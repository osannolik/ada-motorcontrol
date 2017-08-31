with HAL;

package AMC_Types is
   --  Ada Motor Controller common types

   subtype UInt32 is HAL.UInt32;
   subtype UInt16 is HAL.UInt16;
   subtype UInt8 is HAL.UInt8;
   subtype Byte_Array is HAL.UInt8_Array;

   Empty_Byte_Array : constant Byte_Array (1 .. 0) := (others => 0);

   subtype Frequency_Hz is Float;
   subtype Seconds is Float;
   subtype Duty_Cycle is Float range 0.0 .. 100.0;

   subtype Voltage_V is Float;
   --  Represents an electric voltage

   subtype Current_A is Float;
   --  Represents an electric current

   type Temperature_DegC is new Float;

   type Temperature_K is new Float;

   type Angle_Deg is new Float;

   type Angle_Rad is new Float;

   subtype Angle_Erad is Angle_Rad;
   --  Electrical angle, i.e. the rotor angle compensated for motor pole pairs

   type Ctrl_Mode is (Off, Normal, Alignment);

   type Phase is (A, B, C);

   type PWM_Alignment is (Edge, Center);

   type Angle is tagged record
      Angle : Angle_Rad;
      Sin   : Float;
      Cos   : Float;
   end record;

   procedure Set (X : in out Angle; Angle_In : in Angle_Rad);

   function Compose (Angle_In : in Angle_Rad) return Angle;

   type Abc is tagged record
      A : Float;
      B : Float;
      C : Float;
   end record;

   type Dq is tagged record
      D : Float;
      Q : Float;
   end record;

   type Alfa_Beta is tagged record
      Alfa : Float;
      Beta : Float;
   end record;

   function "+"(X, Y : in Abc) return Abc;

   function "+"(X : in Abc; c : in Float) return Abc;

   function "+"(c : in Float; X : in Abc) return Abc;

   function "-"(X, Y : in Abc) return Abc;

   function "*"(X : in Abc; c : in Float) return Abc;

   function "*"(c : in Float; X : in Abc) return Abc;

   function "/"(X : in Abc; c : in Float) return Abc;

   function Magnitude (X : in Abc) return Float
      with
         Inline;

   procedure Normalize (X : in out Abc);

   function To_Alfa_Beta (X : in Abc'Class) return Alfa_Beta;

   function Clarke (X : in Abc'Class) return Alfa_Beta renames To_Alfa_Beta;

   function To_Dq (X : in Abc'Class;
                   Angle : in Angle_Rad) return Dq;



   function "+"(X, Y : in Alfa_Beta) return Alfa_Beta;

   function "-"(X, Y : in Alfa_Beta) return Alfa_Beta;

   function "*"(X : in Alfa_Beta; c : in Float) return Alfa_Beta;

   function "*"(c : in Float; X : in Alfa_Beta) return Alfa_Beta;

   function "/"(X : in Alfa_Beta; c : in Float) return Alfa_Beta;

   function Magnitude (X : in Alfa_Beta) return Float
      with
         Inline;

   procedure Normalize (X : in out Alfa_Beta);

   function To_Abc (X : in Alfa_Beta'Class) return Abc;

   function To_Dq (X : in Alfa_Beta'Class;
                   Angle : in Angle_Rad) return Dq;

   function To_Dq (X : in Alfa_Beta'Class;
                   Angle_In : in Angle'Class) return Dq;

   function Clarke_Inv (X : in Alfa_Beta'Class) return Abc renames To_Abc;

   function Park (X : in Alfa_Beta'Class;
                  Angle : in Angle_Rad) return Dq renames To_Dq;

   function Park (X : in Alfa_Beta'Class;
                  Angle_In : in Angle'Class) return Dq renames To_Dq;

   function "+"(X, Y : in Dq) return Dq;

   function "-"(X, Y : in Dq) return Dq;

   function "*"(X : in Dq; c : in Float) return Dq;

   function "*"(c : in Float; X : in Dq) return Dq;

   function "/"(X : in Dq; c : in Float) return Dq;

   function Magnitude (X : in Dq) return Float
      with
         Inline;

   procedure Normalize (X : in out Dq);

   function To_Abc (X : in Dq'Class;
                    Angle : in Angle_Rad) return Abc;

   function To_Alfa_Beta (X : in Dq'Class;
                          Angle : in Angle_Rad)
                          return Alfa_Beta;

   function Park_Inv (X : in Dq'Class;
                      Angle : in Angle_Rad)
                      return Alfa_Beta renames To_Alfa_Beta;

   function To_Alfa_Beta (X : in Dq'Class;
                         Angle_In : in Angle'Class) return Alfa_Beta;

   function Park_Inv (X : in Dq'Class;
                      Angle_In : in Angle'Class)
                      return Alfa_Beta renames To_Alfa_Beta;
end AMC_Types;
