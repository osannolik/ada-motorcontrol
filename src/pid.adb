with AMC_Utils;

package body PID is


   function Compose (Kp, Ki, Kd : in Float) return Kpid
   is
      (Kpid'(Kp       => Kp,
             Ki       => Ki,
             Kd       => Kd,
             Integral => 0.0,
             E_Prev   => 0.0,
             Output   => 0.0));

   procedure Update (This     : in out Kpid;
                     Setpoint : in Float;
                     Actual   : in Float;
                     Ts       : in Float;
                     Is_Sat   : in Boolean := False)
   is
      E : Float := Setpoint - Actual;
      D_Term : constant Float := (E - This.E_Prev) / Ts; --  TODO: Filter!
   begin

      --  Anti-windup
      if Is_Sat then
         if This.Integral < 0.0 then
            --  Only allow integral to increase
            E := AMC_Utils.Max (E, 0.0);
         else
            --  Only allow integral to decrease
            E := AMC_Utils.Min (E, 0.0);
         end if;
      end if;

      This.Integral := This.Integral + E * This.Ki * Ts;

      This.Output := This.Kp * E + This.Integral + This.Kd * D_Term;

   end Update;

   function Get_Output (This : in Kpid) return Float
   is
   begin
      return This.Output;
   end Get_Output;

end PID;
