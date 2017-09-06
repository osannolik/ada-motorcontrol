with Ada.Real_Time; use Ada.Real_Time;
--  with AMC_Types; use AMC_Types;
with AMC_UART;
with Serial_COBS;
with Communication;
with AMC_Board;
with AMC;
package body Logging is

   COBS   : aliased Serial_COBS.COBS_Stream;

   Serial : aliased AMC_UART.UART_Stream;

   Port   : aliased Communication.Port_Type;

   An_Interface : aliased Communication.Interface_Type;

   task body Logger is
      Period : constant Time_Span := Milliseconds (Config.Logger_Period_Ms);
      Next_Release : Time := Clock;
   begin

      loop
         exit when AMC.Is_Initialized;
         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;

      AMC_UART.Initialize_Default (Stream => Serial);

      COBS.Initialize (IO_Stream_Access => Serial'Access);

      Port.Initialize (IO_Stream_Access => COBS'Access);

      An_Interface.Initialize (Interface_Number => 3);

      Port.Attach_Interface (Interface_Obj     => An_Interface,
                             New_Data_Callback => null);

      loop

         AMC_Board.Turn_On (AMC_Board.Led_Red);

         Port.Receive_Handler;
         Port.Transmit_Handler;

         AMC_Board.Turn_Off (AMC_Board.Led_Red);

         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;
   end Logger;


   procedure Initialize
   is
   begin

      Initialized := True;

   end Initialize;

   function Is_Initialized
      return Boolean is (Initialized);

begin

   Initialize;

end Logging;
