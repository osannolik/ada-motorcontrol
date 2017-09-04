with Ada.Unchecked_Conversion;

package body Communication is

   subtype Loc_Byte_Array is Byte_Array (0 .. Header_Byte_Length - 1);

   function To_Byte_Array is new Ada.Unchecked_Conversion (Source => Msg_Header,
                                                           Target => Loc_Byte_Array);

   function To_Byte_Array (Items : in Byte_Queue.Item_Array) return Byte_Array;

   function To_Byte_Array (Items : in Byte_Queue.Item_Array) return Byte_Array is
      (Byte_Array (Items));




   procedure Initialize (Interface_Obj    : access Interface_Type'Class;
                         Interface_Number : in Interface_Number_Type) is
   begin
      Interface_Obj.Interface_Number := Interface_Number;
   end Initialize;

   procedure Send (Interface_Obj : access Interface_Type'Class;
                   Port          : access Port_Type;
                   Identifier    : in Identifier_Type;
                   Data          : in Byte_Array) is
   begin
      Port.Put (Interface_Number => Interface_Obj.Interface_Number,
                Identifier       => Identifier,
                Data             => Data);
   end Send;




   procedure Initialize (Port             : access Port_Type;
                         IO_Stream_Access : in Stream_Interface.Base_Stream_Access)
   is
   begin
      Port.Stream := IO_Stream_Access;
      Port.Parser_State := Wait_For_Start;
   end Initialize;

   procedure Attach_Interface (Port          : in out Port_Type;
                               Interface_Obj : in out Interface_Type'Class) is
   begin
      null;
      --  Add callback to Port.Callbacks
   end Attach_Interface;

   procedure Put (Port             : access Port_Type;
                  Interface_Number : in Interface_Number_Type;
                  Identifier       : in Identifier_Type;
                  Data             : in Byte_Array) is

      Status : constant Status_Type :=
         Status_Type'(Interface_Number => Interface_Number,
                      Identifier       => Identifier);

      Header : constant Msg_Header :=
         Msg_Header'(Start       => Packet_Start,
                     Data_Length => AMC_Types.UInt16 (Data'Length),
                     Status      => Status);

      Header_Bytes : constant Byte_Array := To_Byte_Array (Header);

      Full_Array : constant Byte_Queue.Item_Array :=
         Byte_Queue.Item_Array (Header_Bytes & Data);

   begin
      Port.Tx_Queue.Push (Items => Full_Array);
   end Put;






   procedure Transmit_Handler (Port : in out Port_Type) is
      Bytes_To_Send : constant Natural := Port.Tx_Queue.Occupied_Slots;
      Bytes_Sent : Natural;
      Data : constant Byte_Array := To_Byte_Array (Port.Tx_Queue.Peek (N => Bytes_To_Send));
   begin
      Port.Stream.Write (Data => Data,
                         Sent => Bytes_Sent);
      Port.Tx_Queue.Flush (N => Bytes_Sent);
   end Transmit_Handler;

end Communication;
