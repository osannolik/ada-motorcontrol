with STM32.Device;
with STM32.GPIO;
with STM32.Timers;

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
