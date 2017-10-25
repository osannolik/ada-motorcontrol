with Position.Estimation; pragma Unreferenced(Position.Estimation);
with AMC_Utils;
with AMC_Encoder;
with Motor;

package body Position is

   function Get_Hall_Direction (Hall : in AMC_Hall.Hall_State)
                                return Hall_Direction
   is
      use type AMC_Types.Hall_Bits;
      Hall_Map        : constant Pattern_To_Sector_Map := Hall_Sector_Map.Get;
      Current_Sector  : constant Hall_Sector := Hall_Map (Hall.Current.Bits);
      Previous_Sector : constant Hall_Sector := Hall_Map (Hall.Previous.Bits);
      Is_Ccw : Boolean;
   begin
      if Hall.Current.Bits = Hall.Previous.Bits then
         return Standstill;
      end if;

      case Current_Sector is
         when H1 =>
            Is_Ccw := (Previous_Sector = H6);

         when H2 | H3 | H4 | H5 | H6 =>
            Is_Ccw := (Previous_Sector = Hall_Sector'Pred (Current_Sector));
      end case;

      if Is_Ccw then
         return Ccw;
      end if;

      return Cw;
   end Get_Hall_Direction;

   function Get_Hall_Sector_Center_Angle (Sector : in Hall_Sector)
                                          return Angle_Erad is
   begin
      return Wrap_To_2Pi (Sector_Center_Angle (Sector) + Hall_Offset);
   end Get_Hall_Sector_Center_Angle;

   function Get_Hall_Sector_Angle (Sector    : in Hall_Sector;
                                   Direction : in Hall_Direction)
                                   return Angle_Erad is
      Center_Angle : constant Angle_Erad := Get_Hall_Sector_Center_Angle (Sector);
   begin
      case Direction is
         when Ccw =>
            return Wrap_To_2Pi (Center_Angle - 0.5 * Hall_Sector_Angle);

         when Cw =>
            return Wrap_To_2Pi (Center_Angle + 0.5 * Hall_Sector_Angle);

         when Standstill =>
            --  Assume center of sector
            return Center_Angle;
      end case;
   end Get_Hall_Sector_Angle;

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
            return Hall_Data.Get.Angle_Raw;

         when Encoder =>
            return To_Erad (AMC_Encoder.Get_Angle);
      end case;
   end Get_Angle;

   function Get_Speed return Speed_Eradps
   is
   begin
      case Config.Position_Sensor is
         when None | Encoder =>
            return 0.0;

         when Hall =>
            return Hall_Data.Get.Speed_Raw;
      end case;
   end Get_Speed;

   function Wrap_To_360 (Angle : in Angle_Deg) return Angle_Deg is
      (Angle_Deg (AMC_Utils.Wrap_To (Float (Angle), 360.0)));

   function Wrap_To_180 (Angle : in Angle_Deg)
                         return Angle_Deg
   is
   begin

      if Angle < -180.0 or else 180.0 < Angle  then
         return Wrap_To_360 (Angle + 180.0) - 180.0;
      end if;

      return Angle;

   end Wrap_To_180;

   function Wrap_To_2Pi (Angle : in Angle_Rad) return Angle_Rad is
      (Angle_Rad (AMC_Utils.Wrap_To (Float (Angle), Float (Two_Pi))));

   function Wrap_To_Pi (Angle : in Angle_Rad)
                        return Angle_Rad
   is
   begin

      if Angle < -Pi or else Pi < Angle then
         return Wrap_To_2Pi (Angle + Pi) - Pi;
      end if;

      return Angle;

   end Wrap_To_Pi;
begin

   Hall_Sector_Map.Set (Config.Hall_Sensor_Pin_Map);

end Position;
