with AMC_Types;

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

   Initialized : Boolean := False;
   Activated   : Boolean := False; -- TODO: Check with peripheral registers...

end AMC_WDG;
