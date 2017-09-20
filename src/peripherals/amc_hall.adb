with HAL; use HAL;
with AMC_Types;
package body AMC_Hall is



   procedure Initialize
   is
      use STM32.Timers;

      Speed_Counter_Max : constant AMC_Types.UInt32 := 16#FFFF#;
      Prescaler         : constant AMC_Types.UInt16 := 225;
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

      Configure (This          => Hall_Timer,
                 Prescaler     => Prescaler - 1,
                 Period        => Speed_Counter_Max,
                 Clock_Divisor => Div1,
                 Counter_Mode  => Up);


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
                                Pulse    => 1,
                                Polarity => High);

      Select_Output_Trigger (Hall_Timer, OC2Ref);

      Set_UpdateRequest (Hall_Timer, Regular);


      Enable_Interrupt (Hall_Timer, Timer_Update_Interrupt);
      Enable_Interrupt (Hall_Timer, Timer_CC1_Interrupt);

      Enable_Channel (Hall_Timer, Channel_1);
      Enable_Channel (Hall_Timer, Channel_2);

      Enable (Hall_Timer);

      Initialized := True;
   end Initialize;

   function Is_Initialized return Boolean is
      (Initialized);

   protected body Handler is

      procedure ISR is
         use STM32.Timers;
      begin

         --  Input capture (xor of hall sensor):
         --  Determine current position and calculate speed!
         if Status (Hall_Timer, Timer_CC1_Indicated) then
            Clear_Pending_Interrupt (Hall_Timer, Timer_CC1_Interrupt);

            Enable_Interrupt (Hall_Timer, Timer_CC2_Interrupt);
            Enable_Interrupt (Hall_Timer, Timer_Update_Interrupt);
         end if;

         --  Output compare is creating a pulse delayed from the input capture event:
         --  Trigger a BLDC commutation!
         if Status (Hall_Timer, Timer_CC2_Indicated) then
            Clear_Pending_Interrupt (Hall_Timer, Timer_CC2_Interrupt);

            Disable_Interrupt (Hall_Timer, Timer_CC2_Interrupt);
         end if;

         --  Input capture timer has overflowed, assume speed is zero
         if Status (Hall_Timer, Timer_Update_Indicated) then
            Clear_Pending_Interrupt (Hall_Timer, Timer_Update_Interrupt);

            Disable_Interrupt (Hall_Timer, Timer_Update_Interrupt);
         end if;

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

end AMC_Hall;
