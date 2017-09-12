with HAL; use HAL;
with AMC_Board;
with STM32.Device;

package body AMC_UART is

   function Current_Rx_Index (Stream : in UART_Stream)
                              return Natural;
   procedure Initialize (Stream : in out UART_Stream);


   --  Gets the rx buffer index where the next data byte will be written
   function Current_Rx_Index (Stream : in UART_Stream)
                              return Natural is
   begin
      return Stream.Buffer_Rx'Length - Natural
         (STM32.DMA.Items_Transferred (This   => Stream.DMA_Ctrl.all,
                                       Stream => Stream.DMA_Stream_Rx));
   end Current_Rx_Index;

   procedure Initialize (Stream : in out UART_Stream) is
      use STM32.USARTs;

      DMA_Stream_Config : STM32.DMA.DMA_Stream_Configuration;
      Pins : constant STM32.GPIO.GPIO_Points :=
         (Stream.Tx_Pin, Stream.Rx_Pin);

      UART     : STM32.USARTs.USART renames Stream.UART.all;
      DMA_Ctrl : STM32.DMA.DMA_Controller renames Stream.DMA_Ctrl.all;
   begin

      --  Configure IO
      STM32.Device.Enable_Clock (Pins);

      STM32.GPIO.Configure_IO (Points => Pins,
                               Config =>
                                  (Mode        => STM32.GPIO.Mode_AF,
                                   Output_Type => STM32.GPIO.Push_Pull,
                                   Speed       => STM32.GPIO.Speed_50MHz,
                                   Resistors   => STM32.GPIO.Pull_Up));

      STM32.GPIO.Configure_Alternate_Function
         (Points => Pins,
          AF     => Stream.AF);

      --  Configure Uart peripheral
      STM32.Device.Enable_Clock (UART);

      Disable (UART);

      Set_Baud_Rate    (UART, Stream.Baud_Rate);
      Set_Mode         (UART, Tx_Rx_Mode);
      Set_Stop_Bits    (UART, Stopbits_1);
      Set_Word_Length  (UART, Word_Length_8);
      Set_Parity       (UART, No_Parity);
      Set_Flow_Control (UART, No_Flow_Control);


      --  Configure DMA for transmitting
      STM32.Device.Enable_Clock (DMA_Ctrl);

      STM32.DMA.Reset (DMA_Ctrl, Stream.DMA_Stream_Tx);

      STM32.DMA.Disable (DMA_Ctrl, Stream.DMA_Stream_Tx);

      DMA_Stream_Config :=
         STM32.DMA.DMA_Stream_Configuration'
         (Channel                      => Stream.DMA_Channel_Tx,
          Direction                    => STM32.DMA.Memory_To_Peripheral,
          Increment_Peripheral_Address => False,
          Increment_Memory_Address     => True,
          Peripheral_Data_Format       => STM32.DMA.Bytes,
          Memory_Data_Format           => STM32.DMA.Bytes,
          Operation_Mode               => STM32.DMA.Normal_Mode,
          Priority                     => STM32.DMA.Priority_Medium,
          FIFO_Enabled                 => False,
          FIFO_Threshold               => STM32.DMA.FIFO_Threshold_Full_Configuration,
          Memory_Burst_Size            => STM32.DMA.Memory_Burst_Single,
          Peripheral_Burst_Size        => STM32.DMA.Peripheral_Burst_Single);

      STM32.DMA.Configure (DMA_Ctrl, Stream.DMA_Stream_Tx, DMA_Stream_Config);

      STM32.DMA.Clear_All_Status (DMA_Ctrl, Stream.DMA_Stream_Tx);

      --  Configure DMA for receive
      STM32.DMA.Reset (DMA_Ctrl, Stream.DMA_Stream_Rx);

      STM32.DMA.Disable (DMA_Ctrl, Stream.DMA_Stream_Rx);

      DMA_Stream_Config :=
         STM32.DMA.DMA_Stream_Configuration'
         (Channel                      => Stream.DMA_Channel_Rx,
          Direction                    => STM32.DMA.Peripheral_To_Memory,
          Increment_Peripheral_Address => False,
          Increment_Memory_Address     => True,
          Peripheral_Data_Format       => STM32.DMA.Bytes,
          Memory_Data_Format           => STM32.DMA.Bytes,
          Operation_Mode               => STM32.DMA.Circular_Mode,
          Priority                     => STM32.DMA.Priority_Medium,
          FIFO_Enabled                 => False,
          FIFO_Threshold               => STM32.DMA.FIFO_Threshold_Full_Configuration,
          Memory_Burst_Size            => STM32.DMA.Memory_Burst_Single,
          Peripheral_Burst_Size        => STM32.DMA.Peripheral_Burst_Single);

      STM32.DMA.Configure (DMA_Ctrl, Stream.DMA_Stream_Rx, DMA_Stream_Config);

      STM32.DMA.Clear_All_Status (DMA_Ctrl, Stream.DMA_Stream_Rx);

      --  Enable and start
      Enable_DMA_Transmit_Requests (UART);
      Enable_DMA_Receive_Requests (UART);

      STM32.DMA.Start_Transfer
         (DMA_Ctrl,
          Stream.DMA_Stream_Rx,
          Source      => Data_Register_Address (UART),
          Destination => Stream.Buffer_Rx'Address,
          Data_Count  => Stream.Buffer_Rx'Length);

      Enable (UART);

      Stream.Initialized := True;
   end Initialize;

   procedure Initialize_Default (Stream : in out UART_Stream) is
   begin
      Initialize (Stream         => Stream,
                  Baud_Rate      => 2_000_000,
                  UART           => AMC_Board.Uart_Peripheral'Access,
                  AF             => AMC_Board.Uart_GPIO_AF,
                  Tx_Pin         => AMC_Board.Uart_Tx_Pin,
                  Rx_Pin         => AMC_Board.Uart_Rx_Pin,
                  DMA_Ctrl       => STM32.Device.DMA_2'Access,
                  DMA_Stream_Tx  => STM32.DMA.Stream_7,
                  DMA_Channel_Tx => STM32.DMA.Channel_5,
                  DMA_Stream_Rx  => STM32.DMA.Stream_1,
                  DMA_Channel_Rx => STM32.DMA.Channel_5);
   end Initialize_Default;

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
                         DMA_Channel_Rx : STM32.DMA.DMA_Channel_Selector) is
   begin
      Stream.Baud_Rate      := Baud_Rate;
      Stream.UART           := UART;
      Stream.AF             := AF;
      Stream.Tx_Pin         := Tx_Pin;
      Stream.Rx_Pin         := Rx_Pin;
      Stream.DMA_Ctrl       := DMA_Ctrl;
      Stream.DMA_Stream_Tx  := DMA_Stream_Tx;
      Stream.DMA_Channel_Tx := DMA_Channel_Tx;
      Stream.DMA_Stream_Rx  := DMA_Stream_Rx;
      Stream.DMA_Channel_Rx := DMA_Channel_Rx;

      Initialize (Stream => Stream);
   end Initialize;

   function Is_Busy_Tx (Stream : in UART_Stream) return Boolean is
      (STM32.DMA.Enabled (Stream.DMA_Ctrl.all, Stream.DMA_Stream_Tx));

   overriding
   procedure Write (Stream : in out UART_Stream;
                    Data   : in AMC_Types.Byte_Array;
                    Sent   : out Natural) is
      DMA_Ctrl : STM32.DMA.DMA_Controller renames Stream.DMA_Ctrl.all;
   begin
      --  Make sure the stream is not busy
      if Is_Busy_Tx (Stream) then
         raise Busy_Transmitting;
      end if;

      Sent := Data'Length; --  Assume all are sent...

      if Data'Length > 0 then
         Stream.Buffer_Tx (Data'Range) := Data;

         STM32.DMA.Clear_All_Status (DMA_Ctrl, Stream.DMA_Stream_Tx);

         STM32.DMA.Disable (DMA_Ctrl, Stream.DMA_Stream_Tx);

         STM32.DMA.Configure_Data_Flow
            (DMA_Ctrl,
             Stream.DMA_Stream_Tx,
             Source      => Stream.Buffer_Tx'Address,
             Destination => STM32.USARTs.Data_Register_Address (Stream.UART.all),
             Data_Count  => Data'Length);

         STM32.DMA.Enable (DMA_Ctrl, Stream.DMA_Stream_Tx);
      end if;
   end Write;

   overriding
   function Read (Stream : in out UART_Stream)
                  return AMC_Types.Byte_Array is
      N : constant Natural := Current_Rx_Index (Stream);
      Data : Byte_Array (Buffer_Index'First .. N - 1);
      DMA_Ctrl : STM32.DMA.DMA_Controller renames Stream.DMA_Ctrl.all;
   begin
      STM32.DMA.Disable (DMA_Ctrl, Stream.DMA_Stream_Rx);

      Data := Stream.Buffer_Rx (Buffer_Index'First .. N - 1);

      STM32.DMA.Set_NDT (This       => DMA_Ctrl,
                         Stream     => Stream.DMA_Stream_Rx,
                         Data_Count => Stream.Buffer_Rx'Length);

      STM32.DMA.Enable (DMA_Ctrl, Stream.DMA_Stream_Rx);

      --  Could have missed a byte or two when the stream was disabled...
      --  TODO: Make it a double buffered?

      return Data;

   end Read;

   function Is_Initialized (Stream : in UART_Stream)
      return Boolean is (Stream.Initialized);

begin

   Initialize_Default (Stream => Stream);

end AMC_UART;
