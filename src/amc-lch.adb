with AMC.Board;
with AMC.PWM;

package body AMC.LCH is

   procedure Handler (Msg : System.Address; Line : Integer) is
      pragma Unreferenced (Msg, Line);
   begin
      if not AMC.Board.Is_Initialized then
         AMC.Board.Initialize;
      end if;

      --  Force the gate driver into a safe state
      AMC.Safe_State;

      -- Signal error to the user
      AMC.Board.Turn_On (Led => AMC.Board.Led_Red);
      AMC.Board.Turn_Off (Led => AMC.Board.Led_Green);
   end Handler;

end AMC.LCH;
