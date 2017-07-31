package body AMC.Board is

   Initialized : Boolean := False;

   procedure Turn_On (Led : in out Led_Pin)
   is
   begin
      STM32.GPIO.Set(This => Led);
   end Turn_On;

   procedure Turn_Off (Led : in out Led_Pin)
   is
   begin
      STM32.GPIO.Clear(This => Led);
   end Turn_Off;

   procedure Toggle (Led : in out Led_Pin)
   is
   begin
      STM32.GPIO.Toggle(This => Led);
   end Toggle;

   function Is_Pressed (Button : Button_Pin)
      return Boolean
   is
   begin
      return not STM32.GPIO.Set (Button);
   end Is_Pressed;

   procedure Initialize
   is
      Configuration : STM32.GPIO.GPIO_Port_Configuration;
      All_Leds      : constant STM32.GPIO.GPIO_Points := (Led_Red, Led_Green);
   begin
      STM32.Device.Enable_Clock (All_Leds);

      Configuration.Mode        := STM32.GPIO.Mode_Out;
      Configuration.Output_Type := STM32.GPIO.Push_Pull;
      Configuration.Speed       := STM32.GPIO.Speed_100MHz;
      Configuration.Resistors   := STM32.GPIO.Floating;
      STM32.GPIO.Configure_IO (All_Leds, Configuration);

      STM32.Device.Enable_Clock (User_Button);

      Configuration.Mode        := STM32.GPIO.Mode_In;
      Configuration.Output_Type := STM32.GPIO.Push_Pull;
      Configuration.Speed       := STM32.GPIO.Speed_100MHz;
      Configuration.Resistors   := STM32.GPIO.Pull_Up;
      STM32.GPIO.Configure_IO (User_Button, Configuration);

      Initialized := True;
   end Initialize;

   function Is_Initialized return Boolean is (Initialized);

end AMC.Board;
