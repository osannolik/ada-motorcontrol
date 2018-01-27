with AMC_Types;
with Config;
with AMC_Board;
with STM32.Timers;
with Ada.Interrupts.Names;

package AMC_WDG is
   --  @summary
   --  Watchdog
   --
   --  @description
   --  Interfaces the a microcontroller watchdog peripheral using common AMC types.
   --

   procedure Initialize (Period    : AMC_Types.Seconds;
                         Tolerance : AMC_Types.Seconds)
      with Pre => not Is_Initialized;

   function Is_Initialized return Boolean;
   --  @return True if initialized.

   procedure Activate
      with Pre => Is_Initialized;

   function Is_Activated return Boolean;
   --  @return True if activated

   procedure Refresh;

private

   protected Refresher is
      pragma Interrupt_Priority (Config.Wdg_ISR_Prio);

      procedure Set_Counter (Val : in Natural);
   private

      procedure ISR with
        Attach_Handler => Ada.Interrupts.Names.TIM6_DAC_Interrupt;

      Counter   : Natural := 0;
      Timed_Out : Boolean := False;

   end Refresher;

   Initialized : Boolean := False;
   Activated   : Boolean := False; -- TODO: Check with peripheral registers...

   Refresh_Timer : STM32.Timers.Timer renames AMC_Board.Wdg_Timer;

end AMC_WDG;
