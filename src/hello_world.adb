with Ada.Real_Time; use Ada.Real_Time;

with STM32.GPIO;    use STM32.GPIO;
with STM32.Device;  use STM32.Device;

with AMC.Board;
with AMC.PWM;
with AMC.ADC;
with HAL; use HAL;

with ADA.Text_IO;

package body Hello_World is

   task body Blinker is
      Period       : constant Time_Span := Milliseconds (100);
      Next_Release : Time := Clock;

      Data : array(1..8) of UInt16 := (others => 0);
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

--           for I in 1..8 loop
--              Data(I) := AMC.ADC.Get_Data_Test(I);
--           end loop;

         --  ADA.Text_IO.Put_Line(Data'Img);

         if AMC.Board.Is_Pressed (AMC.Board.User_Button) then
            --  AMC.Board.Turn_On (AMC.Board.Led_Red);
            --  AMC.Board.Turn_Off (AMC.Board.Led_Green);
            null;
         else
            --  AMC.Board.Turn_Off (AMC.Board.Led_Red);
            --  AMC.Board.Turn_On (AMC.Board.Led_Green);
            null;
         end if;

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Blinker;

   task body Sampler is
      Dummy_Stuff : Boolean := False;
      Samples : AMC.ADC.Injected_Samples_Array := (others => 0);
      Bat_Sense_Data : UInt16 := 0;
      Board_Temp_Data : UInt16 := 0;
   begin
      loop
         AMC.ADC.Handler.Await_New_Samples (Injected_Samples => Samples);

         AMC.Board.Turn_Off (AMC.Board.Led_Green);

         Bat_Sense_Data := AMC.ADC.Get_Sample (AMC.ADC.Bat_Sense);
         Board_Temp_Data := AMC.ADC.Get_Sample (AMC.ADC.Board_Temp);

         Dummy_Stuff := not Dummy_Stuff;

      end loop;
   end Sampler;

end Hello_World;
