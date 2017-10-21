package Position.Estimation is
   --  @summary
   --  Estimate/filter rotor angle and speed
   --
   --  @description
   --

   task Hall_Handler with
      Priority => Config.Hall_Handler_Prio,
      Storage_Size => (2 * 1024);

end Position.Estimation;
