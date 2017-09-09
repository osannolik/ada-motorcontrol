with Ada.Real_Time; use Ada.Real_Time;
with AMC_Types; use AMC_Types;
with AMC_UART;
with Serial_COBS;
with Communication;
with Calmeas;
with AMC_Board;
with AMC;
with System;

package body Logging is

   My_Crap : aliased AMC_Types.UInt8 := 200;

   My_Crap_2 : aliased AMC_Types.Int16 := 100;

   My_Crap_3 : aliased Float := 1337.1337;

   COBS   : aliased Serial_COBS.COBS_Stream;



   Port   : aliased Communication.Port_Type;

   An_Interface : aliased Communication.Interface_Type;

   task body Logger is
      Period : constant Time_Span := Milliseconds (Config.Logger_Period_Ms);
      Next_Release : Time := Clock;

      Addr_Of_My_Crap : System.Address := My_Crap'Address;
      pragma Unreferenced (Addr_Of_My_Crap);
   begin

      loop
         exit when AMC.Is_Initialized;
         Next_Release := Next_Release + Period;
         delay until Next_Release;
      end loop;


      COBS.Initialize (IO_Stream_Access => AMC_UART.Stream'Access);

      Port.Initialize (IO_Stream_Access => COBS'Access);

      An_Interface.Initialize (Interface_Number => 3);

      Port.Attach_Interface (Interface_Obj     => An_Interface,
                             New_Data_Callback => null);




      Calmeas.Add (Symbol => My_Crap'Access,
                   Name   => "My_Crap");

      Calmeas.Add (Symbol => My_Crap_2'Access,
                   Name   => "My_Crap_2");

      Calmeas.Add (Symbol => My_Crap_3'Access,
                   Name   => "My_Crap_3");

      declare
         B : constant Byte_Array := Calmeas.Get_Symbol_Value (0);
         B2 : constant Byte_Array := Calmeas.Get_Symbol_Value (1);
         B3 : constant Byte_Array := Calmeas.Get_Symbol_Value (2);
         pragma Unreferenced (B, B2, B3);
      begin
         null;
      end;


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
