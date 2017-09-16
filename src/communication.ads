with System;
with HAL; use HAL;
with AMC_Types; use AMC_Types;
with Byte_Queue;
with Config;
with Stream_Interface;

package Communication is
   --  @summary
   --  Communication package
   --
   --  @description
   --  Provides a layer that abstracts away the different available senders
   --  and receivers. It implements a simple protocol with a packet divided
   --  into a header and a data field. The header is consisting of a number
   --  indicating what "application" (interface) the packet belongs to,
   --  another number that is application defined, and the total data length.
   --  The data field is appended with an optional CRC byte.
   --
   --  A data sender/receiver is created by declaring an object of the type
   --  Port_type:
   --
   --   Serial_Port : aliased Communication.Port_Type;
   --
   --  The declared port then need to know which stream interface to use for IO.
   --  UART is here an overriding type of Stream_Interface.Base_Stream.
   --
   --   Serial_Port.Initialize (IO_Stream_Access => UART'Access);
   --
   --  An application wanting to use the created port type need to declare an
   --  interface of type Interface_Type, and to provide an access to a callback
   --  handler that will be called when new data is received:
   --
   --   Serial_Port.Attach_Interface
   --   (Interface_Obj     => Application_Interface,
   --    New_Data_Callback => Callback_Handler'Access);

   type Port_Type is tagged limited private;

   type Interface_Type is tagged limited private;


   subtype Interface_Number_Type is HAL.UInt4;
   --  A number that identifies the interface

   subtype Interface_Numbers is Interface_Number_Type range 1 .. Interface_Number_Type'Last;
   --  A number that identifies the interface

   subtype Identifier_Type is HAL.UInt4;
   --  A number that the application may use to identify the type of data sent/received


   type Callback_Access is access procedure (Identifier : in Identifier_Type;
                                             Data       : access Byte_Array;
                                             From_Port  : access Port_Type);

   procedure Initialize (Interface_Obj    : access Interface_Type'Class;
                         Interface_Number : in Interface_Numbers);
   --  Initializes the provided interface object to use the specified interface number
   --  @param Interface_Obj The interface object
   --  @param Interface_Number The specified interface number. Must be unique for each Interface.

   procedure Send (Interface_Obj : access Interface_Type'Class;
                   Port          : access Port_Type;
                   Identifier    : in Identifier_Type;
                   Data          : in Byte_Array);
   --  Enqueue Data to be sent from the provided interface to the specified Port using an Id.
   --  The actual sending is performed when calling Transmit_Handler.
   --  @param Interface_Obj The interface object
   --  @param Port The port to use for sending
   --  @param Identifier Specified Id
   --  @param Data The data to be sent

   procedure Initialize (Port             : access Port_Type;
                         IO_Stream_Access : in Stream_Interface.Base_Stream_Access;
                         Enable_Tx_Crc    : in Boolean := False;
                         Enable_Rx_Crc    : in Boolean := True);
   --  Initialize the provided Port to use the specified stream for sending/receiving.
   --  @param Port The Port object to be initialized
   --  @param IO_Stream_Access The stream that will be used for data IO
   --  @param Enable_Tx_Crc Adds a checksum byte after the sent data
   --  @param Enable_Rx_Crc The receiver will assume that the received data is
   --  appended with a checksum byte

   procedure Attach_Interface (Port              : access Port_Type;
                               Interface_Obj     : in out Interface_Type'Class;
                               New_Data_Callback : in Callback_Access);
   --  Attaching an interface to a port enables a callback subprogram to be
   --  called when new data is received for the specified interface.
   --  NOTE: Keep New_Data_Callback short. It is called in the context of
   --  Port.Receive_Handler
   --  @param Port The port object which to attach the interface callback to
   --  @param Interface_Obj Corresponding interface
   --  @param New_Data_Callback The subprogram that shall be called when new
   --  data arrives on the specified interface.

   procedure Commands_Send_Error (Port                     : access Port_Type;
                                  Causing_Interface_Number : in Interface_Number_Type);
   --  Send an error indication on the provided port.
   --  @param Port Send the error to this port
   --  @param Causing_Interface_Number The interface that sends the error.

   procedure Receive_Handler (Port : in out Port_Type);
   --  Checks for new data on the specified port. Should be called periodically.
   --  If new data is found, then the callback for the corresponding interface will
   --  be called.
   --  @param Port Poll for new data on this port.

   procedure Transmit_Handler (Port : in out Port_Type);
   --  Send all data that has been enqueued for transmission using the provided port.
   --  @param Port Send to the stream assigned to this port.

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

      Use_Rx_CRC     : Boolean;
      Use_Tx_CRC     : Boolean;
   end record;

   Com_Id_Error     : constant Identifier_Type := 0;
   Com_Id_Write_To  : constant Identifier_Type := 1;
   Com_Id_Read_From : constant Identifier_Type := 2;

   Commands_Interface_Number : constant Interface_Number_Type := 0;
   --  A reserved interface for errors and memory read/writes...

   Commands_Interface : aliased Interface_Type;

end Communication;
