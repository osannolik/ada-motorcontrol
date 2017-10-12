with AMC_Types; use AMC_Types;

package AMC_Utils is
   --  @summary
   --  Ada Motor Controller utilities
   --
   --  @description
   --  Provides a collection of utilities and smaller helper functions
   --

   One_Over_Sqrt3 : constant Float := 0.577350269;

   Sqrt3_Over_Two : constant Float := 0.866025404;

   Two_Over_Sqrt3 : constant Float := 1.0 / Sqrt3_Over_Two;

   procedure Saturate (X       : in out Dq;
                       Maximum : in Float;
                       Is_Sat  : out Boolean);
   --  Limits the magnitude of X to be <= than Maximum.
   --  @param X Input value
   --  @param Maximum Upper limit of the magnitude of X
   --  @param Is_Sat True if X has been saturated.

   function Saturate (X       : in Float;
                      Maximum : in Float;
                      Minimum : in Float)
                      return Float;
   --  Limits the input X such that Minimum <= X_out <= Maximum.
   --  @param X Input value
   --  @param Maximum Upper limit of X
   --  @param Minimum Lower limit of X
   --  @return Saturated input

   function Sign (X : in Float)
                  return Float
   with
      Inline;
   --  @param X Input value
   --  @return 0 if X = 0, else sign of X

   function Fmod (X, Y : in Float)
                  return Float
   with
      Inline;
   --  @param X Input value
   --  @param Y Input value
   --  @return Floating point remainder of X/Y

   function Wrap_To (X     : in Float;
                     Upper : in Float)
                     return Float
   with
      Inline;
   --  Wraps input X into [0, Upper] such that positive multiples of Upper map
   --  to Upper and negative multiples of Upper map to zero.
   --  Zero wraps to zero and Upper wraps to Upper.
   --  @param X Input value
   --  @param Upper Upper interval value
   --  @return Wrapped input

   function Max (X, Y : in Float)
                 return Float
   with
      Inline;
   --  @param X Input value
   --  @param Y Input value
   --  @return The largest value of X and Y

   function Min (X, Y : in Float)
                 return Float
   with
      Inline;
   --  @param X Input value
   --  @param Y Input value
   --  @return The smallest value of X and Y

   function Max (X, Y : in Integer)
                 return Integer
   with
      Inline;
   --  @param X Input value
   --  @param Y Input value
   --  @return The largest value of X and Y

   function Min (X, Y : in Integer)
                 return Integer
   with
      Inline;
   --  @param X Input value
   --  @param Y Input value
   --  @return The smallest value of X and Y

   --  A timer object
   type Timer is tagged limited record
      Time    : Seconds := 0.0;
      Timeout : Seconds := 0.0;
   end record;

   function Create (Timeout : in Seconds) return Timer;
   --  Creates a timer object that times out after the specified time.
   --  @param Timeout Time until next timeout in seconds
   --  @return A timer object

   procedure Reset (T : in out Timer);
   --  Resets a timer object to its set timeout value.
   --  @param T A timer object

   procedure Reset (T       : in out Timer;
                    Timeout : in Seconds);
   --  Resets a timer object to the provided timout value.
   --  @param T A timer object
   --  @param Timeout Time until next timeout in seconds

   function Tick (T         : in out Timer;
                  Time_Step : in Seconds) return Boolean;
   --  Let the timer tick with the specified time step.
   --  @param T A timer object
   --  @param Time_Step The time since last call to Tick
   --  @return True if the timer as timed out

   procedure Tick (T         : in out Timer;
                   Time_Step : in Seconds);
   --  Let the timer tick with the specified time step.
   --  @param T A timer object
   --  @param Time_Step The time since last call to Tick

   function Is_Done (T : in out Timer) return Boolean;
   --  Timeout status.
   --  @param T A timer object
   --  @return True if the timer as timed out

end AMC_Utils;
