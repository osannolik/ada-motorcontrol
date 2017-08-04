with STM32.Device;
with STM32.GPIO;
with STM32.Timers;
with STM32.ADC;

package AMC.Board is
   --  Ada Motor Controller board specifics

   subtype Led_Pin is STM32.GPIO.GPIO_Point;
   subtype Button_Pin is STM32.GPIO.GPIO_Point;
   subtype Mcu_Pin is STM32.GPIO.GPIO_Point;

   Led_Green : Led_Pin renames STM32.Device.PB10;
   Led_Red   : Led_Pin renames STM32.Device.PC10;

   User_Button : Button_Pin renames STM32.Device.PB2;

   Gate_Power_Enable : STM32.GPIO.GPIO_Point renames STM32.Device.PA3;

   PWM_Timer        : STM32.Timers.Timer            renames STM32.Device.Timer_1;
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

   ADC_Bat_Sense_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PC0;
   ADC_Board_Temp_Pin : STM32.GPIO.GPIO_Point renames STM32.Device.PC4;

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


   procedure Set_Gate_Driver_Power (Enabled : in Boolean)
   with
      Pre => Is_Initialized;

   procedure Turn_On  (Led : in out Led_Pin)
   with
      Pre => Is_Initialized;

   procedure Turn_Off (Led : in out Led_Pin)
   with
      Pre => Is_Initialized;

   procedure Toggle   (Led : in out Led_Pin)
   with
      Pre => Is_Initialized;

   function Is_Pressed (Button : Button_Pin)
      return Boolean
   with
      Pre => Is_Initialized;

   function Is_Initialized
      return Boolean;

   procedure Initialize
   with
      Pre  => not Is_Initialized,
      Post => Is_Initialized;

private
   Initialized : Boolean := False;
end AMC.Board;
