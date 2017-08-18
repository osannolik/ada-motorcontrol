with AMC_Utils;
with AMC_Math;

package body AMC_Board is

   procedure Set_Gate_Driver_Power (Enabled : in Boolean)
   is
   begin
      if Enabled then
         Gate_Power_Enable.Set;
      else
         Gate_Power_Enable.Clear;
      end if;
   end Set_Gate_Driver_Power;

   procedure Turn_On (Led : in out Led_Pin)
   is
   begin
      Led.Set;
   end Turn_On;

   procedure Turn_Off (Led : in out Led_Pin)
   is
   begin
      Led.Clear;
   end Turn_Off;

   procedure Toggle (Led : in out Led_Pin)
   is
   begin
      Led.Toggle;
   end Toggle;

   function Is_Pressed (Button : Button_Pin)
      return Boolean is (not Button.Set);

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

      STM32.Device.Enable_Clock (User_Button);

      Configuration := (Mode        => STM32.GPIO.Mode_In,
                        Output_Type => STM32.GPIO.Push_Pull,
                        Speed       => STM32.GPIO.Speed_100MHz,
                        Resistors   => STM32.GPIO.Pull_Up);

      STM32.GPIO.Configure_IO (User_Button, Configuration);

      Initialized := True;
   end Initialize;

   function Is_Initialized
      return Boolean is (Initialized);

   function To_Phase_Current (ADC_Voltage : AMC_Types.Voltage_V)
                        return AMC_Types.Current_A
   is
   begin
      return AMC_Types.Current_A
         ((ADC_Voltage - Ina240_Offset) * Phase_Ampere_Per_ADC_Voltage);
   end To_Phase_Current;

   function To_Phase_Currents (ADC_Voltage : AMC_Types.Abc)
                               return AMC_Types.Abc
   is
   begin
      return AMC_Types.Abc'(A => To_Phase_Current (ADC_Voltage => ADC_Voltage.A),
                            B => To_Phase_Current (ADC_Voltage => ADC_Voltage.B),
                            C => To_Phase_Current (ADC_Voltage => ADC_Voltage.C));
   end To_Phase_Currents;

   function To_Phase_Voltage (ADC_Voltage : AMC_Types.Voltage_V)
                              return AMC_Types.Voltage_V
   is
   begin
      --  Assumes steady state measurement
      return AMC_Types.Voltage_V
         (ADC_Voltage * Phase_Voltage_Per_ADC_Voltage);

   end To_Phase_Voltage;

   function To_Phase_Voltages (ADC_Voltage : AMC_Types.Abc)
                               return AMC_Types.Abc
   is
   begin
      return AMC_Types.Abc'(A => To_Phase_Voltage (ADC_Voltage => ADC_Voltage.A),
                            B => To_Phase_Voltage (ADC_Voltage => ADC_Voltage.B),
                            C => To_Phase_Voltage (ADC_Voltage => ADC_Voltage.C));
   end To_Phase_Voltages;

   function To_Vbus (ADC_Voltage : AMC_Types.Voltage_V)
                     return AMC_Types.Voltage_V
   is
   begin
      return AMC_Types.Voltage_V
         (ADC_Voltage * Vbus_Voltage_Per_ADC_Voltage);

   end To_Vbus;

   function To_Board_Temp (ADC_Voltage : AMC_Types.Voltage_V)
                           return AMC_Types.Temperature_DegC
   is
      R  : Float;
      T0 : constant AMC_Types.Temperature_K :=
         AMC_Utils.To_Kelvin(Temperature_Default);
      T  : AMC_Types.Temperature_K;
   begin
      if ADC_Voltage = 0.0 then
         return Temperature_Default;
      end if;

      R := R_NTC_2 * (ADC_Vref/Float(ADC_Voltage) - 1.0);

      T := AMC_Types.Temperature_K
         (1.0 / (1.0 / Float(T0) + AMC_Math.Log (R / R_NTC_1) / NTC_Beta));

      return AMC_Utils.To_DegC (T);

   end To_Board_Temp;

end AMC_Board;
