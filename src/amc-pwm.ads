
with STM32.PWM;
with Ada.Interrupts.Names;

package AMC.PWM is
   --  Pulse width modulation
   --  Interfaces the mcu pwm peripheral

   function Is_Initialized
      return Boolean;

   procedure Initialize
   with
      Pre  => not Is_Initialized,
      Post => Is_Initialized;

   procedure Generate_Break_Event;

private
   Initialized : Boolean := False;

   PWM_A : STM32.PWM.PWM_Modulator;
   PWM_B : STM32.PWM.PWM_Modulator;
   PWM_C : STM32.PWM.PWM_Modulator;

   protected Break is
      pragma Interrupt_Priority;

   private

      procedure Break_ISR;
      pragma Attach_Handler (Break_ISR, Ada.Interrupts.Names.TIM1_BRK_TIM9_Interrupt);

   end Break;

end AMC.PWM;
