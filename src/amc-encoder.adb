with STM32.GPIO;
with AMC.Board;
with AMC_Math;

package body AMC.Encoder is

   procedure Initialize
      (This : in out Object)
   is
      use STM32.Timers;

      Input_Pins : constant STM32.GPIO.GPIO_Points :=
         (AMC.Board.Encoder_A_Pin, AMC.Board.Encoder_B_Pin);

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
                 Period        => UInt32 (Counts_Per_Revolution) - 1,
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




      Set_Counter (Counting_Timer, UInt16'(0));

      Enable_Channel (Counting_Timer, Channel_1);
      Enable_Channel (Counting_Timer, Channel_2);

      Enable (Counting_Timer);

      This.Initialized := True;
   end Initialize;

   function Is_Initialized (This : Object) return Boolean is
      (This.Initialized);

   function Get_Counter (This : in Object) return UInt32 is
      (STM32.Timers.Current_Counter (Counting_Timer));

   function Get_Angle (This : in Object) return AMC_Types.Angle_Rad is
      use STM32.Timers;
   begin
      return AMC_Types.Angle_Rad
         (Float (2*(Current_Counter (Counting_Timer))) * AMC_Math.PI / Counts_Per_Revolution);
   end Get_Angle;

   function Get_Angle (This : in Object) return AMC_Types.Angle_Deg is
      use STM32.Timers;
   begin
      return AMC_Types.Angle_Deg
         (Float (Current_Counter (Counting_Timer)) * 360.0 / Counts_Per_Revolution);
   end Get_Angle;

   function Get_Angle (This : in Object) return AMC_Types.Angle is
      use AMC_Types;
   begin
      return Compose (Angle_Rad'(Get_Angle (This)));
   end Get_Angle;

end AMC.Encoder;
