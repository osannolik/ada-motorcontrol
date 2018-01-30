package Watchdog.Manager is
   --  @summary
   --  Watchdog task
   --
   --  @description
   --  ...
   --

   Failed_Watchdog_Init : Exception;

   Base_Period_Ms : constant Positive := Config.Watchdog_Manager_Period_Ms;

   task Watchdog_Manager with
      Priority => Config.Watchdog_Prio,
      Storage_Size => 1024;

   procedure Refresh;

   Instance : Watchdog_Type;

end Watchdog.Manager;
