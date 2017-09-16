package PID is
   --  @summary
   --  PID controller
   --
   --  @description
   --  This package defines a very simple implementation of a conventional PID
   --  controller.
   --

   --  A PID object where the gain parameters are defined such that
   --  Output = Kp*e + Ki*Integral(e) + Kd*de/dt
   type Kpid is tagged record
      Kp       : Float;
      --  Proportional gain.
      Ki       : Float;
      --  Integral gain.
      Kd       : Float;
      --  Derivative gain.
      Integral : Float;
      --  Holds the error integrated over time.
      E_Prev   : Float;
      --  Holds the previous error value.
      Output   : Float;
      --  Holds the latest calculated control output.
   end record;

   function Compose (Kp, Ki, Kd : in Float) return Kpid;
   --  Create and reset a controller to use the specified gain parameters.
   --  @param Kp Proportional gain.
   --  @param Ki Integral gain.
   --  @param Kd Derivative gain.
   --  @return The PID object.

   procedure Update (This     : in out Kpid;
                     Setpoint : in Float;
                     Actual   : in Float;
                     Ts       : in Float;
                     Is_Sat   : in Boolean := False);
   --  Update the controller output.
   --  @param This The PID object.
   --  @param Setpoint The current set-point value.
   --  @param Actual The current actual value.
   --  @param Ts The time since last update.
   --  @param Is_Sat An optional parameter used by the anti-windup.
   --  Will stop integration if set True.

   function Get_Output (This : in Kpid) return Float;
   --  Get the latest calculated control output.
   --  @param This The PID object.
   --  @return The control output.

end PID;
