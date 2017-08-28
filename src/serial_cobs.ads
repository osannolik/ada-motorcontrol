with AMC_UART;

package Serial_COBS is
   --  Consistent Overhead Byte Stuffing

   Delimiter : constant AMC_UART.Buffer_Element := AMC_UART.Buffer_Element'(0);

   subtype Buffer_Index is AMC_UART.Buffer_Index_Range;
   subtype Data is AMC_UART.Data_TxRx;

   type COBS_Object is tagged limited record
      Buffer_Incomplete : Data (Buffer_Index'Range);
      Idx_Buffer        : Positive := Buffer_Index'First;
   end record;

   Data_Length_Max : constant Buffer_Index := 253;
   --  COBS always adds 1 byte to the message length.
   --  Additionally, for longer packets of length n,
   --  it may add floor(n/254) additional bytes to the encoded packet size.
   --  Hence, by setting data len to max 253, the stuffing size is always 1 byte.

   function COBS_Encode (Input : access Data)
                         return Data
   with
      Pre => Input'Length <= Data_Length_Max,
      Post => (if Input'Length > 0 then
                  COBS_Encode'Result'Length = Input'Length + 1
               else
                  Input'Length = COBS_Encode'Result'Length);

   function COBS_Decode (Encoded_Data : access Data)
                         return Data
   with
      Pre => Encoded_Data'Length <= Data_Length_Max + 1,
      Post => (if Encoded_Data'Length > 0 then
                  COBS_Decode'Result'Length = Encoded_Data'Length - 1
               else
                  Encoded_Data'Length = COBS_Decode'Result'Length);

   function Receive_Handler (Obj : in out COBS_Object;
                             Encoded_Rx : in Data)
                             return Data;


end Serial_COBS;
