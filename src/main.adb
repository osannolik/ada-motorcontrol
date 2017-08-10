with Last_Chance_Handler;  pragma Unreferenced (Last_Chance_Handler);
--  The "last chance handler" is the user-defined routine that is called when
--  an exception is propagated. We need it in the executable, therefore it
--  must be somewhere in the closure of the context clauses.

with System;

with AMC; pragma Unreferenced (AMC);

procedure Main is
   pragma Priority (System.Priority'First);
begin

   --  AMC.Initialize;

   loop
      null;
   end loop;

end Main;
