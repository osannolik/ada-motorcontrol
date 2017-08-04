with Ada.Real_Time; use Ada.Real_Time;

with STM32.GPIO;    use STM32.GPIO;
with STM32.Device;  use STM32.Device;

with AMC.Board;
with AMC.PWM;
with AMC.ADC;
with HAL; use HAL;

with ADA.Text_IO;
with STM32.DMA;

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

         --  AMC.Board.Set_Gate_Driver_Power
         --    (Enabled => AMC.Board.Is_Pressed (AMC.Board.User_Button));

         for I in 1..8 loop
            Data(I) := AMC.ADC.Get_Data_Test(I);
         end loop;

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

      --  Period       : constant Time_Span := Milliseconds (100);
      --  Next_Release : Time := Clock;

      Event_Kind : STM32.DMA.DMA_Interrupt;
      Dummy_Stuff : Boolean := False;
   begin
      loop

         AMC.ADC.IRQ_Handler.Await_Event (Occurrence => Event_Kind);

         AMC.Board.Toggle (AMC.Board.Led_Red);

      end loop;
   end Sampler;

end Hello_World;
