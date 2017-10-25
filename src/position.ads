with AMC_Types; use AMC_Types;
with AMC_Math;
with AMC_Hall;
with Config;
with Generic_PO;

package Position is
   --  @summary
   --  Rotor State Calculation
   --
   --  @description
   --  Measures and calculates the state of the rotor, e.g. angle and speed.
   --  It provides an interface to the used position sensor. Supported sensors:
   --
   --  - Quadrature encoder
   --  - Hall sensor
   --  - Todo: Sensorless, i.e. No sensor at all
   --

   --  Defines directions measured by hall sensor.
   --  Ccw is defined as an increasing angle.
   type Hall_Direction is (Standstill, Cw, Ccw);

   function To_Erad (Angle : in Angle_Rad)
                     return Angle_Erad;
   --  Convert a mechanical angle to the corresponding electrical angle.
   --  @param Angle Mechanical angle in radians
   --  @return Angle Electrical angle, i.e. corrected for number of motor pole-pairs.

   function Get_Angle return Angle_Erad;
   --  Get the current (raw) rotor electrical angle using the configured sensor.
   --  @return Angle in radians.

   function Get_Speed return Speed_Eradps;
   --  Get the current (raw) rotor electrical speed using the configured sensor.
   --  @return Speed in radians per second.

   function Wrap_To_180 (Angle : in Angle_Deg)
                         return Angle_Deg;
   --  Wraps Angle into [-180, 180] degrees.
   --  @param Angle Input angle in degrees.
   --  @return Output angle in degrees.

   function Wrap_To_360 (Angle : in Angle_Deg)
                         return Angle_Deg;
   --  Wraps Angle into [0, 360] degrees such that positive multiples of 360
   --  degrees map to 360 and negative multiples map to zero.
   --  Zero wraps to zero and 360 wraps to 360.
   --  @param Angle Input angle in degrees.
   --  @return Output angle in degrees.

   function Wrap_To_Pi (Angle : in Angle_Rad)
                        return Angle_Rad;
   --  Wraps Angle into [-Pi, Pi] radians.
   --  @param Angle Input angle in radians.
   --  @return Output angle in radians.

   function Wrap_To_2Pi (Angle : in Angle_Rad)
                         return Angle_Rad;
   --  Wraps Angle into [0, 2Pi] radians such that positive multiples of 2Pi
   --  radians map to 2Pi and negative multiples map to zero.
   --  Zero wraps to zero and 2Pi wraps to 2Pi.
   --  @param Angle Input angle in radians.
   --  @return Output angle in radians.

private

   function Get_Hall_Sector_Center_Angle (Sector : in Hall_Sector)
                                          return Angle_Erad;
   --  Get the angle (referenced to the stator's a-axis) to the center of the
   --  specified hall sensor sector.
   --  @param Sector The hall sensor sector.
   --  @return The angle in electrical radians in [0, 2pi).

   function Get_Hall_Direction (Hall : in AMC_Hall.Hall_State)
                                return Hall_Direction;

   function Get_Hall_Sector_Angle (Sector    : in Hall_Sector;
                                   Direction : in Hall_Direction)
                                   return Angle_Erad;

   Pi     : constant Angle_Rad := Angle_Rad (AMC_Math.Pi);
   Two_Pi : constant Angle_Rad := Angle_Rad (2.0 * AMC_Math.Pi);

   Hall_Sector_Angle : constant Angle_Erad := Angle_Erad (Two_Pi / 6.0);

   Hall_Offset : constant Angle_Erad := Config.Position_Sensor_Offset;

   Sector_Center_Angle : constant array (Hall_Sector'Range) of Angle_Erad :=
      (0.0,
       1.0 * Pi / 3.0,
       2.0 * Pi / 3.0,
       3.0 * Pi / 3.0,
       4.0 * Pi / 3.0,
       5.0 * Pi / 3.0);

--     A : Angle_Erad renames Hall_Sector_Angle;
--     O : constant Angle_Erad := 0.5 * Hall_Sector_Angle;
--
--
--     Sector_Angles : array (Hall_Sector'Range, Hall_Sector'Range) of Angle_Erad :=
--     -- Previous
--     --  |              ,--------------------------- Current -------------------------------,
--     --  V               H1,          H2,          H3,          H4,          H5,          H6
--        (H1 => (    0.0 * A, O + 0.0 * A, O + 1.0 * A, O + 2.0 * A, O + 4.0 * A, O + 5.0 * A),
--         H2 => (O + 0.0 * A,     1.0 * A, O + 1.0 * A, O + 2.0 * A, O + 3.0 * A, O + 5.0 * A),
--         H3 => (O + 0.0 * A, O + 1.0 * A,     2.0 * A, O + 2.0 * A, O + 3.0 * A, O + 4.0 * A),
--         H4 => (O + 5.0 * A, O + 1.0 * A, O + 2.0 * A,     3.0 * A, O + 3.0 * A, O + 4.0 * A),
--         H5 => (O + 5.0 * A, O + 0.0 * A, O + 2.0 * A, O + 3.0 * A,     4.0 * A, O + 4.0 * A),
--         H6 => (O + 5.0 * A, O + 0.0 * A, O + 1.0 * A, O + 3.0 * A, O + 4.0 * A,     5.0 * A));

   type Position_Hall_Data is record
      Hall_State : AMC_Hall.Hall_State;
      Angle_Raw  : Angle_Erad;
      Speed_Raw  : Speed_Eradps;
   end record;

   package Position_Hall_PO_Pack is new Generic_PO (Position_Hall_Data);

   Hall_Data : Position_Hall_PO_Pack.Shared_Data (Config.Protected_Object_Prio);

   package Hall_Map_PO_Pack is new Generic_PO (Pattern_To_Sector_Map);

   Hall_Sector_Map : Hall_Map_PO_Pack.Shared_Data (Config.Protected_Object_Prio);

end Position;
