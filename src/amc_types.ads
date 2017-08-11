package AMC_Types is
   --  Ada Motor Controller common types

   subtype Frequency_Hz is Float;
   subtype Seconds is Float;
   subtype Duty_Cycle is Float range 0.0 .. 100.0;

   subtype Voltage_V is Float;
   --  Represents an electric voltage

   subtype Current_A is Float;
   --  Represents an electric current

   type Idq is record
      Iq : Current_A;
      --  Quadrature component: torque

      Id : Current_A;
      --  Direct component: field flux linkage
   end record;
   --  Represents three phase currents in the dq-reference frame

end AMC_Types;
