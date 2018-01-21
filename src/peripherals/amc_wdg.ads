with AMC_Types;

package AMC_WDG is
   --  @summary
   --  Watchdog
   --
   --  @description
   --  Interfaces the a microcontroller watchdog peripheral using common AMC types.
   --

   procedure Initialize (Nominal_Period : AMC_Types.Seconds;
                         Tolerance      : AMC_Types.Seconds)
     with Pre => Is_Initialized;

   function Is_Initialized return Boolean;
   --  @return True if initialized.

   procedure Activate
     with Pre => Is_Initialized;

   procedure Refresh;

private

   Initialized : Boolean := False;

end AMC_WDG;
