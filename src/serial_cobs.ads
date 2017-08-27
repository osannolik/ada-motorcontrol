with AMC_UART;

package Serial_COBS is

   subtype Buffer_Index is AMC_UART.Buffer_Index_Range;
   subtype Data is AMC_UART.Data_TxRx;

   function COBS_Encode (Input : access Data)
                         return Data;

   function COBS_Decode (Encoded_Data : access Data)
                         return Data;

   procedure Receive_Handler;


end Serial_COBS;
