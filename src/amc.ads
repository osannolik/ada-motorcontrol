with HAL;       use HAL;
with System;

package AMC is
   --  Ada Motor Controller

   procedure Initialize;
   --  Initialization to be performed during elaboration

   function Is_Initialized
     return Boolean;

   procedure Safe_State;

   task Inverter_System with
      Storage_Size => (4 * 1024);

   task Sampler with
      Priority => System.Priority'Last,
      Storage_Size => (4 * 1024);

private
   Initialized : Boolean := False;
end AMC;
