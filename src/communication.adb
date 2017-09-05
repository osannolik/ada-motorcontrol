package body Communication is

   function To_Byte_Array (Items : in Byte_Queue.Item_Array) return Byte_Array;

   function To_Byte_Array (Items : in Byte_Queue.Item_Array) return Byte_Array is
      (Byte_Array (Items));

   function Is_Packet_Start (Byte : in AMC_Types.UInt8) return Boolean is
      (Byte = Packet_Start);

   procedure Do_New_Data_Callback (Port             : in out Port_Type;
                                   Interface_Number : in Interface_Number_Type;
                                   Identifier       : in Identifier_Type;
                                   Data             : access Byte_Array);






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


   procedure Attach_Interface (Port              : in out Port_Type;
                               Interface_Obj     : in out Interface_Type'Class;
                               New_Data_Callback : in Callback_Access) is
   begin
      Port.New_Data_CB (Interface_Obj.Interface_Number) := New_Data_Callback;
   end Attach_Interface;


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
   begin
      Port.Tx_Queue.Push (Items => Byte_Queue.Item_Array (Header.Arr & Data));
   end Put;


   procedure Do_New_Data_Callback (Port             : in out Port_Type;
                                   Interface_Number : in Interface_Number_Type;
                                   Identifier       : in Identifier_Type;
                                   Data             : access Byte_Array) is
      Callback : constant Callback_Access := Port.New_Data_CB (Interface_Number);
   begin
      if Callback /= null then
         Callback (Identifier => Identifier,
                   Data       => Data);
      end if;
   end Do_New_Data_Callback;


   procedure Receive_Handler (Port : in out Port_Type) is
      No_Data        : aliased Byte_Array    := AMC_Types.Empty_Byte_Array;
      Data_Start_Idx : constant Buffer_Index := 0;
   begin
      --  TODO: Rewrite, looks nasty...
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
                     Port.Header_Rx.Arr (3) := D;
                     Port.Buffer_Idx := Data_Start_Idx;
                     if Port.Header_Rx.Msg.Data_Length = 0 then
                        if Port.Use_Rx_CRC then
                           Port.Parser_State := Calc_Crc;
                        else
                           Port.Do_New_Data_Callback
                              (Interface_Number => Port.Header_Rx.Msg.Status.Interface_Number,
                               Identifier       => Port.Header_Rx.Msg.Status.Identifier,
                               Data             => No_Data'Access);
                           Port.Parser_State := Wait_For_Start;
                        end if;
                     else
                        Port.Parser_State := Get_Data;
                     end if;

                  when Get_Data =>
                     Port.Buffer_Rx_Data (Port.Buffer_Idx) := D;
                     Port.Buffer_Idx := Port.Buffer_Idx + 1;
                     if Port.Buffer_Idx = Natural (Port.Header_Rx.Msg.Data_Length) then
                        if Port.Use_Rx_CRC then
                           Port.Parser_State := Calc_Crc;
                        else
                           declare
                              New_Data : aliased Byte_Array :=
                                 Port.Buffer_Rx_Data (Data_Start_Idx .. Port.Buffer_Idx - 1);
                           begin
                              Port.Do_New_Data_Callback
                                 (Interface_Number => Port.Header_Rx.Msg.Status.Interface_Number,
                                  Identifier       => Port.Header_Rx.Msg.Status.Identifier,
                                  Data             => New_Data'Access);
                           end;
                           Port.Parser_State := Wait_For_Start;
                        end if;
                     end if;

                  when Calc_Crc =>
                     null;

               end case;

            end loop;

         end;
      end loop;

   end Receive_Handler;


   procedure Transmit_Handler (Port : in out Port_Type) is
      Bytes_Sent    : Natural;
      Bytes_To_Send : constant Natural := Port.Tx_Queue.Occupied_Slots;
      Data          : constant Byte_Array :=
         To_Byte_Array (Port.Tx_Queue.Peek (N => Bytes_To_Send));
   begin
      Port.Stream.Write (Data => Data,
                         Sent => Bytes_Sent);
      Port.Tx_Queue.Flush (N => Bytes_Sent);
   end Transmit_Handler;

end Communication;
