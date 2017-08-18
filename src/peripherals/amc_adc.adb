with STM32.PWM;
with STM32.Timers;

with STM32_SVD.ADC;

package body AMC_ADC is

   function To_Voltage (Adc_Value : in AMC_Types.UInt16)
                        return AMC_Types.Voltage_V
   with
      Inline;

   function Get_Sample (Reading : in ADC_Readings)
      return AMC_Types.Voltage_V is
   begin
      if Reading in ADC_Readings_Inj'Range then
         return Handler.Get_Injected_Samples(Reading);
      elsif Reading in ADC_Readings_Reg'Range then
         return To_Voltage (Regular_Samples(Reading));
      else
         return 0.0;
      end if;
   end Get_Sample;

   procedure Initialize
   is
      type ADCs is (ADC1, ADC2, ADC3);
      type ADCs_Access is array (ADCs'Range) of access STM32.ADC.Analog_To_Digital_Converter;

      All_ADCs : constant ADCs_Access :=
         (STM32.Device.ADC_1'Access, STM32.Device.ADC_2'Access, STM32.Device.ADC_3'Access);

      Reading : ADC_Reading;
      Nbr_Of_Reg : array (ADCs'Range) of Integer := (others => 0);
      Nbr_Of_Inj : array (ADCs'Range) of Integer := (others => 0);

      Regular_Conv_Trigger : STM32.PWM.PWM_Modulator;
      DMA_Stream_Config : STM32.DMA.DMA_Stream_Configuration;
   begin

      --  Initialize GPIO for analog input
      for Reading of Readings_ADC_Settings loop
         STM32.Device.Enable_Clock (Reading.Pin);
         Reading.Pin.Configure_IO
            (Config =>
                STM32.GPIO.GPIO_Port_Configuration'(Mode   => STM32.GPIO.Mode_Analog,
                                                    others => <>));
      end loop;

      --  Count the number of regular/injected for each ADC
      for ADC in ADCs'Range loop
         for R in ADC_Readings_Reg'Range loop
            Reading := Readings_ADC_Settings(R);
            if Reading.ADC_Point.ADC = All_ADCs(ADC) then
               Nbr_Of_Reg(ADC) := Nbr_Of_Reg(ADC) + 1;
            end if;
         end loop;
         for R in ADC_Readings_Inj'Range loop
            Reading := Readings_ADC_Settings(R);
            if Reading.ADC_Point.ADC = All_ADCs(ADC) then
               Nbr_Of_Inj(ADC) := Nbr_Of_Inj(ADC) + 1;
            end if;
         end loop;
      end loop;


      for ADC in ADCs'Range loop

         --  Configure the used ADCs
         if Nbr_Of_Reg(ADC) > 0 or Nbr_Of_Inj(ADC) > 0 then
            STM32.Device.Enable_Clock (All_ADCs(ADC).all);

            STM32.ADC.Disable (All_ADCs(ADC).all);

            STM32.ADC.Configure_Unit (This       => All_ADCs(ADC).all,
                                      Resolution => STM32.ADC.ADC_Resolution_12_Bits,
                                      Alignment  => STM32.ADC.Right_Aligned);

            STM32.ADC.Set_Scan_Mode (This    => All_ADCs(ADC).all,
                                     Enabled => True);

            STM32.ADC.Enable_DMA (This => All_ADCs(ADC).all);
            STM32.ADC.Enable_DMA_After_Last_Transfer (This => All_ADCs(ADC).all);
         end if;

         if Nbr_Of_Reg(ADC) > 0 then
            declare
               use STM32.ADC;
               Last_Rank_Reg : constant Regular_Channel_Rank :=
                  Regular_Channel_Rank(Nbr_Of_Reg(ADC));
               Regulars : Regular_Channel_Conversions(1..Last_Rank_Reg) :=
                  (others => (0, Sampling_Time_Regular));
            begin
               for R in ADC_Readings_Reg'Range loop
                  Reading := Readings_ADC_Settings(R);
                  if Reading.ADC_Point.ADC = All_ADCs(ADC) then
                     Regulars(Reading.Channel_Rank) :=
                        (Channel     => Reading.ADC_Point.Channel,
                         Sample_Time => Sampling_Time_Regular);
                  end if;
               end loop;

               Configure_Regular_Conversions
                  (This        => All_ADCs(ADC).all,
                   Continuous  => False,
                   Trigger     => (Trigger_Rising_Edge, Event => Timer2_CC4_Event),
                   Enable_EOC  => False,
                   Conversions => Regulars);
            end;
         end if;

         if Nbr_Of_Inj(ADC) > 0 then
            declare
               use STM32.ADC;
               Last_Rank_Inj : constant Injected_Channel_Rank :=
                  Injected_Channel_Rank(Nbr_Of_Inj(ADC));
               Injecteds : Injected_Channel_Conversions(1..Last_Rank_Inj) :=
                  (others => (0, Sampling_Time_Injected, 0));
            begin
               for R in ADC_Readings_Inj'Range loop
                  Reading := Readings_ADC_Settings(R);
                  if Reading.ADC_Point.ADC = All_ADCs(ADC) then
                     Injecteds(Injected_Channel_Rank(Reading.Channel_Rank)) :=
                        (Channel     => Reading.ADC_Point.Channel,
                         Sample_Time => Sampling_Time_Injected,
                         Offset      => 0);
                  end if;
               end loop;

               if All_ADCs(ADC) = Multi_Main_ADC'Access then
                  Configure_Injected_Conversions
                     (This          => All_ADCs(ADC).all,
                      AutoInjection => False,
                      Trigger       => (Enabler => Trigger_Rising_Edge,
                                        Event => Timer1_CC4_Event),
                      Enable_EOC    => False,
                      Conversions   => Injecteds);
               else
                  Configure_Injected_Conversions
                     (This          => All_ADCs(ADC).all,
                      AutoInjection => False,
                      Trigger       => (Enabler => Trigger_Disabled),
                      Enable_EOC    => False,
                      Conversions   => Injecteds);
               end if;
            end;
         end if;
      end loop;

      --  Setup ADC mode
      STM32.ADC.Configure_Common_Properties
         (Mode           => STM32.ADC.Triple_Injected_Simultaneous,
          Prescalar      => STM32.ADC.PCLK2_Div_2,  --  Somewhat overclocked...
          DMA_Mode       => STM32.ADC.Disabled,
          Sampling_Delay => STM32.ADC.Sampling_Delay_5_Cycles);


      --  Initialize the timer used for triggering the regular conversions
      STM32.PWM.Configure_PWM_Timer(Generator => STM32.Device.Timer_2'Access,
                                    Frequency => STM32.PWM.Hertz(Regular_Conversion_Frequency));

      Regular_Conv_Trigger.Attach_PWM_Channel (Generator => STM32.Device.Timer_2'Access,
                                               Channel   => STM32.Timers.Channel_4,
                                               Polarity  => STM32.Timers.High);

      Regular_Conv_Trigger.Set_Duty_Cycle (Value => 50);  --  Anything /= 0 or /= 100

      --  Initialize the DMA used to copy the values from the regular conversions
      STM32.Device.Enable_Clock (DMA_Ctrl);

      STM32.DMA.Reset (DMA_Ctrl, DMA_Stream);

      DMA_Stream_Config :=
         STM32.DMA.DMA_Stream_Configuration'
         (Channel                      => STM32.DMA.Channel_0,
          Direction                    => STM32.DMA.Peripheral_To_Memory,
          Increment_Peripheral_Address => False,
          Increment_Memory_Address     => True,
          Peripheral_Data_Format       => STM32.DMA.HalfWords,
          Memory_Data_Format           => STM32.DMA.HalfWords,
          Operation_Mode               => STM32.DMA.Circular_Mode,
          Priority                     => STM32.DMA.Priority_Medium,
          FIFO_Enabled                 => False,
          FIFO_Threshold               => STM32.DMA.FIFO_Threshold_Half_Full_Configuration,
          Memory_Burst_Size            => STM32.DMA.Memory_Burst_Single,
          Peripheral_Burst_Size        => STM32.DMA.Peripheral_Burst_Single);

      STM32.DMA.Configure (DMA_Ctrl, DMA_Stream, DMA_Stream_Config);

      STM32.DMA.Clear_All_Status (DMA_Ctrl, DMA_Stream);

      STM32.DMA.Start_Transfer (This        => DMA_Ctrl,
                                Stream      => DMA_Stream,
                                Source      => STM32.ADC.Data_Register_Address
                                                  (This => Regulars_ADC),
                                Destination => Regular_Samples'Address,
                                Data_Count  => Regular_Samples'Length);

      STM32.ADC.Enable_Interrupts (Multi_Main_ADC, STM32.ADC.Injected_Channel_Conversion_Complete);


      --  Finally, enable the used ADCs
      for ADC in ADCs'Range loop
         if Nbr_Of_Reg(ADC) > 0 or Nbr_Of_Inj(ADC) > 0 then
            STM32.ADC.Enable (All_ADCs(ADC).all);
         end if;
      end loop;

      Regular_Conv_Trigger.Enable_Output;

      Initialized := True;
   end Initialize;

   function Is_Initialized
      return Boolean is (Initialized);

   function To_Voltage (Adc_Value : in AMC_Types.UInt16)
                        return AMC_Types.Voltage_V
   is
   begin
      return AMC_Types.Voltage_V (ADC_V_Per_Lsb * Float (Adc_Value));
   end To_Voltage;

   protected body Handler is

      function Get_Injected_Samples return Injected_Samples_Array is
      begin
         return Samples;
      end Get_Injected_Samples;

      entry Await_New_Samples (Phase_Voltage_Samples : out AMC_Types.Abc;
                               Phase_Current_Samples : out AMC_Types.Abc) when New_Samples is
      begin
         Phase_Voltage_Samples := AMC_Types.Abc'(A => Samples(EMF_A),
                                                 B => Samples(EMF_B),
                                                 C => Samples(EMF_C));
         Phase_Current_Samples := AMC_Types.Abc'(A => Samples(I_A),
                                                 B => Samples(I_B),
                                                 C => Samples(I_C));
         New_Samples := False;
      end Await_New_Samples;

      procedure ISR is
         use STM32.ADC;
      begin
         --  AMC_Board.Turn_On (AMC_Board.Led_Green);

         if Status (Multi_Main_ADC, Injected_Channel_Conversion_Complete) then
            Clear_Interrupt_Pending (Multi_Main_ADC, Injected_Channel_Conversion_Complete);

            for R in ADC_Readings_Inj'Range loop
               Samples(R) := To_Voltage
                  (STM32.ADC.Injected_Conversion_Value
                      (This => Readings_ADC_Settings(R).ADC_Point.ADC.all,
                       Rank => Injected_Channel_Rank(Readings_ADC_Settings(R).Channel_Rank)));
            end loop;

            New_Samples := True;
         end if;
      end ISR;

   end Handler;

end AMC_ADC;
