
with STM32.PWM;

package AMC.PWM is
   --  Pulse width modulation
   --  Interfaces the mcu pwm peripheral

   function Is_Initialized
      return Boolean;

   procedure Initialize
   with
      Pre  => not Is_Initialized,
      Post => Is_Initialized;

private
   Initialized : Boolean := False;

   PWM_A : STM32.PWM.PWM_Modulator;
   PWM_B : STM32.PWM.PWM_Modulator;
   PWM_C : STM32.PWM.PWM_Modulator;

end AMC.PWM;
