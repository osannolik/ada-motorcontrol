with Generic_DQ;

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

   type Phase is (A, B, C);

   type Phase_Voltages is array (Phase'Range) of Voltage_V;

   type Phase_Currents is array (Phase'Range) of Current_A;

   generic
      type Basetype is private;
   package TestType is
      type Dq is record
         D : Basetype;
         Q : Basetype;
      end record;
   end TestType;

   package Dq_Float is new TestType (Voltage_V);

   subtype Dq_Float_Type is Dq_Float.Dq;

   Dq_Test_2 : Dq_Float.Dq;

   Dq_Test : Dq_Float_Type;

end AMC_Types;
