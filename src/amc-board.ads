with STM32.Device;
with STM32.GPIO;

package AMC.Board is

   subtype Led_Pin is STM32.GPIO.GPIO_Point;
   subtype Button_Pin is STM32.GPIO.GPIO_Point;
   subtype Mcu_Pin is STM32.GPIO.GPIO_Point;

   Led_Green : Led_Pin renames STM32.Device.PB10;
   Led_Red   : Led_Pin renames STM32.Device.PC10;

   User_Button : Button_Pin renames STM32.Device.PB2;

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

end AMC.Board;
