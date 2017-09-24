with HAL; use HAL;
--  with AMC_Types;

with Calmeas;

package body AMC_Hall is

   function Is_Valid_Pattern (H : in Hall_Pattern) return Boolean;
   function Get_Hall_Pin_Pattern return Hall_Pattern;

   Speed_Counter_Max : constant UInt32 := UInt32 (UInt16'Last);

   Comm_Del_Param : aliased UInt32 := 0;

   Hall_Cntr : aliased UInt32 := 0;

   procedure Initialize
   is
      use STM32.Timers;
   begin

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

      Configure_Channel_Output (This     => Hall_Timer,
                                Channel  => Channel_2,
                                Mode     => PWM2,
                                State    => Disable,
                                Pulse    => 0,
                                Polarity => High);

      Set_UpdateRequest (Hall_Timer, Regular);

      Set_Output_Preload_Enable (Hall_Timer, Channel_2, False);

      for Irq in Timer_Interrupt'Range loop
         Clear_Pending_Interrupt (Hall_Timer, Irq);
      end loop;

      Enable_Interrupt  (Hall_Timer, Timer_CC1_Interrupt);
      Disable_Interrupt (Hall_Timer, Timer_CC2_Interrupt);
      Disable_Interrupt (Hall_Timer, Timer_Update_Interrupt);

      Enable_Channel  (Hall_Timer, Channel_1);

      Handler.Update_State;

      Enable (Hall_Timer);

      Initialized := True;
   end Initialize;

   function Is_Initialized return Boolean is
      (Initialized);

   function Get_Hall_Pin_Pattern return Hall_Pattern is
      (Hall_Pattern'(As_Pattern => False,
                     H1         => H1_Pin.Set,
                     H2         => H2_Pin.Set,
                     H3         => H3_Pin.Set));

   function Is_Valid_Pattern (H : in Hall_Pattern) return Boolean is
      (not (H.Pattern = Hall_Bits'(2#000#) or H.Pattern = Hall_Bits'(2#111#)));

   protected body Handler is

      procedure Update_State is
      begin
         State := Hall_State'(Current  => Get_Hall_Pin_Pattern,
                              Previous => State.Current);
      end Update_State;

      procedure ISR is
         use STM32.Timers;

         Commutation_Delay_Compare : AMC_Types.UInt32 := 0;
      begin
         AMC_Board.Turn_On (AMC_Board.Debug_Pin_1);

         --  Input capture (xor of hall sensor):
         --  Determine current position and calculate speed!
         if Status (Hall_Timer, Timer_CC1_Indicated) and then
            Interrupt_Enabled (Hall_Timer, Timer_CC1_Interrupt)
         then
            Clear_Pending_Interrupt (Hall_Timer, Timer_CC1_Interrupt);

            --  Get time period since last hall state change
            Speed_Timer_Counter := Current_Capture_Value (Hall_Timer, Channel_1);

            Update_State;

            Hall_State_Is_Updated := True;

            AMC_Board.Turn_On  (AMC_Board.Debug_Pin_2);
            AMC_Board.Turn_Off (AMC_Board.Debug_Pin_2);


            Commutation_Delay_Compare := Comm_Del_Param;

            Clear_Pending_Interrupt (Hall_Timer, Timer_Update_Interrupt);
            Enable_Interrupt (Hall_Timer, Timer_Update_Interrupt);

            --  Prepare for commutation.
            --  Assume we need to wait a factor of the latest hall period
            Clear_Pending_Interrupt (Hall_Timer, Timer_CC2_Interrupt);
            Hall_Cntr := Current_Counter (Hall_Timer);
            Set_Compare_Value (Hall_Timer, Channel_2, Commutation_Delay_Compare);
            Enable_Interrupt (Hall_Timer, Timer_CC2_Interrupt);
         end if;

         --  Output compare is creating a pulse delayed from the input capture event:
         --  Trigger a commutation!
         if (Status (Hall_Timer, Timer_CC2_Indicated) or else
             --  Somehow, setting compare when counter >= compare does not generate interrupt
             --  even though preload is disabled, so check manually...
             Current_Counter (Hall_Timer) >= Commutation_Delay_Compare) and then
            Interrupt_Enabled (Hall_Timer, Timer_CC2_Interrupt)
         then

            AMC_Board.Turn_On  (AMC_Board.Debug_Pin_3);
            AMC_Board.Turn_Off (AMC_Board.Debug_Pin_3);

            Is_Commutation := True;

            Disable_Interrupt (Hall_Timer, Timer_CC2_Interrupt);
         end if;

         --  Input capture timer has overflowed, assume speed is zero
         if Status (Hall_Timer, Timer_Update_Indicated) and then
            Interrupt_Enabled (Hall_Timer, Timer_Update_Interrupt)
         then

            AMC_Board.Turn_On  (AMC_Board.Debug_Pin_4);
            AMC_Board.Turn_Off (AMC_Board.Debug_Pin_4);

            Capture_Overflow := True;

            Disable_Interrupt (Hall_Timer, Timer_Update_Interrupt);
         end if;

         AMC_Board.Turn_Off (AMC_Board.Debug_Pin_1);

      end ISR;

   end Handler;

--     function Get_Angle return AMC_Types.Angle_Rad is
--        use STM32.Timers;
--     begin
--        return AMC_Types.Angle_Rad
--           (Float (2 * (Current_Counter (Counting_Timer))) * AMC_Math.Pi / Counts_Per_Revolution);
--     end Get_Angle;
--
--     function Get_Angle return AMC_Types.Angle_Deg is
--        use STM32.Timers;
--     begin
--        return AMC_Types.Angle_Deg
--           (Float (Current_Counter (Counting_Timer)) * 360.0 / Counts_Per_Revolution);
--     end Get_Angle;
--
--     function Get_Angle return AMC_Types.Angle is
--        use AMC_Types;
--     begin
--        return Compose (Angle_Rad'(Get_Angle));
--     end Get_Angle;
--
--     procedure Set_Angle (Angle : in AMC_Types.Angle_Rad) is
--        Counter : constant AMC_Types.UInt16 :=
--           AMC_Types.UInt16 (Float (Angle) * Counts_Per_Revolution / (2.0 * AMC_Math.Pi));
--     begin
--        STM32.Timers.Set_Counter (Counting_Timer, Counter);
--     end Set_Angle;
--
--     function Get_Direction return Float is
--        use STM32.Timers;
--     begin
--        case Current_Counter_Mode (Counting_Timer) is
--           when Up     => return  1.0;
--           when Down   => return -1.0;
--           when others => return  0.0;
--        end case;
--     end Get_Direction;

begin
   Calmeas.Add (Symbol      => Comm_Del_Param'Access,
                Name        => "Comm_Delay",
                Description => "");
   Calmeas.Add (Symbol      => Hall_Cntr'Access,
                Name        => "Hall_Cntr",
                Description => "");
end AMC_Hall;
