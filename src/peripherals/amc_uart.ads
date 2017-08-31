with STM32.GPIO;
with STM32.USARTs;
with STM32.DMA;
with AMC_Board;
with STM32.Device;
with System;
with AMC_Types; use AMC_Types;

package AMC_UART is

   Buffer_Max_Length : constant Natural := 256;

   subtype Buffer_Index is Natural range 0 .. Buffer_Max_Length - 1;

   function Is_Initialized
      return Boolean;

   procedure Initialize;

   function Is_Busy_Tx return Boolean;

   procedure Send_Data (Data : access Byte_Array);

   function Receive_Data return Byte_Array;

   Busy_Transmitting : exception;
   No_New_Data : exception;

private

   UART : STM32.USARTs.USART renames AMC_Board.Uart_Peripheral;

   Baud_Rate : constant STM32.USARTs.Baud_Rates := 115_200;

   AF : constant STM32.GPIO_Alternate_Function := AMC_Board.Uart_GPIO_AF;

   Pins : constant STM32.GPIO.GPIO_Points :=
      (AMC_Board.Uart_Tx_Pin, AMC_Board.Uart_Rx_Pin);

   UART_Data_Address : constant System.Address :=
      STM32.USARTs.Data_Register_Address (UART);

   DMA_Ctrl : STM32.DMA.DMA_Controller renames STM32.Device.DMA_2;

   DMA_Stream_Tx  : constant STM32.DMA.DMA_Stream_Selector  := STM32.DMA.Stream_7;
   DMA_Channel_Tx : constant STM32.DMA.DMA_Channel_Selector := STM32.DMA.Channel_5;
   DMA_Stream_Rx  : constant STM32.DMA.DMA_Stream_Selector  := STM32.DMA.Stream_1;
   DMA_Channel_Rx : constant STM32.DMA.DMA_Channel_Selector := STM32.DMA.Channel_5;

   Initialized : Boolean := False;

   Buffer_Tx : aliased Byte_Array (Buffer_Index'Range);
   Buffer_Rx : aliased Byte_Array (Buffer_Index'Range);
   Buffer_Tx_Address : constant System.Address := Buffer_Tx'Address;

end AMC_UART;
