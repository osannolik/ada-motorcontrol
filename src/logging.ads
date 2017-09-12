with Config;

package Logging is
   --  Handles logging utilities

   task Logger with
      Priority => Config.Logger_Prio,
      Storage_Size => (8 * 1024);

end Logging;
