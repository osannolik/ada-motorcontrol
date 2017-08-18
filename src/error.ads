with System;

package Error is

   procedure Handler (Msg : System.Address; Line : Integer);
   --  Puts the hardware into a "safe" state and lights the red led.
   --  TODO: Dump data somewhere...

end Error;
