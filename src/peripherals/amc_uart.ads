with STM32.GPIO;
with STM32.USARTs;
with STM32.DMA;
with AMC_Types; use AMC_Types;
with Stream_Interface;

package AMC_UART is

   type UART_Stream is limited new Stream_Interface.Base_Stream with private;

   Buffer_Max_Length : constant Natural := 256;
   subtype Buffer_Index is Natural range 0 .. Buffer_Max_Length - 1;

   function Is_Initialized (Stream : in UART_Stream)
      return Boolean;

   procedure Initialize_Default (Stream : in out UART_Stream);
   --  Initialise the UART_Stream using settings as per AMC_Board (and a few hard codeds)

   procedure Initialize (Stream         : in out UART_Stream;
                         Baud_Rate      : STM32.USARTs.Baud_Rates;
                         UART           : access STM32.USARTs.USART;
                         AF             : STM32.GPIO_Alternate_Function;
                         Tx_Pin         : STM32.GPIO.GPIO_Point;
                         Rx_Pin         : STM32.GPIO.GPIO_Point;
                         DMA_Ctrl       : access STM32.DMA.DMA_Controller;
                         DMA_Stream_Tx  : STM32.DMA.DMA_Stream_Selector;
                         DMA_Channel_Tx : STM32.DMA.DMA_Channel_Selector;
                         DMA_Stream_Rx  : STM32.DMA.DMA_Stream_Selector;
                         DMA_Channel_Rx : STM32.DMA.DMA_Channel_Selector)
   with
      Pre => not Is_Initialized (Stream),
      Post => Is_Initialized (Stream);
   --  Initialize a UART_Stream given the specified settings

   function Is_Busy_Tx (Stream : in UART_Stream) return Boolean;
   --  Indicates if the peripheral is currently transmitting any data

   Busy_Transmitting : exception;

   overriding
   procedure Write (Stream : in out UART_Stream;
                    Data   : in AMC_Types.Byte_Array;
                    Sent   : out Natural)
   with
      Pre => Data'Length <= Buffer_Max_Length;
   --  Writes byte data to the specified UART_Stream.
   --  If the peripheral is busy transmitting previous data the exception
   --  Busy_Transmitting is raised.

   overriding
   function Read (Stream : in out UART_Stream)
                  return AMC_Types.Byte_Array
   with
      Post => Read'Result'Length <= Buffer_Max_Length;
   --  Reads byte data from the specified UART_Stream

private

   type UART_Stream is limited new Stream_Interface.Base_Stream with record
      Initialized    : Boolean;
      Buffer_Tx      : aliased Byte_Array (Buffer_Index'Range);
      Buffer_Rx      : aliased Byte_Array (Buffer_Index'Range);

      Baud_Rate      : STM32.USARTs.Baud_Rates;
      UART           : access STM32.USARTs.USART;
      AF             : STM32.GPIO_Alternate_Function;
      Tx_Pin         : STM32.GPIO.GPIO_Point;
      Rx_Pin         : STM32.GPIO.GPIO_Point;
      DMA_Ctrl       : access STM32.DMA.DMA_Controller;
      DMA_Stream_Tx  : STM32.DMA.DMA_Stream_Selector;
      DMA_Channel_Tx : STM32.DMA.DMA_Channel_Selector;
      DMA_Stream_Rx  : STM32.DMA.DMA_Stream_Selector;
      DMA_Channel_Rx : STM32.DMA.DMA_Channel_Selector;
   end record;

end AMC_UART;
