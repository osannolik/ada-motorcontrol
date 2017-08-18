with AMC_Types_PO;
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
      Idq_CC_Request : AMC_Types_PO.Dq_PO;
      --  Holds the Idq value that is used as set-point for the current controller

      Vbus : AMC_Types_PO.Voltage_PO;
      --  DC bus voltage
   end record;


   Inverter_System_Outputs : Inverter_System_States;
   --  Inverter_System task outputs

private

   Initialized : Boolean := False;

end AMC;
