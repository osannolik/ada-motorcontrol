with STM32.Device;
with STM32.ADC;

package AMC.ADC is
   --  Analog to digital conversion
   --  Interfaces the mcu adc peripheral


   function Is_Initialized
      return Boolean;

   procedure Initialize
   with
      Pre  => not Is_Initialized,
      Post => Is_Initialized;

private
   Initialized : Boolean := False;
end AMC.ADC;
