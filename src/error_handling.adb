with AMC_Board;
with Ada.Text_IO;
with Watchdog.Manager;
with Ada.Real_Time;

package body Error_Handling is

   procedure Make_Safe is
   begin
      if not AMC_Board.Is_Initialized then
         AMC_Board.Initialize;
      end if;

      --  Signal error to the user
      AMC_Board.Turn_On (Led => AMC_Board.Led_Red);
      AMC_Board.Turn_Off (Led => AMC_Board.Led_Green);

      --  Force the gate driver into a safe state
      AMC_Board.Safe_State;
   end Make_Safe;

   procedure Handler is
      use Ada.Real_Time;
   begin
      Make_Safe;
      loop
         Watchdog.Manager.Refresh; -- Keep the board alive
         delay until Clock + Milliseconds (Watchdog.Manager.Base_Period_Ms);
      end loop;
   end Handler;

   procedure Handler (Msg : System.Address; Line : Integer) is
      pragma Unreferenced (Msg, Line);
   begin
      Handler;
   end Handler;

   procedure Handler (Error : Exception_Occurrence) is
      Name : constant String := Exception_Name (Error);
   begin
      Ada.Text_IO.Put_Line (Name);
      Handler;
   end Handler;


end Error_Handling;
