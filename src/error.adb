with AMC_Board;
with AMC_PWM;
with AMC;

package body Error is

   procedure Handler (Msg : System.Address; Line : Integer) is
      pragma Unreferenced (Msg, Line);
   begin
      if not AMC_Board.Is_Initialized then
         AMC_Board.Initialize;
      end if;

      -- Signal error to the user
      AMC_Board.Turn_On (Led => AMC_Board.Led_Red);
      AMC_Board.Turn_Off (Led => AMC_Board.Led_Green);

      --  Force the gate driver into a safe state
      AMC.Safe_State;
   end Handler;

end Error;
