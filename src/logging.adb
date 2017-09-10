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


      Port.Attach_Interface (Interface_Obj     => Calmeas.Communication_Interface,
                             New_Data_Callback => Calmeas.Callback_Handler'Access);


      Calmeas.Add (Symbol => My_Crap'Access,
                   Name   => "My_Foo_Ab");

      Calmeas.Add (Symbol => My_Crap_2'Access,
                   Name   => "My_Bar_Cd");

      Calmeas.Add (Symbol => My_Crap_3'Access,
                   Name   => "My_Goo_Ef");

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
