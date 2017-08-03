with AMC.Types;
with STM32.GPIO;
with STM32.Timers;
with STM32.PWM;
with Ada.Interrupts.Names;

package AMC.PWM is
   --  Pulse width modulation
   --  Interfaces the mcu pwm peripheral

   type Gates is (Gate_A, Gate_B, Gate_C,
                  Sample_Trigger);

   type Pulse_Alignment is (Edge, Center);

   type Gate is record
      Channel   : STM32.Timers.Timer_Channel;
      Modulator : STM32.PWM.PWM_Modulator;
   end record;

   type Gates_Array is array (Gates'Range) of Gate;

   type Object is tagged limited record
      Generator      : access STM32.Timers.Timer;
      Gates          : Gates_Array;
      Initialized    : Boolean := False;
   end record;

   function Is_Initialized (This : Object)
      return Boolean;

   procedure Initialize_Gate
      (This       : in out Object;
       Gate       : Gates;
       Channel    : STM32.Timers.Timer_Channel;
       Pin_H      : STM32.GPIO.GPIO_Point;
       Pin_L      : STM32.GPIO.GPIO_Point;
       Pin_AF     : STM32.GPIO_Alternate_Function;
       Polarity   : STM32.Timers.Timer_Output_Compare_Polarity
          := STM32.Timers.High;
       Idle_State : STM32.Timers.Timer_Capture_Compare_State
          := STM32.Timers.Disable);

   procedure Initialize_Gate
      (This       : in out Object;
       Gate       : Gates;
       Channel    : STM32.Timers.Timer_Channel;
       Polarity   : STM32.Timers.Timer_Output_Compare_Polarity
          := STM32.Timers.High;
       Idle_State : STM32.Timers.Timer_Capture_Compare_State
          := STM32.Timers.Disable);

   procedure Initialize
      (This      : in out Object;
       Generator : not null access STM32.Timers.Timer;
       Frequency : AMC.Types.Frequency_Hz;
       Deadtime  : AMC.Types.Seconds;
       Alignment : Pulse_Alignment);

   procedure Enable
      (This : in out Object;
       Gate : Gates);

   procedure Disable
      (This : in out Object;
       Gate : Gates);

   procedure Set_Duty_Cycle
      (This  : in out Object;
       Gate  : Gates;
       Value : AMC.Types.Duty_Cycle);

   procedure Generate_Break_Event (This : Object);
   --  Sets the pwm outputs to an inactive state, e.g. all low.

private

   protected Break is
      pragma Interrupt_Priority;

   private

      procedure Break_ISR;
      pragma Attach_Handler (Break_ISR, Ada.Interrupts.Names.TIM1_BRK_TIM9_Interrupt);

   end Break;

end AMC.PWM;
