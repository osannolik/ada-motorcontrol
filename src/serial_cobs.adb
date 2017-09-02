with AMC_Types; use AMC_Types;

package body Serial_COBS is

   function Is_Delimiter (X : in AMC_Types.UInt8) return Boolean is
      use type AMC_Types.UInt8;
   begin
      return X = Delimiter;
   end Is_Delimiter;

   procedure Initialize (Stream : in out COBS_Stream;
                         IO_Stream_Access : in Stream_Interface.Base_Stream_Access)
   is
   begin
      Stream.Idx_Buffer := Buffer_Index'First;
      Stream.IO_Stream_Access := IO_Stream_Access;
   end Initialize;

   function COBS_Encode (Input : in Byte_Array)
                         return Byte_Array
   is
      --  Output length is always 1 element longer than Input
      subtype Output_Index is
         Buffer_Index range Buffer_Index'First .. Buffer_Index'First + Input'Length;

      Encoded_Data : Byte_Array (Output_Index);
      Idx_Code     : Buffer_Index := Buffer_Index'First;
      Idx_Out      : Buffer_Index := Buffer_Index'First + 1;
      Code         : Positive := 1;
   begin
      if Input'Length = 0 then
         return Empty_Byte_Array;
      end if;

      for D of Input loop
         if Is_Delimiter (D) then
            Encoded_Data (Idx_Code) := AMC_Types.UInt8 (Code);
            Idx_Code := Idx_Out;
            Idx_Out  := Idx_Out + 1;
            Code := 1;
         else
            Encoded_Data (Idx_Out) := D;
            Idx_Out := Idx_Out + 1;
            Code := Code + 1;
            if Code = 255 then
               Encoded_Data (Idx_Code) := AMC_Types.UInt8 (Code);
               Idx_Code := Idx_Out;
               Idx_Out  := Idx_Out + 1;
               Code := 1;
            end if;
         end if;
      end loop;

      Encoded_Data (Idx_Code) := AMC_Types.UInt8 (Code);

      return Encoded_Data;

   end COBS_Encode;


   function COBS_Decode (Encoded_Data : in Byte_Array)
                         return Byte_Array
   is
      --  Output length is always 1 element less than Encoded_Data
      subtype Output_Index is
         Buffer_Index range Buffer_Index'First .. Buffer_Index'First + Encoded_Data'Length - 2;

      Decoded_Data     : Byte_Array (Output_Index'Range);
      Idx_Out, Idx_End : Buffer_Index := Buffer_Index'First;
      Idx              : Natural := Buffer_Index'First;
      Length           : Natural;
   begin
      loop
         Length := Natural (Encoded_Data (Idx)) - 1;
         Idx_End := Idx + Length;

         Decoded_Data (Idx_Out .. Idx_Out + Length - 1) :=
            Encoded_Data (Idx + 1 .. Idx_End);

         Idx := Idx_End + 1;
         Idx_Out := Idx_Out + Length;

         exit when not (Idx < Buffer_Index'First + Encoded_Data'Length);

         if Idx < 255 then
            Decoded_Data (Idx_Out) := 0;
            Idx_Out := Idx_Out + 1;
         end if;
      end loop;

      return Decoded_Data;

   end COBS_Decode;

   function Receive_Handler (Stream    : in out COBS_Stream;
                             IO_Stream : in out Stream_Interface.Base_Stream'Class)
                             return AMC_Types.Byte_Array
   is
      Encoded_Rx   : constant Byte_Array := IO_Stream.Read;
      Decoded_Data : Byte_Array (Buffer_Index'Range);
      Idx_Decode   : Natural := Buffer_Index'First;
   begin

      for Data of Encoded_Rx loop
         if Is_Delimiter (Data) then
            declare
               Encoded_Data : constant Byte_Array :=
                  Stream.Buffer_Incomplete (Buffer_Index'First .. Stream.Idx_Buffer - 1);
               Decoded_Length : constant Natural :=
                  Stream.Idx_Buffer - 1 - Buffer_Index'First; -- Enc len minus one
            begin
               Decoded_Data (Idx_Decode .. Idx_Decode + Decoded_Length - 1) :=
                  COBS_Decode (Encoded_Data);
               Idx_Decode := Idx_Decode + Decoded_Length;
            end;

            Stream.Idx_Buffer := Buffer_Index'First;
         else
            Stream.Buffer_Incomplete (Stream.Idx_Buffer) := Data;
            Stream.Idx_Buffer := Stream.Idx_Buffer + 1;
         end if;
      end loop;

      return Decoded_Data (Buffer_Index'First .. Idx_Decode - 1);

   end Receive_Handler;


   overriding
   procedure Write (Stream : in out COBS_Stream;
                    Data   : in AMC_Types.Byte_Array;
                    Sent   : out Natural) is
      use type AMC_Types.Byte_Array;
      Encoded_Data : constant AMC_Types.Byte_Array := COBS_Encode (Data);
   begin
      if Encoded_Data'Length > 0 then
         Stream.IO_Stream_Access.Write (Data => Encoded_Data & Delimiter,
                                        Sent => Sent);
      else
         Sent := 0;
      end if;
   end Write;


   overriding
   function Read (Stream : in out COBS_Stream)
                  return AMC_Types.Byte_Array is
   begin
      return Receive_Handler (Stream    => Stream,
                              IO_Stream => Stream.IO_Stream_Access.all);
   end Read;


end Serial_COBS;
