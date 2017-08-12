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


   type Abc is tagged record
      A : Float;
      B : Float;
      C : Float;
   end record;

   type Dq is tagged record
      D : Float;
      Q : Float;
   end record;

   subtype junk is Abc;

   function "+"(X,Y : in Abc) return Abc;

   function "-"(X,Y : in Abc) return Abc;

   function "*"(X : in Abc; c : in Float) return Abc;

   function "*"(c : in Float; X : in Abc) return Abc;

   function "/"(X : in Abc; c : in Float) return Abc;

   function Magnitude(X : in Abc) return Float
      with
         Inline;

   procedure Normalize(X : in out Abc);

   function To_Dq(X : in Abc'Class) return Dq;


   function "+"(X,Y : in Dq) return Dq;

   function "-"(X,Y : in Dq) return Dq;

   function "*"(X : in Dq; c : in Float) return Dq;

   function "*"(c : in Float; X : in Dq) return Dq;

   function "/"(X : in Dq; c : in Float) return Dq;

   function Magnitude(X : in Dq) return Float
      with
         Inline;

   procedure Normalize(X : in out Dq);

   function To_Abc(X : in Dq'Class) return Abc;

end AMC_Types;
