with AMC_Types; use AMC_Types;
with AMC_Math;

package Position is
   --  Calculated the state of the rotor

   type Position_Sensor is (None, Hall, Encoder);

   function To_Erad (Angle : in Angle_Rad)
                     return Angle_Erad;
   --  Convert a mechanical angle to the corresponding electrical angle.

   function Get_Angle return Angle_Erad;

   function Wrap_To_180 (Angle : in Angle_Deg)
                         return Angle_Deg;
   --  Wraps Angle into [-180, 180] degrees.

   function Wrap_To_360 (Angle : in Angle_Deg)
                         return Angle_Deg;
   --  Wraps Angle into [0, 360] degrees such that positive multiples of 360
   --  degrees map to 360 and negative multiples map to zero.
   --  Zero wraps to zero and 360 wraps to 360.

   function Wrap_To_Pi (Angle : in Angle_Rad)
                        return Angle_Rad;
   --  Wraps Angle into [-Pi, Pi] radians.

   function Wrap_To_2Pi (Angle : in Angle_Rad)
                         return Angle_Rad;
   --  Wraps Angle into [0, 2Pi] radians such that positive multiples of 2Pi
   --  radians map to 2Pi and negative multiples map to zero.
   --  Zero wraps to zero and 2Pi wraps to 2Pi.

private

   Pi     : constant Angle_Rad := Angle_Rad (AMC_Math.Pi);
   Two_Pi : constant Angle_Rad := Angle_Rad (2.0 * AMC_Math.Pi);

end Position;
