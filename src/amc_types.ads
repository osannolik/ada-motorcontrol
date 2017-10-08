with HAL;
with Interfaces;

package AMC_Types is
   --  @summary
   --  Ada Motor Controller common types
   --
   --  @description
   --  This package defines a set of types that can be used across the project.
   --

   subtype UInt32 is HAL.UInt32;
   subtype UInt16 is HAL.UInt16;
   subtype UInt8 is HAL.UInt8;
   subtype Int32 is Interfaces.Integer_32;
   subtype Int16 is Interfaces.Integer_16;
   subtype Int8 is Interfaces.Integer_8;
   subtype Byte_Array is HAL.UInt8_Array;

   Empty_Byte_Array : constant Byte_Array (1 .. 0) := (others => 0);

   subtype Frequency_Hz is Float;
   subtype Seconds is Float;

   subtype Percent is Float range 0.0 .. 100.0;

   subtype Duty_Cycle is Percent;
   --  Represents duty cycle given in percent 0 - 100

   subtype Voltage_V is Float;
   --  Represents an electric voltage

   subtype Current_A is Float;
   --  Represents an electric current

   type Temperature_DegC is new Float;

   type Temperature_K is new Float;

   type Angle_Deg is new Float;
   --  An angle

   type Angle_Rad is new Float;
   --  An angle

   subtype Angle_Erad is Angle_Rad;
   --  Electrical angle, i.e. the rotor angle compensated for motor pole pairs

   type Speed_Rpm is new Float;
   --  Angular velocity of rotor given in mechanical angle domain

   subtype Speed_Erpm is Speed_Rpm;
   --  Angular velocity of rotor given in electrical angle domain

   type Speed_Radps is new Float;
   --  Angular velocity of rotor given in mechanical angle domain

   subtype Speed_Eradps is Speed_Radps;
   --  Angular velocity of rotor given in electrical angle domain


   --  Defines a set of controller modes
   type Ctrl_Mode is
      (Off,
       --  The motor is not controlled, no switching
       Normal,
       --  The motor is controlled according to an input signal
       Alignment,
       --  The motor is controlled in such a way as to define the rotor angle
       Speed
       --  Control the motor speed to a specified set-point
      );

   --  Define the type of available sensors
   type Position_Sensor is (None, Hall, Encoder);

   --  Defines the phases
   type Phase is (A, B, C);

   --  Describes where on the PWM waveform the signals shall be aligned
   type PWM_Alignment is
      (Edge,
       --  Positive edge
       Center
       --  Center of positive part
      );

   function To_Kelvin (DegC : in Temperature_DegC)
                       return Temperature_K
   with
      Inline;
   --  @param DegC Input value represented in degrees celcius
   --  @return Corresponding temperature in Kelvin

   function To_DegC (Kelvin : in Temperature_K)
                     return Temperature_DegC
   with
      Inline;
   --  @param Kelvin Input value represented in Kelvin
   --  @return Corresponding temperature in degrees celcius

   --  This angle type contains calculated values of Sin(Angle) and Cos(Angle)
   type Angle is tagged record
      Angle : Angle_Rad;
      --  The angle in radians
      Sin   : Float;
      --  Sin(Angle)
      Cos   : Float;
      --  Cos(Angle)
   end record;

   procedure Set (X : in out Angle; Angle_In : in Angle_Rad);
   --  Sets the angle value and calculates Sin and Cos of the angle
   --  @param X The angle object
   --  @param Angle_In The angle is set to this value

   function Compose (Angle_In : in Angle_Rad) return Angle;
   --  Calculates Sin and Cos of the angle and creates an angle object
   --  @param Angle_In The angle is set to this value
   --  @return The angle object

   --  A three-dimensional type representing a stator fixed value
   type Abc is tagged record
      A : Float;
      B : Float;
      C : Float;
   end record;

   --  A two-dimensional type representing a rotor fixed value
   type Dq is tagged record
      D : Float;
      Q : Float;
   end record;

   --  A two-dimensional type representing a stator fixed value
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
   --  Calculates the euclidean norm of X
   --  @param X

   procedure Normalize (X : in out Abc);
   --  Normalizes the components of X such that the magnitude is 1
   --  @param X

   function To_Alfa_Beta (X : in Abc'Class) return Alfa_Beta;
   --  Transform a three-dimensional stator fixed value to a two-dimensional
   --  stator fixed value.
   --  @param X The three-dimensional stator fixed value
   --  @return The two-dimensional stator fixed value

   function Clarke (X : in Abc'Class) return Alfa_Beta renames To_Alfa_Beta;
   --  Transform a three-dimensional stator fixed value to a two-dimensional
   --  stator fixed value.
   --  @param X The three-dimensional stator fixed value
   --  @return The two-dimensional stator fixed value

   function To_Dq (X : in Abc'Class;
                   Angle : in Angle_Rad) return Dq;
   --  Transform a three-dimensional stator fixed value to a two-dimensional
   --  rotor fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The three-dimensional stator fixed value
   --  @param Angle Stator-to-rotor angle
   --  @return The two-dimensional rotor fixed value

   function To_Dq (X : in Abc'Class;
                   Angle_In : in Angle'Class) return Dq;
   --  Transform a three-dimensional stator fixed value to a two-dimensional
   --  rotor fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The three-dimensional stator fixed value
   --  @param Angle_In Stator-to-rotor angle
   --  @return The two-dimensional rotor fixed value


   function "+"(X, Y : in Alfa_Beta) return Alfa_Beta;

   function "-"(X, Y : in Alfa_Beta) return Alfa_Beta;

   function "*"(X : in Alfa_Beta; c : in Float) return Alfa_Beta;

   function "*"(c : in Float; X : in Alfa_Beta) return Alfa_Beta;

   function "/"(X : in Alfa_Beta; c : in Float) return Alfa_Beta;

   function Magnitude (X : in Alfa_Beta) return Float
      with
         Inline;
   --  Calculates the euclidean norm of X
   --  @param X

   procedure Normalize (X : in out Alfa_Beta);
   --  Normalizes the components of X such that the magnitude is 1
   --  @param X

   function To_Abc (X : in Alfa_Beta'Class) return Abc;
   --  Transform a two-dimensional stator fixed value to a three-dimensional
   --  stator fixed value.
   --  @param X The two-dimensional stator fixed value
   --  @return The three-dimensional stator fixed value

   function To_Dq (X : in Alfa_Beta'Class;
                   Angle : in Angle_Rad) return Dq;
   --  Transform a two-dimensional stator fixed value to a two-dimensional
   --  rotor fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The two-dimensional stator fixed value
   --  @param Angle Stator-to-rotor angle
   --  @return The two-dimensional rotor fixed value

   function To_Dq (X : in Alfa_Beta'Class;
                   Angle_In : in Angle'Class) return Dq;
   --  Transform a two-dimensional stator fixed value to a two-dimensional
   --  rotor fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The two-dimensional stator fixed value
   --  @param Angle_In Stator-to-rotor angle
   --  @return The two-dimensional rotor fixed value

   function Clarke_Inv (X : in Alfa_Beta'Class) return Abc renames To_Abc;
   --  Transform a two-dimensional stator fixed value to a three-dimensional
   --  stator fixed value.
   --  @param X The two-dimensional stator fixed value
   --  @return The three-dimensional stator fixed value

   function Park (X : in Alfa_Beta'Class;
                  Angle : in Angle_Rad) return Dq renames To_Dq;
   --  Transform a two-dimensional stator fixed value to a two-dimensional
   --  rotor fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The two-dimensional stator fixed value
   --  @param Angle Stator-to-rotor angle
   --  @return The two-dimensional rotor fixed value

   function Park (X : in Alfa_Beta'Class;
                  Angle_In : in Angle'Class) return Dq renames To_Dq;
   --  Transform a two-dimensional stator fixed value to a two-dimensional
   --  rotor fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The two-dimensional stator fixed value
   --  @param Angle_In Stator-to-rotor angle
   --  @return The two-dimensional rotor fixed value

   function "+"(X, Y : in Dq) return Dq;

   function "-"(X, Y : in Dq) return Dq;

   function "*"(X : in Dq; c : in Float) return Dq;

   function "*"(c : in Float; X : in Dq) return Dq;

   function "/"(X : in Dq; c : in Float) return Dq;

   function Magnitude (X : in Dq) return Float
      with
         Inline;
   --  Calculates the euclidean norm of X
   --  @param X

   procedure Normalize (X : in out Dq);
   --  Normalizes the components of X such that the magnitude is 1
   --  @param X

   function To_Abc (X : in Dq'Class;
                    Angle : in Angle_Rad) return Abc;
   --  Transform a two-dimensional rotor fixed value to a three-dimensional
   --  stator fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The two-dimensional rotor fixed value
   --  @param Angle Stator-to-rotor angle
   --  @return The three-dimensional stator fixed value

   function To_Alfa_Beta (X : in Dq'Class;
                          Angle : in Angle_Rad)
                          return Alfa_Beta;
   --  Transform a two-dimensional rotor fixed value to a two-dimensional
   --  stator fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The two-dimensional rotor fixed value
   --  @param Angle Stator-to-rotor angle
   --  @return The two-dimensional stator fixed value

   function Park_Inv (X : in Dq'Class;
                      Angle : in Angle_Rad)
                      return Alfa_Beta renames To_Alfa_Beta;
   --  Transform a two-dimensional rotor fixed value to a two-dimensional
   --  stator fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The two-dimensional rotor fixed value
   --  @param Angle Stator-to-rotor angle
   --  @return The two-dimensional stator fixed value

   function To_Alfa_Beta (X : in Dq'Class;
                         Angle_In : in Angle'Class) return Alfa_Beta;
   --  Transform a two-dimensional rotor fixed value to a two-dimensional
   --  stator fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The two-dimensional rotor fixed value
   --  @param Angle_In Stator-to-rotor angle
   --  @return The two-dimensional stator fixed value

   function Park_Inv (X : in Dq'Class;
                      Angle_In : in Angle'Class)
                      return Alfa_Beta renames To_Alfa_Beta;
   --  Transform a two-dimensional rotor fixed value to a two-dimensional
   --  stator fixed value, assuming a stator-to-rotor angle Angle.
   --  @param X The two-dimensional rotor fixed value
   --  @param Angle_In Stator-to-rotor angle
   --  @return The two-dimensional stator fixed value

   --  Defines the set of reference frames
   type Reference_Frame_Type is
      (Stator_Abc,
       --  Three-dimensional stator value
       Stator_Ab,
       --  Three-dimensional stator value
       Rotor
       --  Two-dimensional rotor value
      );

   --  A variant type for respresenting a space vector value within a given
   --  reference frame.
   type Space_Vector
      (Reference_Frame : Reference_Frame_Type := Rotor) is record
      case Reference_Frame is
         when Stator_Abc =>
            Stator_Fixed_Abc : Abc;

         when Stator_Ab =>
            Stator_Fixed_Ab : Alfa_Beta;

         when Rotor =>
            Rotor_Fixed : Dq;

      end case;
   end record;

   function To_Rotor_Fixed (X        : in Space_Vector;
                            Angle_In : in Angle'Class)
                            return Dq;
   --  Transform a space vector to its corresponding rotor fixed representation.
   --  @param X The space vector
   --  @param Angle Stator-to-rotor angle

end AMC_Types;
