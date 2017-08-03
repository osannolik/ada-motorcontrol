package AMC.Types is
   --  Ada Motor Controller common types

   subtype Frequency_Hz is Float;
   subtype Seconds is Float;
   subtype Duty_Cycle is Float range 0.0 .. 100.0;

end AMC.Types;
