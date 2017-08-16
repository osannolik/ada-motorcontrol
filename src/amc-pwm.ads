with STM32.GPIO;
with STM32.Timers;
with STM32.PWM;
with Ada.Interrupts.Names;
with AMC_Types;
with AMC.Board;

package AMC.PWM is
   --  Pulse width modulation
   --  Interfaces the mcu pwm peripheral

   type Gate_Setting is private;

   type Gate_Settings is private;


   function Is_Initialized
      return Boolean;

   procedure Initialize
   --  Initialize the peripheral.
   --  Each phase need to be enabled manually after this.
      (Frequency : AMC_Types.Frequency_Hz;
       Deadtime  : AMC_Types.Seconds;
       Alignment : AMC_Types.PWM_Alignment);

   procedure Enable
   --  Enable PWM generation for the specified phase
      (Phase : AMC_Types.Phase);

   procedure Disable
   --  Disable PWM generation for the specified phase
      (Phase : AMC_Types.Phase);

   function Get_Duty_Resolution
   --  Get the minimum step that the duty can be changed
      return AMC_Types.Duty_Cycle;

   procedure Set_Duty_Cycle
   --  Sets the duty cycle for the specified Phase
      (Phase : AMC_Types.Phase;
       Value : AMC_Types.Duty_Cycle);

   procedure Set_Duty_Cycle
   --  Sets the duty cycle for all phases
      (Dabc : AMC_Types.Abc);

   procedure Set_Trigger_Cycle
   --  Sets where over the PWM cycle the trigger shall occur.
      (Value : AMC_Types.Duty_Cycle);

   procedure Generate_Break_Event;
   --  Sets the pwm outputs to an inactive state, e.g. all low.

private

   type Gate_Setting is record
      Channel   : STM32.Timers.Timer_Channel;
      Pin_H     : STM32.GPIO.GPIO_Point;
      Pin_L     : STM32.GPIO.GPIO_Point;
      Pin_AF    : STM32.GPIO_Alternate_Function;
   end record;

   type Gate_Settings is array (AMC_Types.Phase'Range) of Gate_Setting;

   Initialized : Boolean := False;

   PWM_Timer_Ref : access STM32.Timers.Timer := AMC.Board.PWM_Timer'Access;

   Modulators : array (AMC_Types.Phase'Range) of STM32.PWM.PWM_Modulator;

   Gate_Phase_Settings : constant Gate_Settings :=
      ((AMC_Types.A) => Gate_Setting'(Channel => AMC.Board.PWM_Gate_A_Ch,
                                      Pin_H   => AMC.Board.PWM_Gate_H_A_Pin,
                                      Pin_L   => AMC.Board.PWM_Gate_L_A_Pin,
                                      Pin_AF  => AMC.Board.PWM_Gate_GPIO_AF),
       (AMC_Types.B) => Gate_Setting'(Channel => AMC.Board.PWM_Gate_B_Ch,
                                      Pin_H   => AMC.Board.PWM_Gate_H_B_Pin,
                                      Pin_L   => AMC.Board.PWM_Gate_L_B_Pin,
                                      Pin_AF  => AMC.Board.PWM_Gate_GPIO_AF),
       (AMC_Types.C) => Gate_Setting'(Channel => AMC.Board.PWM_Gate_C_Ch,
                                      Pin_H   => AMC.Board.PWM_Gate_H_C_Pin,
                                      Pin_L   => AMC.Board.PWM_Gate_L_C_Pin,
                                      Pin_AF  => AMC.Board.PWM_Gate_GPIO_AF));

   Trigger_Modulator : STM32.PWM.PWM_Modulator;

   Trigger_Channel : constant STM32.Timers.Timer_Channel :=
      AMC.Board.PWM_Trigger_Ch;


   protected Break is
      pragma Interrupt_Priority;

   private

      procedure Break_ISR;
      pragma Attach_Handler (Break_ISR, Ada.Interrupts.Names.TIM1_BRK_TIM9_Interrupt);

   end Break;

end AMC.PWM;
