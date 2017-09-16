with System;
with Ada.Exceptions; use Ada.Exceptions;

package Error_Handling is
   --  @summary
   --  Error Handling
   --
   --  @description
   --  Contains handlers that are called by the last change handler, e.g. when
   --  unhandled exceptions occur.
   --  Actions could include dumping the stack trace and variables of interest
   --  to non-volatile memory.
   --

   procedure Handler (Error : Exception_Occurrence);
   --  A handler that could be used when using the Ravenscar Full profile.
   --  The exception name is dumped to the semi-host handler and the inverter is
   --  forced into a safe state.
   --  @param Error The causing exception

   procedure Handler (Msg : System.Address; Line : Integer);
   --  A handler that could be used when using the Ravenscar SFP profile.
   --  The inverter is forced into a safe state.
   --  @param Msg Address of error occurence
   --  @param Line The line of error occurence

end Error_Handling;
