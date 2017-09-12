with System;
with Ada.Exceptions; use Ada.Exceptions;

package Error_Handling is

   procedure Handler (Error : Exception_Occurrence);
   procedure Handler (Msg : System.Address; Line : Integer);
   --  Puts the hardware into a "safe" state and lights the red led.
   --  TODO: Dump data somewhere...



end Error_Handling;
