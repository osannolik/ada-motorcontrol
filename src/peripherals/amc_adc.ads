with STM32.Device;
with STM32.ADC;
with STM32.GPIO;
with STM32.DMA;
with Ada.Interrupts.Names;
with AMC_Types;
with AMC_Board;
with Config;

package AMC_ADC is
   --  Analog to digital conversion
   --  Interfaces the mcu adc peripheral


   type ADC_Readings is
      (I_A, I_B, I_C, EMF_A, EMF_B, EMF_C, Bat_Sense, Board_Temp, Ext_V);

   subtype ADC_Readings_Inj is ADC_Readings range I_A .. EMF_C;
   subtype ADC_Readings_Reg is ADC_Readings range Bat_Sense .. Ext_V;

   type Injected_Samples_Array is
      array (ADC_Readings_Inj'Range) of AMC_Types.Voltage_V;


   function Get_Sample (Reading : in ADC_Readings)
      return AMC_Types.Voltage_V;

   function Is_Initialized
      return Boolean;

   procedure Initialize;

   protected Handler is
      pragma Interrupt_Priority (Config.ADC_ISR_Prio);

      function Get_Injected_Samples return Injected_Samples_Array;
      entry Await_New_Samples (Phase_Voltage_Samples : out AMC_Types.Abc;
                               Phase_Current_Samples : out AMC_Types.Abc);
   private

      Samples : Injected_Samples_Array := (others => 0.0);
      New_Samples : Boolean := False;

      procedure ISR with
        Attach_Handler => Ada.Interrupts.Names.ADC_Interrupt;

   end Handler;

private

   type Regular_Samples_Array is
      array (ADC_Readings_Reg'Range) of AMC_Types.UInt16;

   for Regular_Samples_Array'Component_Size use 16;

   subtype Rank is STM32.ADC.Regular_Channel_Rank;

   type ADC_Reading is record
      Pin          : STM32.GPIO.GPIO_Point;
      ADC_Point    : STM32.ADC.ADC_Point;
      Channel_Rank : Rank;
   end record;

   type ADC_Readings_Array is array (ADC_Readings'Range) of ADC_Reading;

   Initialized : Boolean := False;

   ADC_V_Per_Lsb : constant Float := AMC_Board.ADC_Vref / 4095.0; --  12 bit

   Regular_Conversion_Frequency : constant Positive := 14_000;

   Regulars_ADC : STM32.ADC.Analog_To_Digital_Converter renames STM32.Device.ADC_1;

   Multi_Main_ADC : STM32.ADC.Analog_To_Digital_Converter renames STM32.Device.ADC_1;

   DMA_Ctrl : STM32.DMA.DMA_Controller renames STM32.Device.DMA_2;

   DMA_Stream : constant STM32.DMA.DMA_Stream_Selector := STM32.DMA.Stream_0;

   Sampling_Time_Regular : STM32.ADC.Channel_Sampling_Times renames
      STM32.ADC.Sample_480_Cycles;

   Sampling_Time_Injected : STM32.ADC.Channel_Sampling_Times renames
      STM32.ADC.Sample_3_Cycles;

   --  Mapping between reading enum and corresponding pin etc.
   Readings_ADC_Settings : constant ADC_Readings_Array :=
      ((I_A)        => (Pin          => AMC_Board.ADC_I_A_Pin,
                        ADC_Point    => AMC_Board.ADC_I_A_Point,
                        Channel_Rank => 1),
       (I_B)        => (Pin          => AMC_Board.ADC_I_B_Pin,
                        ADC_Point    => AMC_Board.ADC_I_B_Point,
                        Channel_Rank => 1),
       (I_C)        => (Pin          => AMC_Board.ADC_I_C_Pin,
                        ADC_Point    => AMC_Board.ADC_I_C_Point,
                        Channel_Rank => 1),
       (EMF_A)      => (Pin          => AMC_Board.ADC_EMF_A_Pin,
                        ADC_Point    => AMC_Board.ADC_EMF_A_Point,
                        Channel_Rank => 2),
       (EMF_B)      => (Pin          => AMC_Board.ADC_EMF_B_Pin,
                        ADC_Point    => AMC_Board.ADC_EMF_B_Point,
                        Channel_Rank => 2),
       (EMF_C)      => (Pin          => AMC_Board.ADC_EMF_C_Pin,
                        ADC_Point    => AMC_Board.ADC_EMF_C_Point,
                        Channel_Rank => 2),
       (Bat_Sense)  => (Pin          => AMC_Board.ADC_Bat_Sense_Pin,
                        ADC_Point    => AMC_Board.ADC_Bat_Sense_Point,
                        Channel_Rank => 1),
       (Board_Temp) => (Pin          => AMC_Board.ADC_Board_Temp_Pin,
                        ADC_Point    => AMC_Board.ADC_Board_Temp_Point,
                        Channel_Rank => 2),
       (Ext_V)      => (Pin          => AMC_Board.ADC_Ext_V_Pin,
                        ADC_Point    => AMC_Board.ADC_Ext_V_Point,
                        Channel_Rank => 3));

   Regular_Samples : Regular_Samples_Array := (others => 0) with Volatile;

--     Phase_Voltage_To_Reading : constant array (AMC_Types.Phase'Range) of ADC_Readings :=
--        ((AMC_Types.A) => EMF_A,
--         (AMC_Types.B) => EMF_B,
--         (AMC_Types.C) => EMF_C);
--
--     Phase_Current_To_Reading : constant array (AMC_Types.Phase'Range) of ADC_Readings :=
--        ((AMC_Types.A) => I_A,
--         (AMC_Types.B) => I_B,
--         (AMC_Types.C) => I_C);

end AMC_ADC;
