with AMC_Board;
with AMC;
with Ada.Text_IO;

package body Error_Handling is

   procedure Make_Safe;
   procedure Make_Safe is
   begin
      if not AMC_Board.Is_Initialized then
         AMC_Board.Initialize;
      end if;

      --  Signal error to the user
      AMC_Board.Turn_On (Led => AMC_Board.Led_Red);
      AMC_Board.Turn_Off (Led => AMC_Board.Led_Green);

      --  Force the gate driver into a safe state
      AMC.Safe_State;
   end Make_Safe;

   procedure Handler (Msg : System.Address; Line : Integer) is
      pragma Unreferenced (Msg, Line);
   begin
      Make_Safe;
   end Handler;

   procedure Handler (Error : Exception_Occurrence) is
      Name : constant String := Exception_Name (Error);
   begin
      Make_Safe;
      Ada.Text_IO.Put_Line (Name);
   end Handler;


end Error_Handling;
