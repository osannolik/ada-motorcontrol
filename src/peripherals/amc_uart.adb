with HAL; use HAL;

package body AMC_UART is

   --  Gets the rx buffer index where the next data byte will be written
   function Current_Rx_Index return Natural is
      (Buffer_Rx'Length - Natural (STM32.DMA.Items_Transferred (This   => DMA_Ctrl,
                                                                Stream => DMA_Stream_Rx)));

   procedure Initialize
   is
      use STM32.USARTs;

      DMA_Stream_Config : STM32.DMA.DMA_Stream_Configuration;
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
          AF     => AF);

      --  Configure Uart peripheral
      STM32.Device.Enable_Clock (UART);

      Disable (UART);

      Set_Baud_Rate    (UART, Baud_Rate);
      Set_Mode         (UART, Tx_Rx_Mode);
      Set_Stop_Bits    (UART, Stopbits_1);
      Set_Word_Length  (UART, Word_Length_8);
      Set_Parity       (UART, No_Parity);
      Set_Flow_Control (UART, No_Flow_Control);


      --  Configure DMA for transmitting
      STM32.Device.Enable_Clock (DMA_Ctrl);

      STM32.DMA.Reset (DMA_Ctrl, DMA_Stream_Tx);

      STM32.DMA.Disable (DMA_Ctrl, DMA_Stream_Tx);

      DMA_Stream_Config :=
         STM32.DMA.DMA_Stream_Configuration'
         (Channel                      => DMA_Channel_Tx,
          Direction                    => STM32.DMA.Memory_To_Peripheral,
          Increment_Peripheral_Address => False,
          Increment_Memory_Address     => True,
          Peripheral_Data_Format       => STM32.DMA.Bytes,
          Memory_Data_Format           => STM32.DMA.Bytes,
          Operation_Mode               => STM32.DMA.Normal_Mode,
          Priority                     => STM32.DMA.Priority_Low,
          FIFO_Enabled                 => False,
          FIFO_Threshold               => STM32.DMA.FIFO_Threshold_Full_Configuration,
          Memory_Burst_Size            => STM32.DMA.Memory_Burst_Single,
          Peripheral_Burst_Size        => STM32.DMA.Peripheral_Burst_Single);

      STM32.DMA.Configure (DMA_Ctrl, DMA_Stream_Tx, DMA_Stream_Config);

      STM32.DMA.Clear_All_Status (DMA_Ctrl, DMA_Stream_Tx);

      --  Configure DMA for receive
      STM32.DMA.Reset (DMA_Ctrl, DMA_Stream_Rx);

      STM32.DMA.Disable (DMA_Ctrl, DMA_Stream_Rx);

      DMA_Stream_Config :=
         STM32.DMA.DMA_Stream_Configuration'
         (Channel                      => DMA_Channel_Rx,
          Direction                    => STM32.DMA.Peripheral_To_Memory,
          Increment_Peripheral_Address => False,
          Increment_Memory_Address     => True,
          Peripheral_Data_Format       => STM32.DMA.Bytes,
          Memory_Data_Format           => STM32.DMA.Bytes,
          Operation_Mode               => STM32.DMA.Circular_Mode,
          Priority                     => STM32.DMA.Priority_Low,
          FIFO_Enabled                 => False,
          FIFO_Threshold               => STM32.DMA.FIFO_Threshold_Full_Configuration,
          Memory_Burst_Size            => STM32.DMA.Memory_Burst_Single,
          Peripheral_Burst_Size        => STM32.DMA.Peripheral_Burst_Single);

      STM32.DMA.Configure (DMA_Ctrl, DMA_Stream_Rx, DMA_Stream_Config);

      STM32.DMA.Clear_All_Status (DMA_Ctrl, DMA_Stream_Rx);

      --  Enable and start


      Enable_DMA_Transmit_Requests (UART);
      Enable_DMA_Receive_Requests (UART);

      STM32.DMA.Start_Transfer
         (DMA_Ctrl,
          DMA_Stream_Rx,
          Source      => UART_Data_Address,
          Destination => Buffer_Rx'Address,
          Data_Count  => Buffer_Rx'Length);

      Enable (UART);

      Initialized := True;
   end Initialize;

   function Is_Busy_Tx return Boolean is
      (STM32.DMA.Enabled (DMA_Ctrl, DMA_Stream_Tx));

   procedure Send_Data (Data : access Byte_Array)
   is
   begin
      --  Make sure the stream is not busy
      if Is_Busy_Tx then
         raise Busy_Transmitting;
      end if;

      if Data'Length > 0 then
         Buffer_Tx (Data'Range) := Data.all;

         STM32.DMA.Clear_All_Status (DMA_Ctrl, DMA_Stream_Tx);

         STM32.DMA.Disable (DMA_Ctrl, DMA_Stream_Tx);

         STM32.DMA.Configure_Data_Flow
            (DMA_Ctrl,
             DMA_Stream_Tx,
             Source      => Buffer_Tx_Address,
             Destination => UART_Data_Address,
             Data_Count  => Data'Length);

         STM32.DMA.Enable (DMA_Ctrl, DMA_Stream_Tx);
      end if;
   end Send_Data;

   function Receive_Data return Byte_Array is
      N : constant Natural := Current_Rx_Index;
      Data : Byte_Array (Buffer_Index'First .. N - 1);
   begin
      STM32.DMA.Disable (DMA_Ctrl, DMA_Stream_Rx);

      Data := Buffer_Rx (Buffer_Index'First .. N - 1);

      STM32.DMA.Set_NDT (This       => DMA_Ctrl,
                         Stream     => DMA_Stream_Rx,
                         Data_Count => Buffer_Rx'Length);

      STM32.DMA.Enable (DMA_Ctrl, DMA_Stream_Rx);

      --  Could have missed a byte or two when the stream was disabled...
      --  TODO: Make it a double buffered?

      return Data;
   end Receive_Data;

   function Is_Initialized
      return Boolean is (Initialized);

end AMC_UART;
