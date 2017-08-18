with HAL;       use HAL;
with System;
with AMC_Types;
with Config;

with Generic_PO;

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





   package Dq_PO is new Generic_PO (AMC_Types.Dq);
   package Voltage_PO is new Generic_PO (AMC_Types.Voltage_V);

   subtype Dq_PO_Shared_With_CC is Dq_PO.Shared_Data(Config.Current_Control_Prio);
   --  Provides mutually exclusive access to a Dq type

   subtype Voltage_PO_Shared_With_CC is Voltage_PO.Shared_Data(Config.Current_Control_Prio);
   --  Provides mutually exclusive access to a Voltage_V type

   type Inverter_System_States is record
      Idq_CC_Request : Dq_PO_Shared_With_CC;
      --  Holds the Idq value that is used as set-point for the current controller

      Vbus : Voltage_PO_Shared_With_CC;
      --  DC bus voltage
   end record;
   --  Collects protected objects set by the Inverter_System task


   Inverter_System_Outputs : Inverter_System_States;
   --  Inverter_System task outputs

   Initialized : Boolean := False;






end AMC;
