with Ada.Real_Time; use Ada.Real_Time;

with STM32.GPIO;    use STM32.GPIO;
with STM32.Device;  use STM32.Device;

with AMC.Board;
with AMC.PWM;

package body Hello_World is

   task body Blinker is
      Period       : constant Time_Span := Milliseconds (100);
      Next_Release : Time := Clock;
   begin

--        while not AMC.Is_Initialized loop
--           Next_Release := Next_Release + Period;
--           delay until Next_Release;
--        end loop;

      AMC.Board.Turn_Off (AMC.Board.Led_Red);
      AMC.Board.Turn_Off (AMC.Board.Led_Green);

      loop

         AMC.Board.Set_Gate_Driver_Power
           (Enabled => AMC.Board.Is_Pressed (AMC.Board.User_Button));

         if AMC.Board.Is_Pressed (AMC.Board.User_Button) then
            AMC.Board.Turn_On (AMC.Board.Led_Red);
            AMC.Board.Turn_Off (AMC.Board.Led_Green);

            AMC.PWM.Generate_Break_Event;

         else
            AMC.Board.Turn_Off (AMC.Board.Led_Red);
            AMC.Board.Turn_On (AMC.Board.Led_Green);
         end if;

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Blinker;

end Hello_World;
