package body AMC.ADC is

   procedure Initialize
   is
      Configuration : STM32.GPIO.GPIO_Port_Configuration;
      All_PP_Outputs : constant STM32.GPIO.GPIO_Points := (Led_Red, Led_Green, Gate_Power_Enable);
   begin
      STM32.Device.Enable_Clock (All_PP_Outputs);

      Configuration := (Mode        => STM32.GPIO.Mode_Out,
                        Output_Type => STM32.GPIO.Push_Pull,
                        Speed       => STM32.GPIO.Speed_100MHz,
                        Resistors   => STM32.GPIO.Floating);

      STM32.GPIO.Configure_IO (All_PP_Outputs, Configuration);

      Initialized := True;
   end Initialize;

   function Is_Initialized
      return Boolean is (Initialized);

end AMC.ADC;
