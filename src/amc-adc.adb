with STM32.Device;
with STM32.PWM;
with STM32.Timers;
with AMC.Board;

package body AMC.ADC is

   procedure Initialize (This : in out Object)
   is
      type ADCs is (ADC1, ADC2, ADC3);
      type ADCs_Access is array (ADCs'Range) of access STM32.ADC.Analog_To_Digital_Converter;

      All_ADCs : constant ADCs_Access :=
         (STM32.Device.ADC_1'Access, STM32.Device.ADC_2'Access, STM32.Device.ADC_3'Access);

      use AMC.Board;

      Reading : ADC_Reading;
      Nbr_Of_Reg : array (ADCs'Range) of Integer := (others => 0);
      Nbr_Of_Inj : array (ADCs'Range) of Integer := (others => 0);

      Regular_Conv_Trigger : STM32.PWM.PWM_Modulator;
   begin

      This.Reading_Data :=
         ((I_A)        => (Pin          => ADC_I_A_Pin,
                           ADC_Point    => ADC_I_A_Point,
                           Channel_Rank => 1),
          (I_B)        => (Pin          => ADC_I_B_Pin,
                           ADC_Point    => ADC_I_B_Point,
                           Channel_Rank => 1),
          (I_C)        => (Pin          => ADC_I_C_Pin,
                           ADC_Point    => ADC_I_C_Point,
                           Channel_Rank => 1),
          (EMF_A)      => (Pin          => ADC_EMF_A_Pin,
                           ADC_Point    => ADC_EMF_A_Point,
                           Channel_Rank => 2),
          (EMF_B)      => (Pin          => ADC_EMF_B_Pin,
                           ADC_Point    => ADC_EMF_B_Point,
                           Channel_Rank => 2),
          (EMF_C)      => (Pin          => ADC_EMF_C_Pin,
                           ADC_Point    => ADC_EMF_C_Point,
                           Channel_Rank => 2),
          (Bat_Sense)  => (Pin          => ADC_Bat_Sense_Pin,
                           ADC_Point    => ADC_Bat_Sense_Point,
                           Channel_Rank => 1),
          (Board_Temp) => (Pin          => ADC_Board_Temp_Pin,
                           ADC_Point    => ADC_Board_Temp_Point,
                           Channel_Rank => 2));

      for Reading of This.Reading_Data loop
         STM32.Device.Enable_Clock (Reading.Pin);
         Reading.Pin.Configure_IO
            (Config => (Mode => STM32.GPIO.Mode_Analog, others => <>));
      end loop;

      STM32.ADC.Configure_Common_Properties
         (Mode           => STM32.ADC.Triple_Combined_Regular_Injected_Simultaneous,
          Prescalar      => STM32.ADC.PCLK2_Div_2,  --  Somewhat overclocked...
          DMA_Mode       => STM32.ADC.Disabled,
          Sampling_Delay => STM32.ADC.Sampling_Delay_5_Cycles);

      for ADC in ADCs'Range loop
         for R in ADC_Readings_Reg'Range loop
            Reading := This.Reading_Data(R);
            if Reading.ADC_Point.ADC = All_ADCs(ADC) then
               Nbr_Of_Reg(ADC) := Nbr_Of_Reg(ADC) + 1;
            end if;
         end loop;
         for R in ADC_Readings_Inj'Range loop
            Reading := This.Reading_Data(R);
            if Reading.ADC_Point.ADC = All_ADCs(ADC) then
               Nbr_Of_Inj(ADC) := Nbr_Of_Inj(ADC) + 1;
            end if;
         end loop;
      end loop;

      for ADC in ADCs'Range loop

         if Nbr_Of_Reg(ADC) > 0 or Nbr_Of_Inj(ADC) > 0 then
            STM32.Device.Enable_Clock (All_ADCs(ADC).all);

            STM32.ADC.Configure_Unit (This       => All_ADCs(ADC).all,
                                      Resolution => STM32.ADC.ADC_Resolution_12_Bits,
                                      Alignment  => STM32.ADC.Right_Aligned);
            STM32.ADC.Enable (All_ADCs(ADC).all);
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
                  Reading := This.Reading_Data(R);
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
                  Reading := This.Reading_Data(R);
                  if Reading.ADC_Point.ADC = All_ADCs(ADC) then
                     Injecteds(Injected_Channel_Rank(Reading.Channel_Rank)) :=
                        (Channel     => Reading.ADC_Point.Channel,
                         Sample_Time => Sampling_Time_Injected,
                         Offset      => 0);
                  end if;
               end loop;

               Configure_Injected_Conversions
                  (This          => All_ADCs(ADC).all,
                   AutoInjection => False,
                   Trigger       => (Trigger_Rising_Edge, Event => Timer1_CC4_Event),
                   Enable_EOC    => False,
                   Conversions   => Injecteds);
            end;
         end if;
      end loop;

      STM32.PWM.Configure_PWM_Timer(Generator => STM32.Device.Timer_2'Access,
                                    Frequency => 14_000);

      Regular_Conv_Trigger.Attach_PWM_Channel (Generator => STM32.Device.Timer_2'Access,
                                               Channel   => STM32.Timers.Channel_1,
                                               Polarity  => STM32.Timers.High);

      Regular_Conv_Trigger.Set_Duty_Cycle (Value => 50);  --  Anything /= 0 or /= 100


      --  Multi_Disable_DMA_After_Last_Transfer



      Regular_Conv_Trigger.Enable_Output;

      This.Initialized := True;
   end Initialize;

   function Is_Initialized (This : in Object)
      return Boolean is (This.Initialized);

end AMC.ADC;
