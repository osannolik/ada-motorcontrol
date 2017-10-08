with Ada.Interrupts.Names;
with HAL;
with STM32.Timers;
with STM32.Device;
with STM32.GPIO;
with AMC_Types;
with AMC_Board;
with Config;

package AMC_Hall is
   --  @summary
   --  Hall Sensor
   --
   --  @description
   --  Interfaces peripherals used for hall sensor handling using common AMC types.
   --

   subtype Hall_Bits is HAL.UInt3;

   subtype Valid_Hall_Bits is Hall_Bits range 1 .. 6;

   Nof_Valid_Hall_States : constant Positive := 6;

   type Hall_Pattern (As_Pattern : Boolean := True) is
      record
         case As_Pattern is
            when True =>
               Bits : Hall_Bits;
            when False =>
               H1 : Boolean;
               H2 : Boolean;
               H3 : Boolean;
         end case;
      end record with Unchecked_Union, Size => Hall_Bits'Size;

   for Hall_Pattern use record
      Bits at 0 range 0 .. 2;
      H1      at 0 range 0 .. 0;
      H2      at 0 range 1 .. 1;
      H3      at 0 range 2 .. 2;
   end record;

   type Hall_State is record
      Current  : Hall_Pattern;
      Previous : Hall_Pattern;
   end record;

   function Is_Initialized return Boolean;
   --  @return True if initialized.

   procedure Initialize;
   --  Initialize hall, i.e. timer peripheral.
   --
   --  Initialize TIM4 peripheral as follows:
   --
   --   - Hall sensor inputs are connected to Ch1, Ch2, and Ch3.
   --   - TI1 is xor of all three channels.
   --   - Input capture IC1 is configured to capture at both edges of TI1.
   --   - TI1F_ED = TI1 is set to trigger a reset of the timer.
   --   - OC2 is configured to create a pulse delayed from the TRC = TI1F_ED event.
   --   - Interrupt at input capture and delayed pulse event.
   --
   --  This way it is possible to measure the time between two consecutive
   --  hall sensor changes and thus to estimate the speed of the motor.
   --  Also, it is possible to trigger the commutation of the BLDC based on
   --  the IC (or delayed pulse) interrupt.
   --
   --  Configuration:
   --  APB1 is the clock source = 2*APB1 (2*45 MHz)
   --  Using a prescaler of 225 and using all 16 bits yields:
   --   - Resolution = 225 / 90 MHz = 2.5 us
   --   - Time until overflow = 2^16 * 225 / 90 MHz = 0.16384 s
   --  This allows for a speed down to 61 rpm before an overflow occurs.
   --  At 10000 rpm, the resolution will be approx 2.5 us * (10000^2)/10 = 25 rpm
   --


   function Is_Standstill return Boolean;

   protected State is
      pragma Interrupt_Priority (Config.Hall_ISR_Prio);

      entry Await_New (New_State    : out Hall_State;
                       Time_Delta_s : out AMC_Types.Seconds);
      --  Suspend the caller and wake it up again as soon as the hall sensor changes state.
      --  @param New_State New State.
      --  @param Time_Delta_s Time since previous state change. If the timer has overflowed,
      --  then this is set to 0 s.

      function Get return Hall_State;

      procedure Update;

      procedure Set_Commutation_Delay_Factor (Factor : AMC_Types.Percent);

      function Overflow return Boolean;

   private

      procedure ISR with
        Attach_Handler => Ada.Interrupts.Names.TIM4_Interrupt;

      Hall_State_Is_Updated : Boolean := False;
      --  True when hall sensor has changed state

      Capture_Overflow : Boolean := True;
      --  True when speed timer has overflowed, i.e. very slow rotation

      State : Hall_State;
      --  Holds the state of the hall sensor

      Delay_Factor : Float range 0.0 .. 1.0 := 0.0;
      --  Time for commutation will be this Factor times the time since last state change

      Speed_Timer_Counter : AMC_Types.UInt32 := 0;
      --  Timer counts since last hall state change

   end State;

   protected Commutation is
      pragma Interrupt_Priority (Config.Hall_ISR_Prio);

      entry Await_Commutation;
      --  Suspend the caller and wake it up again as soon as commutation shall occur.
      --  Nominally, the time for this commutation is the time since last hall state change plus
      --  Time_Delta_s * Commutation_Delay_Factor,
      --  i.e. if factor is 0.5 then commutation is halfway between two hall state changes
      --  (assuming constant speed).
      --  @param Current_State The hall state.

      procedure Manual_Trigger;

   private

      procedure ISR with
        Attach_Handler => Ada.Interrupts.Names.TIM3_Interrupt;

      Is_Commutation : Boolean := False;
      --  True when commutation event occurs

   end Commutation;

private

   Prescaler : constant AMC_Types.UInt16 := 225;

   Initialized : Boolean := False;

   H1_Pin : STM32.GPIO.GPIO_Point renames AMC_Board.Hall_1_Pin;
   H2_Pin : STM32.GPIO.GPIO_Point renames AMC_Board.Hall_2_Pin;
   H3_Pin : STM32.GPIO.GPIO_Point renames AMC_Board.Hall_3_Pin;

   Input_Pins : constant STM32.GPIO.GPIO_Points := (H1_Pin, H2_Pin, H3_Pin);

   Hall_Timer : STM32.Timers.Timer renames STM32.Device.Timer_4;

   Commutation_Timer : STM32.Timers.Timer renames STM32.Device.Timer_3;

end AMC_Hall;
