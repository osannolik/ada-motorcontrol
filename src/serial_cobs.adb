with HAL; use HAL;

package body Serial_COBS is



   Delimiter : constant AMC_UART.Buffer_Element := 0;

   Decode_Buffer : Data (Buffer_Index'Range);

   Decode_Index : Positive := 1;

   pragma Unreferenced (Decode_Buffer, Decode_Index);


   function COBS_Encode (Input : access Data)
                         return Data
   is
      --  Output length is always 1 element longer than Input
      subtype Output_Index is
         Buffer_Index range Buffer_Index'First .. Buffer_Index'First + Input'Length;

      Encoded_Data : Data (Output_Index);
      Idx_Code     : Buffer_Index := Buffer_Index'First;
      Idx_Out      : Buffer_Index := Buffer_Index'First + 1;
      Code         : AMC_UART.Buffer_Element := 1;
   begin
      for D of Input.all loop
         if D = 0 then
            Encoded_Data (Idx_Code) := Code;
            Idx_Code := Idx_Out;
            Idx_Out  := Idx_Out + 1;
            Code := 1;
         else
            Encoded_Data (Idx_Out) := D;
            Idx_Out := Idx_Out + 1;
            Code := Code + 1;
            if Code = 255 then
               Encoded_Data (Idx_Code) := Code;
               Idx_Code := Idx_Out;
               Idx_Out  := Idx_Out + 1;
               Code := 1;
            end if;
         end if;
      end loop;

      Encoded_Data (Idx_Code) := Code;

      return Encoded_Data;
   end COBS_Encode;


   function COBS_Decode (Encoded_Data : access Data)
                         return Data
   is
      --  Output length is always 1 element less than Encoded_Data
      subtype Output_Index is
         Buffer_Index range Buffer_Index'First .. Buffer_Index'First + Encoded_Data'Length - 2;

      Decoded_Data     : Data (Output_Index'Range);
      Idx_Out, Idx_End : Buffer_Index := Buffer_Index'First;
      Idx              : Positive := Buffer_Index'First;
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


   procedure Receive_Handler is
   begin

      declare
         Encoded_Rx : constant AMC_UART.Data_TxRx := AMC_UART.Receive_Data;
         --  N : constant Natural := Encoded_Rx'Length;
         I : Positive := 1;
      begin

         for B of Encoded_Rx loop
            if B = Delimiter then
               --  Decode_Buffer (Decode_Index .. I) := Encoded_Rx (1 ..
               null;
            else
               I := I + 1;
            end if;

         end loop;


      end;

   end Receive_Handler;

end Serial_COBS;
