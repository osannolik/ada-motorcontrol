with Ada.Interrupts.Names;
with STM32.Timers;
with STM32.Device;
with STM32.GPIO;
--  with AMC_Types;
with AMC_Board;
with Config;

package AMC_Hall is
   --  @summary
   --  Hall Sensor
   --
   --  @description
   --  Interfaces peripherals used for hall sensor handling using common AMC types.
   --

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

   protected Handler is
      pragma Interrupt_Priority (Config.Hall_ISR_Prio);

   private

      procedure ISR with
        Attach_Handler => Ada.Interrupts.Names.TIM4_Interrupt;

   end Handler;

--     function Get_Angle return AMC_Types.Angle_Rad;
--     --  Get the angle related to mechanical rotations, i.e. it is not
--     --  compensated for the motor's pole pairs
--     --  @return Mechanical angle in radians.
--
--     function Get_Angle return AMC_Types.Angle_Deg;
--     --  Get the angle related to mechanical rotations, i.e. it is not
--     --  compensated for the motor's pole pairs
--     --  @return Mechanical angle in degrees.
--
--     function Get_Angle return AMC_Types.Angle;
--     --  Get the angle related to mechanical rotations, i.e. it is not
--     --  compensated for the motor's pole pairs
--     --  @return Mechanical angle object.
--
--     procedure Set_Angle (Angle : in AMC_Types.Angle_Rad);
--     --  Define the current sensor position as the specified angle.
--     --  @param Angle Set angle in radians.
--
--     function Get_Direction return Float;
--     --  @return 1.0 if forward, else -1.0

private

   Initialized : Boolean := False;

   Input_Pins : constant STM32.GPIO.GPIO_Points :=
      (AMC_Board.Hall_1_Pin, AMC_Board.Hall_2_Pin, AMC_Board.Hall_3_Pin);

   Hall_Timer : STM32.Timers.Timer renames STM32.Device.Timer_4;

end AMC_Hall;
