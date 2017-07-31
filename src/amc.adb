with AMC.Board;

pragma Elaborate(AMC.Board);

package body AMC is

   Initialized : Boolean := False;

   procedure Initialize;
   --  Initialization to be performed during elaboration

   procedure Initialize
   is
   begin
      AMC.Board.Initialize;

      Initialized := AMC.Board.Is_Initialized;
                     --  and AMC.Child.Is_initialized;
   end Initialize;

   function Is_Initialized
      return Boolean is (Initialized);

begin

   Initialize;

end AMC;
