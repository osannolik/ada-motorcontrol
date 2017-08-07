with STM32.Device;
with STM32.ADC;
with STM32.GPIO;
with STM32.DMA;
--  with Ada.Interrupts;
with Ada.Interrupts.Names;
with System;
with Ada.Synchronous_Task_Control;

package AMC.ADC is
   --  Analog to digital conversion
   --  Interfaces the mcu adc peripheral

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

   subtype Rank is STM32.ADC.Regular_Channel_Rank;

   type ADC_Reading is record
      Pin          : STM32.GPIO.GPIO_Point;
      ADC_Point    : STM32.ADC.ADC_Point;
      Channel_Rank : Rank;
   end record;

   type ADC_Readings_Array is array (ADC_Readings'Range) of ADC_Reading;

   type Object is tagged limited record
      Reading_Data : ADC_Readings_Array;
      Initialized  : Boolean := False;
   end record;

   function Is_Initialized (This : in Object)
      return Boolean;

   procedure Initialize (This : in out Object);

   function Get_Data_Test(Index : Integer) return UInt16;






--     Regular_Channel_EOC : Ada.Synchronous_Task_Control.Suspension_Object;
--
--     protected Handler is
--        pragma Interrupt_Priority(System.Interrupt_Priority'Last);
--
--        function Get_Samples return Injected_Samples_Array;
--
--     private
--
--        Samples : Injected_Samples_Array := (others => 0);
--
--        procedure IRQ_Handler with
--          Attach_Handler => Ada.Interrupts.Names.ADC_Interrupt;
--
--     end Handler;





   protected Handler is
      pragma Interrupt_Priority(System.Interrupt_Priority'Last);

      function Get_Samples return Injected_Samples_Array;
      entry Await_Event (Injected_Samples : out Injected_Samples_Array);

   private

      Samples : Injected_Samples_Array := (others => 0);

      Event_Occurred : Boolean := False;

      procedure IRQ_Handler with
        Attach_Handler => Ada.Interrupts.Names.ADC_Interrupt;

   end Handler;


private


end AMC.ADC;
