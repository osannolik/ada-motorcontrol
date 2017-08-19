package PID is
   --  PID controller

   type Kpid is tagged record
      Kp       : Float;
      Ki       : Float;
      Kd       : Float;
      Integral : Float;
      E_Prev   : Float;
      Output   : Float;
   end record;

   function Compose (Kp, Ki, Kd : in Float) return Kpid;

   procedure Update (This     : in out Kpid;
                     Setpoint : in Float;
                     Actual   : in Float;
                     Ts       : in Float;
                     Is_Sat   : in Boolean);

   function Get_Output (This : in Kpid) return Float;

end PID;
