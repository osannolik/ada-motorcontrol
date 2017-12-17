with Config;

package Logging_Handler is
   --  @summary
   --  Logging
   --
   --  @description
   --  This package contain features for logging data. It includes a task responsible
   --  for collecting data of interest and to send it to a specified IO.
   --  It calls the Calmeas package that will buffer the values of logged variables.
   --  The task then calls the communication stack as to send the logged data and to
   --  check for received data (e.g. requests to change value of a variable,
   --  or set the Calmeas sample rate).
   --  Here you could also add logging to other media, for example Bluetooth, CAN or SD.
   --

   task Logger with
      Priority => Config.Logger_Prio,
      Storage_Size => (8 * 1024);

end Logging_Handler;
