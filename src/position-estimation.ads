package Position.Estimation is
   --  @summary
   --  Estimate/filter rotor angle and speed
   --
   --  @description
   --

   task Hall_Handler with
      Priority => Config.Hall_Handler_Prio,
      Storage_Size => (4 * 1024);

   procedure Angle_Update (Delta_T : in Seconds);

   function Get_Angle return Angle_Erad;

private

   type Hall_Angle_Estimation_Data is record
      Angle_Est : Angle_Erad := 0.0;
   end record;

   package Hall_Angle_Estimation_PO_Pack is new Generic_PO (Hall_Angle_Estimation_Data);

   type Hall_Speed_Estimation_Data is record
      Speed_Est : Speed_Eradps := 0.0;
   end record;

   package Hall_Speed_Estimation_PO_Pack is new Generic_PO (Hall_Speed_Estimation_Data);

   Hall_Angle_Est_Data : Hall_Angle_Estimation_PO_Pack.Shared_Data (Config.Protected_Object_Prio);

   Hall_Speed_Est_Data : Hall_Speed_Estimation_PO_Pack.Shared_Data (Config.Protected_Object_Prio);

end Position.Estimation;
