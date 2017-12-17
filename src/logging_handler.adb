with Ada.Real_Time; use Ada.Real_Time;
with AMC_UART;
with Serial_COBS;
with Communication;
with Calmeas;
--  with AMC_Board;
with AMC;

package body Logging_Handler is

   UART_COBS : aliased Serial_COBS.COBS_Stream;
   --  Instance of a COBS encoder/decoder

   Serial_COBS_Port : aliased Communication.Port_Type;
   --  Instant of a communication port

   task body Logger is
      Period : constant Time_Span := Milliseconds (Config.Logger_Period_Ms);
      Next_Release : Time := Clock;

      Comm_Cnt : Natural := Natural'First;
   begin

      loop
         exit when AMC.Is_Initialized;
         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;

      --  Make COBS encoder/decoder use the UART for data IO
      UART_COBS.Initialize
         (IO_Stream_Access => AMC_UART.Stream'Access);

      --  Attach the COBS-UART combination to the communication port
      Serial_COBS_Port.Initialize
         (IO_Stream_Access => UART_COBS'Access);

      --  Make Calmeas use the communication port for data IO
      Serial_COBS_Port.Attach_Interface
         (Interface_Obj     => Calmeas.Communication_Interface,
          New_Data_Callback => Calmeas.Callback_Handler'Access);

      loop
         --  AMC_Board.Turn_On (AMC_Board.Led_Red);

         --  Sample all variables (symbols) added to Calmeas and enabled via host gui
         Calmeas.Sample (To_Port => Serial_COBS_Port'Access);

         Comm_Cnt := Natural'Succ (Comm_Cnt);
         if Comm_Cnt >= 10 then
            Comm_Cnt := Natural'First;

            --  Transmit and receive data on the communication port
            Serial_COBS_Port.Receive_Handler;
            Serial_COBS_Port.Transmit_Handler;
         end if;

         --  AMC_Board.Turn_Off (AMC_Board.Led_Red);

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Logger;

end Logging_Handler;
