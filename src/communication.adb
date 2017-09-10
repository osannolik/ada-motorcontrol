with CRC;

package body Communication is

   function To_Byte_Array (Items : in Byte_Queue.Item_Array) return Byte_Array;

   function To_Byte_Array (Items : in Byte_Queue.Item_Array) return Byte_Array is
      (Byte_Array (Items));

   function Is_Packet_Start (Byte : in AMC_Types.UInt8) return Boolean is
      (Byte = Packet_Start);

   function Calculate_CRC (Header : in Header_Type;
                           Data   : in Byte_Array)
                           return AMC_Types.UInt8;

   procedure Do_New_Data_Callback (Port   : in out Port_Type;
                                   Status : in Status_Type;
                                   Data   : access Byte_Array);

   procedure Commands_Callback_Handler (Identifier : in Identifier_Type;
                                        Data       : access Byte_Array;
                                        From_Port  : in out Port_Type);

   procedure Commands_Write_To (Data  : access Byte_Array;
                                Error : out Boolean);

   procedure Commands_Read_From (Data         : access Byte_Array;
                                 Send_To_Port : in out Port_Type;
                                 Error        : out Boolean);



   procedure Initialize (Interface_Obj    : access Interface_Type'Class;
                         Interface_Number : in Interface_Numbers) is
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
                         IO_Stream_Access : in Stream_Interface.Base_Stream_Access;
                         Enable_Tx_Crc    : in Boolean := False;
                         Enable_Rx_Crc    : in Boolean := True)
   is
   begin
      Port.Stream       := IO_Stream_Access;
      Port.Use_Rx_CRC   := Enable_Rx_Crc;
      Port.Use_Tx_CRC   := Enable_Tx_Crc;
      Port.Parser_State := Wait_For_Start;
      Port.Buffer_Idx   := Buffer_Index'First;
      Port.Tx_Queue.Flush_All;

      --  Reserved interface (0) for memory read/writes
      Port.Attach_Interface (Interface_Obj     => Commands_Interface,
                             New_Data_Callback => Commands_Callback_Handler'Access);
   end Initialize;


   procedure Attach_Interface (Port              : in out Port_Type;
                               Interface_Obj     : in out Interface_Type'Class;
                               New_Data_Callback : in Callback_Access) is
   begin
      Port.New_Data_CB (Interface_Obj.Interface_Number) := New_Data_Callback;
   end Attach_Interface;


   function Calculate_CRC (Header : in Header_Type;
                           Data   : in Byte_Array)
                           return AMC_Types.UInt8 is
   begin
      return CRC.Calculate (Byte_Array'(((0) => Header.Arr (3))) & Data);
   end Calculate_CRC;


   procedure Put (Port             : access Port_Type;
                  Interface_Number : in Interface_Number_Type;
                  Identifier       : in Identifier_Type;
                  Data             : in Byte_Array)

   is
      Header : constant Header_Type :=
         Header_Type'(As_Array  => False,
                      Msg       => (Start       => Packet_Start,
                                    Data_Length => AMC_Types.UInt16 (Data'Length),
                                    Status      => (Interface_Number => Interface_Number,
                                                    Identifier       => Identifier)));
      Crc_Byte : AMC_Types.UInt8;
   begin
      if Port.Use_Tx_CRC then
         Crc_Byte := Calculate_CRC (Header, Data);
         Port.Tx_Queue.Push (Items => Byte_Queue.Item_Array (Header.Arr & Data & Crc_Byte));
      else
         Port.Tx_Queue.Push (Items => Byte_Queue.Item_Array (Header.Arr & Data));
      end if;
   end Put;


   procedure Do_New_Data_Callback (Port   : in out Port_Type;
                                   Status : in Status_Type;
                                   Data   : access Byte_Array) is
      Callback : constant Callback_Access := Port.New_Data_CB (Status.Interface_Number);
   begin
      if Callback /= null then
         Callback (Identifier => Status.Identifier,
                   Data       => Data,
                   From_Port  => Port);
      end if;
   end Do_New_Data_Callback;


   procedure Commands_Send_Error (Port                     : in out Port_Type;
                                  Causing_Interface_Number : in Interface_Number_Type) is
      Data : constant Byte_Array := (0 => AMC_Types.UInt8 (Causing_Interface_Number));
   begin
      Port.Put (Interface_Number => Commands_Interface_Number,
                Identifier       => Com_Id_Error,
                Data             => Data);
   end Commands_Send_Error;


   type Commands_Mem_Range_Cmd is record
      At_Address : System.Address;
      Length     : AMC_Types.UInt16 := 16#0#;
   end record
      with Size => 48;

   for Commands_Mem_Range_Cmd use record
      At_Address at 0 range 0  .. 31;
      Length     at 0 range 32 .. 47;
   end record;

   type Commands_Mem_Range_Type
      (As_Array : Boolean := False)
   is record
      case As_Array is
         when False =>
            Cmd : Commands_Mem_Range_Cmd;

         when True =>
            Arr : Byte_Array (0 .. 5);

      end case;
   end record
      with Unchecked_Union, Size => 48;


   procedure Commands_Write_To (Data  : access Byte_Array;
                                Error : out Boolean) is
      Write  : Commands_Mem_Range_Type;
      Cmd_Length : constant Natural := Commands_Mem_Range_Cmd'Size / 8;
   begin
      Error := (Data'Length < Cmd_Length);
      if not Error then
         Write := Commands_Mem_Range_Type'(As_Array => True,
                                           Arr      => Data (0 .. Cmd_Length - 1));
         Error := (Natural (Write.Cmd.Length) = Data'Length - Cmd_Length);
         if not Error then
            declare
               subtype Write_Array is Byte_Array (0 .. Natural (Write.Cmd.Length) - 1);

               procedure Write_Unsafe (A : System.Address; Data : in Byte_Array);
               procedure Write_Unsafe (A : System.Address; Data : in Byte_Array) is
                  Result : Write_Array;
                  for Result'Address use A;
                  pragma Import (Convention => Ada, Entity => Result);
               begin
                  Result := Data;
               end Write_Unsafe;
            begin
               Write_Unsafe (A    => Write.Cmd.At_Address,
                             Data => Data (Cmd_Length .. Data'Length - 1));
            end;
         end if;
      end if;
   end Commands_Write_To;


   procedure Commands_Read_From (Data         : access Byte_Array;
                                 Send_To_Port : in out Port_Type;
                                 Error        : out Boolean) is
      Read  : Commands_Mem_Range_Type;
      Cmd_Length : constant Natural := Commands_Mem_Range_Cmd'Size / 8;
   begin
      Error := (Data'Length /= Cmd_Length);
      if not Error then
         Read := Commands_Mem_Range_Type'(As_Array => True,
                                          Arr      => Data (0 .. Cmd_Length - 1));
         declare
            subtype Read_Array is Byte_Array (0 .. Natural (Read.Cmd.Length) - 1);

            function Read_Unsafe (A : System.Address) return Read_Array;
            function Read_Unsafe (A : System.Address) return Read_Array is
               Result : constant Read_Array;
               for Result'Address use A;
               pragma Import (Convention => Ada, Entity => Result);
            begin
               return Result;
            end Read_Unsafe;

         begin
            Send_To_Port.Put (Interface_Number => Commands_Interface_Number,
                              Identifier       => Com_Id_Read_From,
                              Data             => Read_Unsafe (Read.Cmd.At_Address));
         end;
      end if;
   end Commands_Read_From;


   procedure Commands_Callback_Handler (Identifier : in Identifier_Type;
                                        Data       : access Byte_Array;
                                        From_Port  : in out Port_Type) is
      Error : Boolean;
   begin
      case Identifier is
         when Com_Id_Write_To =>
            Commands_Write_To (Data  => Data,
                               Error => Error);

         when Com_Id_Read_From =>
            Commands_Read_From (Data         => Data,
                                Send_To_Port => From_Port,
                                Error        => Error);

         when Com_Id_Error =>
            null;

         when others =>
            null;
      end case;

      if Error then
         Commands_Send_Error (Port                     => From_Port,
                              Causing_Interface_Number => Commands_Interface_Number);
      end if;
   end Commands_Callback_Handler;


   procedure Receive_Handler (Port : in out Port_Type) is

      Data_Start_Idx : constant Buffer_Index := Buffer_Index'First;

      pragma Style_Checks (Off); --  No spec is OK
      procedure Fill_Header (Port       : in out Port_Type;
                             D          : in AMC_Types.UInt8;
                             Next_State : out Parser_State_Type) is
         pragma Style_Checks (On);
         No_Data : aliased Byte_Array := AMC_Types.Empty_Byte_Array;
      begin
         Port.Header_Rx.Arr (3) := D;
         Port.Buffer_Idx := Data_Start_Idx;
         if Port.Header_Rx.Msg.Data_Length = 0 then
            if Port.Use_Rx_CRC then
               Next_State := Calc_Crc;
            else
               Port.Do_New_Data_Callback (Status => Port.Header_Rx.Msg.Status,
                                          Data   => No_Data'Access);
               Next_State := Wait_For_Start;
            end if;
         else
            Next_State := Get_Data;
         end if;
      end Fill_Header;

      pragma Style_Checks (Off); --  No spec is OK
      procedure Fill_Data (Port       : in out Port_Type;
                           D          : in AMC_Types.UInt8;
                           Next_State : out Parser_State_Type) is
         pragma Style_Checks (On);
      begin
         Port.Buffer_Rx_Data (Port.Buffer_Idx) := D;
         Port.Buffer_Idx := Port.Buffer_Idx + 1;
         if Port.Buffer_Idx = Natural (Port.Header_Rx.Msg.Data_Length) then
            if Port.Use_Rx_CRC then
               Next_State := Calc_Crc;
            else
               declare
                  New_Data : aliased Byte_Array :=
                     Port.Buffer_Rx_Data (Data_Start_Idx .. Port.Buffer_Idx - 1);
               begin
                  Port.Do_New_Data_Callback (Status => Port.Header_Rx.Msg.Status,
                                             Data   => New_Data'Access);
               end;
               Next_State := Wait_For_Start;
            end if;
         else
            Next_State := Get_Data;
         end if;
      end Fill_Data;

      pragma Style_Checks (Off); --  No spec is OK
      procedure Do_Crc (Port        : in out Port_Type;
                        Message_Crc : in AMC_Types.UInt8) is
         pragma Style_Checks (On);
         New_Data : aliased Byte_Array :=
            Port.Buffer_Rx_Data (Data_Start_Idx .. Port.Buffer_Idx - 1);
      begin
         if Message_Crc = Calculate_CRC (Port.Header_Rx, New_Data) then
            Port.Do_New_Data_Callback (Status => Port.Header_Rx.Msg.Status,
                                       Data   => New_Data'Access);
         else
            Commands_Send_Error
               (Port                     => Port,
                Causing_Interface_Number =>
                   Port.Header_Rx.Msg.Status.Interface_Number);
         end if;
      end Do_Crc;

   begin
      loop
         declare
            Data : constant Byte_Array := Port.Stream.Read;
         begin
            exit when Data'Length = 0;

            for D of Data loop
               case Port.Parser_State is

                  when Wait_For_Start =>
                     if Is_Packet_Start (D) then
                        Port.Parser_State := Get_Size_1;
                     end if;

                  when Get_Size_1 =>
                     Port.Header_Rx.Arr (1) := D;
                     Port.Parser_State := Get_Size_2;

                  when Get_Size_2 =>
                     Port.Header_Rx.Arr (2) := D;
                     Port.Parser_State := Get_Header;

                  when Get_Header =>
                     Fill_Header (Port => Port,
                                  D    => D,
                                  Next_State => Port.Parser_State);

                  when Get_Data =>
                     Fill_Data (Port => Port,
                                D    => D,
                                Next_State => Port.Parser_State);

                  when Calc_Crc =>
                     Do_Crc (Port        => Port,
                             Message_Crc => D);
                     Port.Parser_State := Wait_For_Start;

               end case;
            end loop;
         end;
      end loop;

   end Receive_Handler;


   procedure Transmit_Handler (Port : in out Port_Type) is
      Bytes_To_Send : constant Natural := Port.Tx_Queue.Occupied_Slots;
   begin
      if Bytes_To_Send > 0 then
         declare
            Bytes_Sent : Natural;
            Data : constant Byte_Array :=
               To_Byte_Array (Port.Tx_Queue.Peek (Bytes_To_Send));
         begin
            Port.Stream.Write (Data => Data,
                               Sent => Bytes_Sent);
            Port.Tx_Queue.Flush (N => Bytes_Sent);
         end;
      end if;
   end Transmit_Handler;

begin

   Commands_Interface.Interface_Number := Commands_Interface_Number;

end Communication;
