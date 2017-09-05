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



   type Callback_Access is access procedure (Identifier : in Identifier_Type;
                                             Data       : access Byte_Array);





   type Interface_Type is tagged limited private;

   procedure Initialize (Interface_Obj    : access Interface_Type'Class;
                         Interface_Number : in Interface_Number_Type);

   procedure Send (Interface_Obj : access Interface_Type'Class;
                   Port          : access Port_Type;
                   Identifier    : in Identifier_Type;
                   Data          : in Byte_Array);





   procedure Initialize (Port             : access Port_Type;
                         IO_Stream_Access : in Stream_Interface.Base_Stream_Access);

   procedure Attach_Interface (Port              : in out Port_Type;
                               Interface_Obj     : in out Interface_Type'Class;
                               New_Data_Callback : in Callback_Access);
   --  Attaching an interface to a port enables a callback subprogram to be
   --  called when new data is received for the specified interface.
   --  NOTE: Keep New_Data_Callback short. It is called in the context of
   --        Port.Receive_Handler

   procedure Put (Port             : access Port_Type;
                  Interface_Number : in Interface_Number_Type;
                  Identifier       : in Identifier_Type;
                  Data             : in Byte_Array);

   procedure Receive_Handler (Port : in out Port_Type);

   procedure Transmit_Handler (Port : in out Port_Type);




private

   type Interface_Type is tagged limited record
      Interface_Number : Interface_Number_Type;
   end record;





   Packet_Start : constant AMC_Types.UInt8 := 16#73#;  --  's'
   Data_Length_Max : constant Natural := 1024;  --  Natural (Data_Size_Type'Last - 1);

   Header_Byte_Length : constant Positive := 4;

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
      Data_Length : AMC_Types.UInt16 := 0;
      Status      : Status_Type;
   end record
      with Size => Header_Byte_Length * 8, Bit_Order => System.Low_Order_First;

   for Msg_Header use record
      Start       at 0 range 0 .. 7;
      Data_Length at 0 range 8 .. 23;
      Status      at 0 range 24 .. 31;
   end record;

   type Header_Type
      (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            Msg : Msg_Header;

         when True =>
            Arr : Byte_Array (0 .. Header_Byte_Length - 1);

      end case;
   end record
      with Unchecked_Union, Size => 32, Volatile_Full_Access;

   for Header_Type use record
      Msg at 0 range 0 .. 31;
      Arr at 0 range 0 .. 31;
   end record;

   type Parser_State_Type is (Wait_For_Start,
                              Get_Header,
                              Get_Size_1,
                              Get_Size_2,
                              Get_Data,
                              Calc_Crc);

   subtype Buffer_Index is Natural range 0 .. Data_Length_Max;

   type Callbacks_Array is array (Interface_Number_Type'Range) of Callback_Access;

   type Port_Type is tagged limited record
      Stream         : Stream_Interface.Base_Stream_Access;

      New_Data_CB    : Callbacks_Array := (others => null);

      Tx_Queue       : Byte_Queue.Protected_Queue (Config.Protected_Object_Prio);
      Buffer_Rx_Data : aliased Byte_Array (Buffer_Index'Range);
      Header_Rx      : Header_Type;

      Parser_State   : Parser_State_Type := Wait_For_Start;
      Buffer_Idx     : Buffer_Index := 0;

      Use_Rx_CRC     : Boolean := False;
      Use_Tx_CRC     : Boolean := False;
   end record;

end Communication;
