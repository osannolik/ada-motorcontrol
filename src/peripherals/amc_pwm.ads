with STM32.GPIO;
with STM32.Timers;
with STM32.PWM;
with Ada.Interrupts.Names;
with AMC_Types;
with AMC_Board;

package AMC_PWM is
   --  @summary
   --  Pulse Width Modulation
   --
   --  @description
   --  Interfaces the microcontroller's PWM peripheral using common AMC types.
   --

   function Is_Initialized
      return Boolean;
   --  @return True when initialized.

   procedure Initialize
      (Frequency : AMC_Types.Frequency_Hz;
       Deadtime  : AMC_Types.Seconds;
       Alignment : AMC_Types.PWM_Alignment);
   --  Initialize the peripheral.
   --  Each phase need to be enabled manually after this.
   --  @param Frequency Switching frequency.
   --  @param Deadtime If complementary switching is used, sets the deadtime.
   --  @param Alignment Aslignment of PWM waveforms.

   procedure Enable
      (Phase : AMC_Types.Phase);
   --  Enable PWM generation for the specified phase.
   --  @param Phase The specified phase.

   procedure Disable
      (Phase : AMC_Types.Phase);
   --  Disable PWM generation for the specified phase.
   --  @param Phase The specified phase.

   function Get_Duty_Resolution
      return AMC_Types.Duty_Cycle;
   --  @return The minimum step that the duty can be changed, in percent.

   procedure Set_Duty_Cycle
      (Phase : AMC_Types.Phase;
       Value : AMC_Types.Duty_Cycle);
   --  Sets the duty cycle for the specified Phase.
   --  @param Phase The specified phase.
   --  @param Value The duty cycle percentage 0-100.

   procedure Set_Duty_Cycle
      (Dabc : AMC_Types.Abc);
   --  Sets the duty cycle for all phases.
   --  @param Dabc Duty cycle percentages 0-100.

   procedure Set_Trigger_Cycle
      (Value : AMC_Types.Duty_Cycle);
   --  Sets where over the PWM cycle the trigger shall occur. Trigger occurs at
   --  the positive edge of the waveform. Setting this to 0 disables the triggering.
   --  @param Value Duty cycle defined the same way as for the phase duty.

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

   PWM_Timer_Ref : access STM32.Timers.Timer := AMC_Board.PWM_Timer'Access;

   Modulators : array (AMC_Types.Phase'Range) of STM32.PWM.PWM_Modulator;

   Gate_Phase_Settings : constant Gate_Settings :=
      ((AMC_Types.A) => Gate_Setting'(Channel => AMC_Board.PWM_Gate_A_Ch,
                                      Pin_H   => AMC_Board.PWM_Gate_H_A_Pin,
                                      Pin_L   => AMC_Board.PWM_Gate_L_A_Pin,
                                      Pin_AF  => AMC_Board.PWM_Gate_GPIO_AF),
       (AMC_Types.B) => Gate_Setting'(Channel => AMC_Board.PWM_Gate_B_Ch,
                                      Pin_H   => AMC_Board.PWM_Gate_H_B_Pin,
                                      Pin_L   => AMC_Board.PWM_Gate_L_B_Pin,
                                      Pin_AF  => AMC_Board.PWM_Gate_GPIO_AF),
       (AMC_Types.C) => Gate_Setting'(Channel => AMC_Board.PWM_Gate_C_Ch,
                                      Pin_H   => AMC_Board.PWM_Gate_H_C_Pin,
                                      Pin_L   => AMC_Board.PWM_Gate_L_C_Pin,
                                      Pin_AF  => AMC_Board.PWM_Gate_GPIO_AF));

   Trigger_Modulator : STM32.PWM.PWM_Modulator;

   Trigger_Channel : constant STM32.Timers.Timer_Channel :=
      AMC_Board.PWM_Trigger_Ch;


   protected Break is
      pragma Interrupt_Priority;

   private

      procedure Break_ISR;
      pragma Attach_Handler (Break_ISR, Ada.Interrupts.Names.TIM1_BRK_TIM9_Interrupt);

   end Break;

end AMC_PWM;
