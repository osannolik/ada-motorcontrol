with STM32.Device;
with STM32.GPIO;
with STM32.Timers;
with STM32.ADC;
with STM32.USARTs;
with AMC_Types;

package AMC_Board is
   --  @summary
   --  Ada Motor Controller board specifics
   --
   --  @description
   --  Defines parameters and configurations related to the used board.
   --
   --  https://github.com/osannolik/MotCtrl
   --

   ADC_Vref      : constant Float := 3.3;
   --  ADC full scale voltage

   R_Shunt       : constant Float := 0.5e-3;  --  R26, R27, R28
   Ina240_Gain   : constant Float := 50.0;
   Ina240_Offset : constant Float := ADC_Vref * 0.5;

   R_EMF_1       : constant Float := 33.0e3;  --  R29, R31, R33
   R_EMF_2       : constant Float := 3.9e3;   --  R35, R36, R37

   R_Vbus_1      : constant Float := 20.0e3;  --  R1
   R_Vbus_2      : constant Float := 1.8e3;   --  R2

   R_NTC_1       : constant Float := 10.0e3;  --  NTC
   R_NTC_2       : constant Float := 10.0e3;  --  R3
   NTC_Beta      : constant Float := 3434.0;

   Temperature_Default : constant AMC_Types.Temperature_DegC := 25.0;

   subtype Led_Pin is STM32.GPIO.GPIO_Point;
   subtype Debug_Pin is STM32.GPIO.GPIO_Point;
   subtype Button_Pin is STM32.GPIO.GPIO_Point;
   subtype Mcu_Pin is STM32.GPIO.GPIO_Point;

   Led_Green : Led_Pin renames STM32.Device.PB10;
   Led_Red   : Led_Pin renames STM32.Device.PC10;

   Debug_Pin_1 : Debug_Pin renames STM32.Device.PB12;
   Debug_Pin_2 : Debug_Pin renames STM32.Device.PB13;
   Debug_Pin_3 : Debug_Pin renames STM32.Device.PB14;
   Debug_Pin_4 : Debug_Pin renames STM32.Device.PB15;

   User_Button : Button_Pin renames STM32.Device.PB2;

   Gate_Power_Enable : STM32.GPIO.GPIO_Point renames STM32.Device.PA3;

   PWM_Timer        : STM32.Timers.Timer            renames STM32.Device.Timer_1;
   ADC_Reg_Timer    : STM32.Timers.Timer            renames STM32.Device.Timer_2;
   Pos_Comm_Timer   : STM32.Timers.Timer            renames STM32.Device.Timer_3;
   Pos_Timer        : STM32.Timers.Timer            renames STM32.Device.Timer_4;
   Wdg_Timer        : STM32.Timers.Timer            renames STM32.Device.Timer_6;

   PWM_Gate_GPIO_AF : STM32.GPIO_Alternate_Function renames STM32.Device.GPIO_AF_TIM1_1;
   PWM_Gate_A_Ch    : STM32.Timers.Timer_Channel    renames STM32.Timers.Channel_1;
   PWM_Gate_B_Ch    : STM32.Timers.Timer_Channel    renames STM32.Timers.Channel_2;
   PWM_Gate_C_Ch    : STM32.Timers.Timer_Channel    renames STM32.Timers.Channel_3;
   PWM_Trigger_Ch   : STM32.Timers.Timer_Channel    renames STM32.Timers.Channel_4;

   PWM_Gate_H_A_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PA8;
   PWM_Gate_L_A_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PA7;
   PWM_Gate_H_B_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PA9;
   PWM_Gate_L_B_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PB0;
   PWM_Gate_H_C_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PA10;
   PWM_Gate_L_C_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PB1;

   ADC_I_A_Pin      : STM32.GPIO.GPIO_Point renames STM32.Device.PC1;
   ADC_I_B_Pin      : STM32.GPIO.GPIO_Point renames STM32.Device.PC2;
   ADC_I_C_Pin      : STM32.GPIO.GPIO_Point renames STM32.Device.PC3;

   ADC_EMF_A_Pin    : STM32.GPIO.GPIO_Point renames STM32.Device.PA0;
   ADC_EMF_B_Pin    : STM32.GPIO.GPIO_Point renames STM32.Device.PA1;
   ADC_EMF_C_Pin    : STM32.GPIO.GPIO_Point renames STM32.Device.PA2;

   ADC_Bat_Sense_Pin  : STM32.GPIO.GPIO_Point renames STM32.Device.PC0;
   ADC_Board_Temp_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PC4;
   ADC_Ext_V_Pin      : STM32.GPIO.GPIO_Point renames STM32.Device.PA4;

   ADC_I_A_Point    : constant STM32.ADC.ADC_Point :=
      (STM32.Device.ADC_1'Access, Channel => 11);

   ADC_I_B_Point    : constant STM32.ADC.ADC_Point :=
      (STM32.Device.ADC_2'Access, Channel => 12);

   ADC_I_C_Point    : constant STM32.ADC.ADC_Point :=
      (STM32.Device.ADC_3'Access, Channel => 13);

   ADC_EMF_A_Point  : constant STM32.ADC.ADC_Point :=
      (STM32.Device.ADC_1'Access, Channel => 0);

   ADC_EMF_B_Point  : constant STM32.ADC.ADC_Point :=
      (STM32.Device.ADC_2'Access, Channel => 1);

   ADC_EMF_C_Point  : constant STM32.ADC.ADC_Point :=
      (STM32.Device.ADC_3'Access, Channel => 2);

   ADC_Bat_Sense_Point : constant STM32.ADC.ADC_Point :=
      (STM32.Device.ADC_1'Access, Channel => 10);

   ADC_Board_Temp_Point : constant STM32.ADC.ADC_Point :=
      (STM32.Device.ADC_1'Access, Channel => 14);

   ADC_Ext_V_Point : constant STM32.ADC.ADC_Point :=
      (STM32.Device.ADC_1'Access, Channel => 4);

   Encoder_A_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PB6;
   Encoder_B_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PB7;

   Hall_1_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PB6;
   Hall_2_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PB7;
   Hall_3_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PB8;

   Uart_Tx_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PC6;
   Uart_Rx_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PC7;
   Uart_Peripheral : STM32.USARTs.USART renames STM32.Device.USART_6;
   Uart_GPIO_AF : STM32.GPIO_Alternate_Function renames STM32.Device.GPIO_AF_USART6_8;

   procedure Set_Gate_Driver_Power (Enabled : in Boolean)
   with
      Pre => Is_Initialized;
   --  Enable or disable the power to the gate drivers.
   --  @param Enabled Enables the power if True

   procedure Turn_On  (Led : in out Led_Pin)
   with
      Pre => Is_Initialized;
   --  Turns on the specified LED.
   --  @param Led The specified LED.

   procedure Turn_Off (Led : in out Led_Pin)
   with
      Pre => Is_Initialized;
   --  Turns off the specified LED.
   --  @param Led The specified LED.

   procedure Toggle   (Led : in out Led_Pin)
   with
      Pre => Is_Initialized;
   --  Toggles the specified LED.
   --  @param Led The specified LED.

   function Is_Pressed (Button : Button_Pin)
      return Boolean
   with
      Pre => Is_Initialized;
   --  @param Button Specifies the button.
   --  @return True if the button is pressed.

   function Is_Initialized
      return Boolean;
   --  @return True if the board specifics are initialized.

   procedure Initialize
   with
      Pre  => not Is_Initialized,
      Post => Is_Initialized;
   --  Initializes the board specifics.

   function To_Phase_Current (ADC_Voltage : AMC_Types.Voltage_V)
                              return AMC_Types.Current_A
   with
      Inline;
   --  Convert an ADC reading to the corresponding phase current.
   --  @param ADC_Voltage ADC reading in volts
   --  @return Corresponding phase current in amperes

   function To_Phase_Currents (ADC_Voltage : AMC_Types.Abc)
                               return AMC_Types.Abc
   with
      Inline;
   --  Convert ADC readings to the corresponding phase currents.
   --  @param ADC_Voltage ADC readings in volts
   --  @return Corresponding phase currents in amperes

   function To_Phase_Voltage (ADC_Voltage : AMC_Types.Voltage_V)
                              return AMC_Types.Voltage_V
   with
      Inline;
   --  Convert an ADC reading to the corresponding phase voltage.
   --  @param ADC_Voltage ADC reading in volts
   --  @return Corresponding phase voltage

   function To_Phase_Voltages (ADC_Voltage : AMC_Types.Abc)
                               return AMC_Types.Abc
      with
      Inline;
   --  Convert ADC readings to the corresponding phase voltages.
   --  @param ADC_Voltage ADC readings in volts
   --  @return Corresponding phase voltages

   function To_Vbus (ADC_Voltage : AMC_Types.Voltage_V)
                     return AMC_Types.Voltage_V
   with
      Inline;
   --  Convert an ADC reading to the corresponding bus voltage.
   --  @param ADC_Voltage ADC reading in volts
   --  @return Corresponding bus voltage

   function To_Board_Temp (ADC_Voltage : AMC_Types.Voltage_V)
                           return AMC_Types.Temperature_DegC;
   --  Convert an ADC reading to the corresponding temperature.
   --  @param ADC_Voltage ADC reading in volts
   --  @return Corresponding temperature

   function Get_Startup_Reason return AMC_Types.Start_Reason;
   --  @return The reason for board startup.

   procedure Safe_State;
   --  Forces the inverter into a state that is considered safe.
   --  Typically this disables the PWM generation (all switches off), and
   --  turns off the power to the gate drivers.

private
   Initialized : Boolean := False;

   Startup_Reason : AMC_Types.Start_Reason;

   Phase_Ampere_Per_ADC_Voltage : constant Float :=
      1.0 / (R_Shunt * Ina240_Gain);

   Phase_Voltage_Per_ADC_Voltage : constant Float :=
      (R_EMF_1 + R_EMF_2) / R_EMF_2;

   Vbus_Voltage_Per_ADC_Voltage : constant Float :=
      (R_Vbus_1 + R_Vbus_2) / R_Vbus_2;

end AMC_Board;
