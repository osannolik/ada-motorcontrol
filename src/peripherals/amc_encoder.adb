with STM32.GPIO;
with AMC_Board;
with AMC_Math;
with HAL; use HAL;

package body AMC_Encoder is

   procedure Initialize
   is
      use STM32.Timers;

      Input_Pins : constant STM32.GPIO.GPIO_Points :=
         (AMC_Board.Encoder_A_Pin, AMC_Board.Encoder_B_Pin);

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

      STM32.Device.Enable_Clock (Counting_Timer);


      Configure (This          => Counting_Timer,
                 Prescaler     => 0,
                 Period        => AMC_Types.UInt32 (Counts_Per_Revolution) - 1,
                 Clock_Divisor => Div1,
                 Counter_Mode  => Up);

      Configure_Encoder_Interface (This         => Counting_Timer,
                                   Mode         => Encoder_Mode_TI1_TI2,
                                   IC1_Polarity => Rising,
                                   IC2_Polarity => Rising);


      --  TODO: Add Speed measurement using another timer

--        Select_Output_Trigger (This   => Counting_Timer,
--                               Source => OC1);
--
--        Enable_Master_Slave_Mode (This => Counting_Timer);




      Set_Counter (Counting_Timer, AMC_Types.UInt16'(0));

      Enable_Channel (Counting_Timer, Channel_1);
      Enable_Channel (Counting_Timer, Channel_2);

      Enable (Counting_Timer);

      Initialized := True;
   end Initialize;

   function Is_Initialized return Boolean is
      (Initialized);

   function Get_Counter return AMC_Types.UInt32 is
      (STM32.Timers.Current_Counter (Counting_Timer));

   function Get_Angle return AMC_Types.Angle_Rad is
      use STM32.Timers;
   begin
      return AMC_Types.Angle_Rad
         (Float (2 * (Current_Counter (Counting_Timer))) * AMC_Math.Pi / Counts_Per_Revolution);
   end Get_Angle;

   function Get_Angle return AMC_Types.Angle_Deg is
      use STM32.Timers;
   begin
      return AMC_Types.Angle_Deg
         (Float (Current_Counter (Counting_Timer)) * 360.0 / Counts_Per_Revolution);
   end Get_Angle;

   function Get_Angle return AMC_Types.Angle is
      use AMC_Types;
   begin
      return Compose (Angle_Rad'(Get_Angle));
   end Get_Angle;

   procedure Set_Angle (Angle : in AMC_Types.Angle_Rad) is
      Counter : constant AMC_Types.UInt16 :=
         AMC_Types.UInt16 (Float (Angle) * Counts_Per_Revolution / (2.0 * AMC_Math.Pi));
   begin
      STM32.Timers.Set_Counter (Counting_Timer, Counter);
   end Set_Angle;

   function Get_Direction return Float is
      use STM32.Timers;
   begin
      case Current_Counter_Mode (Counting_Timer) is
         when Up     => return  1.0;
         when Down   => return -1.0;
         when others => return  0.0;
      end case;
   end Get_Direction;

end AMC_Encoder;
