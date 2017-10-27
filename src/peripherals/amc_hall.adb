with HAL; use HAL;

with Calmeas;

package body AMC_Hall is

   function Is_Valid_Pattern (H : in Hall_Pattern) return Boolean;

   function Get_Hall_Pin_Pattern return Hall_Pattern is
      (Hall_Pattern'(As_Pattern => False,
                     H1_Pin     => H1_Pin.Set,
                     H2_Pin     => H2_Pin.Set,
                     H3_Pin     => H3_Pin.Set));

   Speed_Timer_Resolution : AMC_Types.Seconds;

   Comm_Del_Param : aliased UInt32 := 16#0010#;

   procedure Initialize
   is
      use STM32.Timers;
   begin

      Speed_Timer_Resolution := AMC_Types.Seconds
         (Float (Prescaler) / Float (STM32.Device.System_Clock_Frequencies.TIMCLK1));

      STM32.Device.Enable_Clock (Input_Pins);

      STM32.GPIO.Configure_IO (Points => Input_Pins,
                               Config =>
                                  (Mode        => STM32.GPIO.Mode_AF,
                                   Output_Type => STM32.GPIO.Push_Pull,
                                   Speed       => STM32.GPIO.Speed_100MHz,
                                   Resistors   => STM32.GPIO.Floating));

      STM32.GPIO.Configure_Alternate_Function
         (Points => Input_Pins,
          AF     => STM32.Device.GPIO_AF_TIM4_2);


      STM32.Device.Enable_Clock (Hall_Timer);

      STM32.Device.Reset (Hall_Timer);

      Configure (This          => Hall_Timer,
                 Prescaler     => Prescaler - 1,
                 Period        => Speed_Counter_Max,
                 Clock_Divisor => Div1,
                 Counter_Mode  => Up);

      Configure_Prescaler (This        => Hall_Timer,
                           Prescaler   => Prescaler - 1,
                           Reload_Mode => Immediate);

      Configure_Channel_Input (This      => Hall_Timer,
                               Channel   => Channel_1,
                               Polarity  => Both_Edges,
                               Selection => TRC,
                               Prescaler => Div1,
                               Filter    => 15);

      Enable_Hall_Sensor (Hall_Timer);

      Select_Input_Trigger (Hall_Timer, TI1_Edge_Detector);

      Select_Slave_Mode (Hall_Timer, Reset);

      Set_UpdateRequest (Hall_Timer, Regular);

      --  Hall_Timer is master...
      Enable_Master_Slave_Mode (Hall_Timer);
      --  ...with TI1F_ED = TI1 as output
      Select_Output_Trigger (Hall_Timer, OC1);


      STM32.Device.Enable_Clock (Commutation_Timer);

      STM32.Device.Reset (Commutation_Timer);

      Configure (This          => Commutation_Timer,
                 Prescaler     => Prescaler - 1,
                 Period        => Speed_Counter_Max,
                 Clock_Divisor => Div1,
                 Counter_Mode  => Up);


      --  Commutation_Timer is slave...
      Select_Input_Trigger (Commutation_Timer, Internal_Trigger_3);
      --  ...that is reset at state change
      Select_Slave_Mode (Commutation_Timer, Reset);

      Set_Output_Preload_Enable (Commutation_Timer, Channel_1, False);

      Configure_Channel_Output (This     => Commutation_Timer,
                                Channel  => Channel_1,
                                Mode     => PWM2,
                                State    => Disable,
                                Pulse    => 0,
                                Polarity => High);

      Disable_Interrupt (Commutation_Timer, Timer_CC1_Interrupt);

      for Irq in Timer_Interrupt'Range loop
         Clear_Pending_Interrupt (Hall_Timer, Irq);
      end loop;

      Enable_Interrupt  (Hall_Timer, Timer_CC1_Interrupt);
      Disable_Interrupt (Hall_Timer, Timer_Update_Interrupt);

      Enable_Channel  (Hall_Timer, Channel_1);



      Enable (Hall_Timer);
      Enable (Commutation_Timer);

      Initialized := True;
   end Initialize;

   function Is_Initialized return Boolean is
      (Initialized);

   function Is_Valid_Pattern (H : in Hall_Pattern) return Boolean is
      (H.Bits in AMC_Types.Valid_Hall_Bits);

   function Is_Standstill return Boolean is
   begin
      return State.Overflow;
   end Is_Standstill;

   protected body State is

      entry Await_New (New_State            : out Hall_State;
                       Time_Delta_s         : out AMC_Types.Seconds;
                       Speed_Timer_Overflow : out Boolean) when Hall_State_Is_Updated is
         use AMC_Types;
      begin
         New_State := State;

         Time_Delta_s := Seconds'Max
            (Seconds'Succ (0.0), Seconds (Speed_Timer_Counter) * Speed_Timer_Resolution);

         Speed_Timer_Overflow := Capture_Overflow;

         Hall_State_Is_Updated := False;
      end Await_New;

      function Get return Hall_State is
      begin
         return State;
      end Get;

      procedure Update is
      begin
         State := Hall_State'(Current  => Get_Hall_Pin_Pattern,
                              Previous => State.Current);
         Hall_State_Is_Updated := True;
      end Update;

      procedure Set_Commutation_Delay_Factor (Factor : in AMC_Types.Percent) is
      begin
         Delay_Factor := Factor / AMC_Types.Percent'Last;
      end Set_Commutation_Delay_Factor;

      function Overflow return Boolean is
         (Capture_Overflow);

      procedure ISR is
         use STM32.Timers;

         Commutation_Delay_Compare : UInt32;
      begin
         AMC_Board.Turn_On (AMC_Board.Debug_Pin_1);

         --  Input capture (xor of hall sensor):
         --  Determine current position and calculate speed!
         if Status (Hall_Timer, Timer_CC1_Indicated) and then
            Interrupt_Enabled (Hall_Timer, Timer_CC1_Interrupt)
         then
            Clear_Pending_Interrupt (Hall_Timer, Timer_CC1_Interrupt);

            --  Get time period since last hall state change
            if Capture_Overflow then
               Speed_Timer_Counter := Speed_Counter_Max;
               Capture_Overflow := False;
            else
               Speed_Timer_Counter := Current_Capture_Value (Hall_Timer, Channel_1);
            end if;

            Commutation_Delay_Compare := UInt32 (Delay_Factor * Float (Speed_Timer_Counter));

            if Current_Counter (Hall_Timer) < Commutation_Delay_Compare then
               --  Prepare for commutation.
               --  Assume we need to wait a factor of the latest hall period
               Clear_Pending_Interrupt (Commutation_Timer, Timer_CC1_Interrupt);
               Set_Compare_Value (Commutation_Timer, Channel_1, Commutation_Delay_Compare);
               Enable_Interrupt  (Commutation_Timer, Timer_CC1_Interrupt);
            else
               --  Somehow, setting compare when counter >= compare does not generate interrupt
               --  even though preload is disabled, so generate it manually...
               Commutation.Manual_Trigger;
            end if;

            Update;

            Clear_Pending_Interrupt (Hall_Timer, Timer_Update_Interrupt);
            Enable_Interrupt (Hall_Timer, Timer_Update_Interrupt);
         end if;

         --  Input capture timer has overflowed, assume speed is zero
         if Status (Hall_Timer, Timer_Update_Indicated) and then
            Interrupt_Enabled (Hall_Timer, Timer_Update_Interrupt)
         then
            Capture_Overflow := True;

            Speed_Timer_Counter := Speed_Counter_Max;

            Update;

            Disable_Interrupt (Hall_Timer, Timer_Update_Interrupt);
         end if;

         --  AMC_Board.Turn_Off (AMC_Board.Debug_Pin_1);

      end ISR;

   end State;

   protected body Commutation is

      entry Await_Commutation when Is_Commutation is
      begin
         Is_Commutation := False;
      end Await_Commutation;

      procedure Manual_Trigger is
      begin
         Is_Commutation := True;
      end Manual_Trigger;

      procedure ISR is
         use STM32.Timers;
      begin

         if Status (Commutation_Timer, Timer_CC1_Indicated) and then
            Interrupt_Enabled (Commutation_Timer, Timer_CC1_Interrupt)
         then
            Clear_Pending_Interrupt (Commutation_Timer, Timer_CC1_Interrupt);

            Is_Commutation := True;

            Disable_Interrupt (Commutation_Timer, Timer_CC1_Interrupt);
         end if;

      end ISR;

   end Commutation;

begin

   Calmeas.Add (Symbol      => Comm_Del_Param'Access,
                Name        => "Comm_Delay",
                Description => "");

end AMC_Hall;
