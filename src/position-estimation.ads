package Position.Estimation is
   --  @summary
   --  Estimate/filter rotor angle and speed
   --
   --  @description
   --  Based on raw sensor data, try to estimate the actual rotor state.
   --

   --  Defines a dead zone around 0 rpm.
   --  Estimation does currently not work very well at low rpm...
   Hall_Speed_Estimate_Min : constant Speed_Eradps := 70.0;

   task Hall_Handler with
      Priority => Config.Hall_Handler_Prio,
      Storage_Size => (2 * 1024);

   procedure Angle_Update (Delta_T : in Seconds);
   --  Run the angle estimation.
   --  @param Delta_T The time since last call to this subprogram

   function Get_Angle return Angle_Erad;
   --  @return The estimated rotor angle.

   function Get_Speed return Speed_Eradps;
   --  @return The estimated rotor speed.

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
