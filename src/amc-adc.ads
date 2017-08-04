with STM32.ADC;
with STM32.GPIO;


package AMC.ADC is
   --  Analog to digital conversion
   --  Interfaces the mcu adc peripheral

   Sampling_Time_Regular : STM32.ADC.Channel_Sampling_Times renames
      STM32.ADC.Sample_480_Cycles;
   Sampling_Time_Injected : STM32.ADC.Channel_Sampling_Times renames
      STM32.ADC.Sample_3_Cycles;

   type ADC_Readings is
      (I_A, I_B, I_C, EMF_A, EMF_B, EMF_C, Bat_Sense, Board_Temp);

   subtype ADC_Readings_Inj is ADC_Readings range I_A .. EMF_C;
   subtype ADC_Readings_Reg is ADC_Readings range Bat_Sense .. Board_Temp;

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

private


end AMC.ADC;
