with STM32.Device;
with STM32.ADC;
with STM32.GPIO;
with STM32.DMA;
with Ada.Interrupts.Names;
with System;
with AMC.Board;

package AMC.ADC is
   --  Analog to digital conversion
   --  Interfaces the mcu adc peripheral

   Regular_Conversion_Frequency : constant Positive := 14_000;

   Regulars_ADC : STM32.ADC.Analog_To_Digital_Converter renames STM32.Device.ADC_1;
   Multi_Main_ADC : STM32.ADC.Analog_To_Digital_Converter renames STM32.Device.ADC_1;

   DMA_Ctrl : STM32.DMA.DMA_Controller renames STM32.Device.DMA_2;

   DMA_Stream : constant STM32.DMA.DMA_Stream_Selector := STM32.DMA.Stream_0;


   Sampling_Time_Regular : STM32.ADC.Channel_Sampling_Times renames
      STM32.ADC.Sample_480_Cycles;
   Sampling_Time_Injected : STM32.ADC.Channel_Sampling_Times renames
      STM32.ADC.Sample_3_Cycles;

   type ADC_Readings is
      (I_A, I_B, I_C, EMF_A, EMF_B, EMF_C, Bat_Sense, Board_Temp);

   subtype ADC_Readings_Inj is ADC_Readings range I_A .. EMF_C;
   subtype ADC_Readings_Reg is ADC_Readings range Bat_Sense .. Board_Temp;

   type Injected_Samples_Array is array (ADC_Readings_Inj'Range) of UInt16;
   type Regular_Samples_Array is array (ADC_Readings_Reg'Range) of UInt16;
   for Regular_Samples_Array'Component_Size use 16;

   subtype Rank is STM32.ADC.Regular_Channel_Rank;

   type ADC_Reading is record
      Pin          : STM32.GPIO.GPIO_Point;
      ADC_Point    : STM32.ADC.ADC_Point;
      Channel_Rank : Rank;
   end record;

   type ADC_Readings_Array is array (ADC_Readings'Range) of ADC_Reading;

   type Object is tagged limited record
      Initialized  : Boolean := False;
   end record;

   function Get_Sample (Reading : in ADC_Readings)
      return UInt16;

   function Is_Initialized (This : in Object)
      return Boolean;

   procedure Initialize (This : in out Object);

   protected Handler is
      pragma Interrupt_Priority(System.Interrupt_Priority'Last);

      function Get_Injected_Samples return Injected_Samples_Array;
      entry Await_New_Samples (Injected_Samples : out Injected_Samples_Array);

   private

      Samples : Injected_Samples_Array := (others => 0);
      New_Samples : Boolean := False;

      procedure ISR with
        Attach_Handler => Ada.Interrupts.Names.ADC_Interrupt;

   end Handler;


private

   --  Mapping between reading enum and corresponding pin etc.
   Readings_ADC_Settings : constant ADC_Readings_Array :=
      ((I_A)        => (Pin          => AMC.Board.ADC_I_A_Pin,
                        ADC_Point    => AMC.Board.ADC_I_A_Point,
                        Channel_Rank => 1),
       (I_B)        => (Pin          => AMC.Board.ADC_I_B_Pin,
                        ADC_Point    => AMC.Board.ADC_I_B_Point,
                        Channel_Rank => 1),
       (I_C)        => (Pin          => AMC.Board.ADC_I_C_Pin,
                        ADC_Point    => AMC.Board.ADC_I_C_Point,
                        Channel_Rank => 1),
       (EMF_A)      => (Pin          => AMC.Board.ADC_EMF_A_Pin,
                        ADC_Point    => AMC.Board.ADC_EMF_A_Point,
                        Channel_Rank => 2),
       (EMF_B)      => (Pin          => AMC.Board.ADC_EMF_B_Pin,
                        ADC_Point    => AMC.Board.ADC_EMF_B_Point,
                        Channel_Rank => 2),
       (EMF_C)      => (Pin          => AMC.Board.ADC_EMF_C_Pin,
                        ADC_Point    => AMC.Board.ADC_EMF_C_Point,
                        Channel_Rank => 2),
       (Bat_Sense)  => (Pin          => AMC.Board.ADC_Bat_Sense_Pin,
                        ADC_Point    => AMC.Board.ADC_Bat_Sense_Point,
                        Channel_Rank => 1),
       (Board_Temp) => (Pin          => AMC.Board.ADC_Board_Temp_Pin,
                        ADC_Point    => AMC.Board.ADC_Board_Temp_Point,
                        Channel_Rank => 2));

   Regular_Samples : Regular_Samples_Array := (others => 0) with Volatile;

end AMC.ADC;
