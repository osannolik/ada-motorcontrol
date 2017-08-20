with Generic_PO;
with AMC_Types; use AMC_Types;
with Config;

package AMC is
   --  Ada Motor Controller

   procedure Initialize;
   --  Initialization to be performed during elaboration

   function Is_Initialized
     return Boolean;

   procedure Safe_State;

   task Inverter_System with
      Priority => Config.Inverter_System_Prio,
      Storage_Size => (4 * 1024);


   --  Collects protected objects set by the Inverter_System task
   type Inverter_System_States is record
      Idq_CC_Request : Dq;
      --  Holds the Idq value that is used as set-point for the current controller

      Vbus : Voltage_V;
      --  DC bus voltage

      Alignment_Angle : Angle_Erad;
      --  In Alignment mode, the current controller aligns rotor to this angle

      Mode : Ctrl_Mode;
      --  Holds the current control mode
   end record;

   package System_States_PO_Pack is new Generic_PO (Inverter_System_States);

   subtype Inverter_Output is
      System_States_PO_Pack.Shared_Data (Config.Protected_Object_Prio);

   Inverter_System_Outputs : Inverter_Output;
   --  Inverter_System task outputs

private

   Initialized : Boolean := False;

end AMC;
