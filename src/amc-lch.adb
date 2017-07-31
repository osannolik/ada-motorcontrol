with AMC.Board;

package body AMC.LCH is

   procedure Handler (Msg : System.Address; Line : Integer) is
      pragma Unreferenced (Msg, Line);
   begin
      if not AMC.Board.Is_Initialized then
         AMC.Board.Initialize;
      end if;

      AMC.Board.Set_Gate_Driver_Power (Enabled => False);
      AMC.Board.Turn_On (Led => AMC.Board.Led_Red);
      AMC.Board.Turn_Off (Led => AMC.Board.Led_Green);
   end Handler;

end AMC.LCH;
