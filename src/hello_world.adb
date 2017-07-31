with Ada.Real_Time; use Ada.Real_Time;

with STM32.GPIO;    use STM32.GPIO;
with STM32.Device;  use STM32.Device;

with AMC;
with AMC.Board;

package body Hello_World is

   task body Blinker is
      Period       : constant Time_Span := Milliseconds (500);
      Next_Release : Time := Clock;
      err : Boolean := False;
   begin

      AMC.Initialize;
      AMC.Board.Turn_On (AMC.Board.Led_Red);

      loop

         if AMC.Board.Is_Pressed (AMC.Board.User_Button) then
            AMC.Board.Toggle (AMC.Board.Led_Green);
         else
            AMC.Board.Toggle (AMC.Board.Led_Red);
         end if;

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Blinker;

end Hello_World;
