with Config;

package Logging is
   --  Handles logging utilities

   procedure Initialize;
   --  Initialization to be performed during elaboration

   function Is_Initialized
     return Boolean;

   task Logger with
      Priority => Config.Logger_Prio,
      Storage_Size => (4 * 1024);

private

   Initialized : Boolean := False;

end Logging;
