with System;
with HAL; use HAL;
with AMC_Types; use AMC_Types;
with Byte_Queue;
with Config;
with Stream_Interface;

package Communication is

   type Port_Type is tagged limited private;

   subtype Data_Size_Type is AMC_Types.UInt16;

   subtype Interface_Number_Type is HAL.UInt4;
   subtype Identifier_Type is HAL.UInt4;




   type Interface_Type is tagged limited record
      Interface_Number : Interface_Number_Type;
      --  Callbacks...
   end record;


   procedure Initialize (Interface_Obj    : access Interface_Type'Class;
                         Interface_Number : in Interface_Number_Type);

   procedure Initialize (Port             : access Port_Type;
                         IO_Stream_Access : in Stream_Interface.Base_Stream_Access);

   procedure Attach_Interface (Port          : in out Port_Type;
                               Interface_Obj : in out Interface_Type'Class);

   procedure Send (Interface_Obj : access Interface_Type'Class;
                   Port          : access Port_Type;
                   Identifier    : in Identifier_Type;
                   Data          : in Byte_Array);

   procedure Put (Port             : access Port_Type;
                  Interface_Number : in Interface_Number_Type;
                  Identifier       : in Identifier_Type;
                  Data             : in Byte_Array);

   procedure Transmit_Handler (Port : in out Port_Type);


--     Calmeas.Initialize (Interface_Number = , Callback =);
--
--     Serial.Attach_Stream (Stream = );
--     Serial.Attach_Interface (Calmes);
--
--     Calmeas.Put (Serial, Id, Data)

private

   type Parser_State_Type is (Wait_For_Start,
                              Get_Header,
                              Get_Size_1,
                              Get_Size_2,
                              Get_Data,
                              Calc_Crc);


   Data_Length_Max : constant Natural := Natural (Data_Size_Type'Last - 1);

   Header_Byte_Length : constant Positive := 4;

   Packet_Start : constant AMC_Types.UInt8 := 16#73#;  --  's'

   subtype Buffer_Index is Natural range 0 .. Data_Length_Max;

   type Port_Type is tagged limited record
      Stream         : Stream_Interface.Base_Stream_Access;

      Tx_Queue       : Byte_Queue.Protected_Queue (Config.Protected_Object_Prio);
      Buffer_Rx_Data : aliased Byte_Array (Buffer_Index'Range);

      Parser_State   : Parser_State_Type := Wait_For_Start;

      --  Callbacks : array (Interface_Number_Type'Range) of callback...
   end record;

   type Status_Type is record
      Interface_Number : Interface_Number_Type := 16#0#;
      Identifier       : Identifier_Type := 16#0#;
   end record
      with Size => 8, Bit_Order => System.Low_Order_First;

   for Status_Type use record
      Interface_Number at 0 range 0 .. 3;
      Identifier       at 0 range 4 .. 7;
   end record;

   type Msg_Header is record
      Start       : AMC_Types.UInt8 := Packet_Start;
      Data_Length : AMC_Types.UInt16 := 16#0#;
      Status      : Status_Type;
   end record
      with Size => Header_Byte_Length * 8, Bit_Order => System.Low_Order_First;

   for Msg_Header use record
      Start       at 0 range 0 .. 7;
      Data_Length at 0 range 8 .. 23;
      Status      at 0 range 24 .. 31;
   end record;

end Communication;
