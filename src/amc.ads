with HAL;       use HAL;
with System;
with AMC_Types;

private with Generic_PO;

package AMC is
   --  Ada Motor Controller

   ADC_ISR_Prio : constant System.Interrupt_Priority := System.Interrupt_Priority'Last;
   Current_Control_Prio : constant System.Priority := System.Priority'Last;
   Inverter_System_Prio : constant System.Priority := System.Priority'Last - 2;

   procedure Initialize;
   --  Initialization to be performed during elaboration

   function Is_Initialized
     return Boolean;

   procedure Safe_State;

   task Inverter_System with
      Priority => Inverter_System_Prio,
      Storage_Size => (4 * 1024);

   task Current_Control with
      Priority => Current_Control_Prio,
      Storage_Size => (4 * 1024);

private

   package Idq_PO is new Generic_PO (AMC_Types.Idq);

   type Idq_PO_Shared_With_CC is new Idq_PO.Shared_Data(Current_Control_Prio);
   --  Provides mutually exclusive access to an Idq type

   type Inverter_System_States is record
      Idq_CC_Request : Idq_PO_Shared_With_CC;
      --  Holds the Idq value that is used as set-point for the current controller
   end record;
   --  Collects protected objects set by the Inverter_System task

   Inverter_System_Outputs : Inverter_System_States;
   --  Inverter_System task outputs


   Initialized : Boolean := False;
end AMC;
