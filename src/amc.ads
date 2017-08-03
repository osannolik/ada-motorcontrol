with HAL;       use HAL;

package AMC is
   --  Ada Motor Controller

   procedure Initialize;
   --  Initialization to be performed during elaboration

   function Is_Initialized
     return Boolean;

   procedure Safe_State;

private
   Initialized : Boolean := False;
end AMC;
