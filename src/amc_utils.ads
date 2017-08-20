with AMC_Types; use AMC_Types;

package AMC_Utils is

   One_Over_Sqrt3 : constant Float := 0.577350269;

   Sqrt3_Over_Two : constant Float := 0.866025404;

   Two_Over_Sqrt3 : constant Float := 1.0 / Sqrt3_Over_Two;

   procedure Saturate (X       : in out Dq;
                       Maximum : in Float;
                       Is_Sat  : out Boolean);

   function Sign (X : in Float)
                  return Float
   with
      Inline;

   function Fmod (X, Y : in Float)
                  return Float
   with
      Inline;

   function Wrap_To (X     : in Float;
                     Upper : in Float)
                     return Float
   with
      Inline;
   --  Wraps input X into [0, Upper] such that positive multiples of Upper map
   --  to Upper and negative multiples of Upper map to zero.
   --  Zero wraps to zero and Upper wraps to Upper

   function Max (X, Y : in Float)
                 return Float
   with
      Inline;

   function Min (X, Y : in Float)
                 return Float
   with
      Inline;

   function Max (X, Y : in Integer)
                 return Integer
   with
      Inline;

   function Min (X, Y : in Integer)
                 return Integer
   with
      Inline;

   function To_Kelvin (DegC : in Temperature_DegC)
                       return Temperature_K
   with
      Inline;

   function To_DegC (Kelvin : in Temperature_K)
                     return Temperature_DegC
   with
      Inline;

   type Timer is tagged limited record
      Time    : Seconds := 0.0;
      Timeout : Seconds := 0.0;
   end record;

   function Create (Timeout : in Seconds) return Timer;

   procedure Reset (T : in out Timer);

   function Tick (T         : in out Timer;
                  Time_Step : in Seconds) return Boolean;

   procedure Tick (T         : in out Timer;
                   Time_Step : in Seconds);

   function Is_Done (T : in out Timer) return Boolean;

end AMC_Utils;
