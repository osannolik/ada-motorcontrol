with Config;
with AMC_Utils;
with AMC_Encoder;
with Motor;

package body Position is

   function To_Erad (Angle : in Angle_Rad)
                     return Angle_Erad
   is
      PP : constant Float := Motor.Pole_Pairs;
   begin
      return Angle_Erad
         (PP * AMC_Utils.Wrap_To (Float (Angle), Float (Two_Pi) / PP));
   end To_Erad;

   function Get_Angle return Angle_Erad
   is
   begin
      case Config.Position_Sensor is
         when None =>
            return 0.0;

         when Hall =>
            return 0.0;

         when Encoder =>
            return To_Erad (AMC_Encoder.Get_Angle);
      end case;
   end Get_Angle;

   function Wrap_To_360 (Angle : in Angle_Deg)
                         return Angle_Deg
   is (Angle_Deg (AMC_Utils.Wrap_To (Float (Angle), 360.0)));

   function Wrap_To_180 (Angle : in Angle_Deg)
                         return Angle_Deg
   is
   begin

      if Angle > 180.0 or else
         Angle < -180.0
      then
         return Wrap_To_360 (Angle + 180.0) - 180.0;
      end if;

      return Angle;

   end Wrap_To_180;

   function Wrap_To_2Pi (Angle : in Angle_Rad)
                         return Angle_Rad
   is (Angle_Rad (AMC_Utils.Wrap_To (Float (Angle), Float (Two_Pi))));

   function Wrap_To_Pi (Angle : in Angle_Rad)
                        return Angle_Rad
   is
   begin

      if Angle > Pi or else
         Angle < -Pi
      then
         return Wrap_To_2Pi (Angle + Pi) - Pi;
      end if;

      return Angle;

   end Wrap_To_Pi;

end Position;
