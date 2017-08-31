with AMC_Types; use AMC_Types;

package body Serial_COBS is

   function Is_Delimiter (X : in AMC_Types.UInt8) return Boolean is
      use type AMC_Types.UInt8;
   begin
      return X = AMC_Types.UInt8'(Delimiter);
   end Is_Delimiter;

   function COBS_Encode (Input : access Byte_Array)
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

      for D of Input.all loop
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


   function COBS_Decode (Encoded_Data : access Byte_Array)
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


   function Receive_Handler (Obj : in out COBS_Object;
                             Encoded_Rx : in Byte_Array)
                             return Byte_Array
   is
      Decoded_Data : Byte_Array (Buffer_Index'Range);
      Idx_Decode   : Natural := Buffer_Index'First;
   begin

      for Data of Encoded_Rx loop
         if Is_Delimiter (Data) then
            declare
               Encoded_Data : aliased Byte_Array :=
                  Obj.Buffer_Incomplete (Buffer_Index'First .. Obj.Idx_Buffer - 1);
               Decoded_Length : constant Natural :=
                  Obj.Idx_Buffer - 1 - Buffer_Index'First; -- Enc len minus one
            begin
               Decoded_Data (Idx_Decode .. Idx_Decode + Decoded_Length - 1) :=
                  COBS_Decode (Encoded_Data'Access);
               Idx_Decode := Idx_Decode + Decoded_Length;
            end;

            Obj.Idx_Buffer := Buffer_Index'First;
         else
            Obj.Buffer_Incomplete (Obj.Idx_Buffer) := Data;
            Obj.Idx_Buffer := Obj.Idx_Buffer + 1;
         end if;
      end loop;

      return Decoded_Data (Buffer_Index'First .. Idx_Decode - 1);

   end Receive_Handler;

end Serial_COBS;
