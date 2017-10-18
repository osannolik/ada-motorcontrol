with AMC;
with AMC_Utils;
with AMC_Encoder;
with Motor;
with Calmeas;

package body Position is

   Hall_State_Log : aliased UInt8;
   Direction_Log  : aliased UInt8;

   procedure Map_Pattern_To_Sector (Pattern : in AMC_Hall.Hall_Pattern;
                                    Sector  : in Hall_Sector)
   is
      use type AMC_Hall.Hall_Bits;
   begin
      for P in Hall_Sector_Map'Range loop
         if P = Pattern.Bits then
            Hall_Sector_Map (P) := Sector;
            exit;
         end if;
      end loop;
   end Map_Pattern_To_Sector;

   function Get_Hall_Sector_Center_Angle (Sector : in Hall_Sector)
                                          return Angle_Erad is
   begin
      return Wrap_To_2Pi (Sector_Center_Angle (Sector) + Hall_Offset);
   end Get_Hall_Sector_Center_Angle;

   function Get_Hall_Sector_Angle (Sector    : in Hall_Sector;
                                   Direction : in Hall_Direction)
                                   return Angle_Erad is
      Center_Angle : constant Angle_Erad := Sector_Center_Angle (Sector) + Hall_Offset;
   begin
      case Direction is
         when Ccw =>
            return Wrap_To_2Pi (Center_Angle - 0.5 * Hall_Sector_Angle);

         when Cw =>
            return Wrap_To_2Pi (Center_Angle + 0.5 * Hall_Sector_Angle);

         when Standstill =>
            --  Assume center of sector
            return Get_Hall_Sector_Center_Angle (Sector => Sector);
      end case;
   end Get_Hall_Sector_Angle;

   procedure Set_Hall_Angle (Angle : in Angle_Erad)
   is
      Hall : constant AMC_Hall.Hall_State := AMC_Hall.State.Get;

      function Is_Within_Sector (Angle  : in Angle_Erad;
                                 Sector : in Hall_Sector)
                                 return Boolean
      is
         Ccw_Angle : constant Angle_Erad := Get_Hall_Sector_Angle (Sector, Ccw);
         Cw_Angle  : constant Angle_Erad := Get_Hall_Sector_Angle (Sector, Cw);
      begin
         if Ccw_Angle <= Cw_Angle then
            return Ccw_Angle <= Angle and then Angle < Cw_Angle;
         else
            --  Sector spans over transition from 2pi to 0
            return Ccw_Angle <= Angle or else Angle < Cw_Angle;
         end if;
      end Is_Within_Sector;
   begin
      for Sector in Hall_Sector loop
         --  Which sector does the angle belong to?
         if Is_Within_Sector (Angle  => Wrap_To_2Pi (Angle),
                              Sector => Sector)
         then
            Map_Pattern_To_Sector (Pattern => Hall.Current,
                                   Sector  => Sector);
            exit;
         end if;
      end loop;
   end Set_Hall_Angle;

   function Get_Hall_Direction (Hall : in AMC_Hall.Hall_State)
                                return Hall_Direction
   is
      use type AMC_Hall.Hall_Bits;
      Current_Sector  : constant Hall_Sector := Hall_Sector_Map (Hall.Current.Bits);
      Previous_Sector : constant Hall_Sector := Hall_Sector_Map (Hall.Previous.Bits);
      Is_Ccw : Boolean;
   begin
      if AMC_Hall.Is_Standstill or else Hall.Current.Bits = Hall.Previous.Bits then
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

   function Hall_State_To_Angle (Hall : in AMC_Hall.Hall_State)
                                 return Angle_Erad
   is
   begin
      return Get_Hall_Sector_Angle
         (Sector    => Hall_Sector_Map (Hall.Current.Bits),
          Direction => Get_Hall_Direction (Hall));
   end Hall_State_To_Angle;

   task body Hall_State_Handler is
      New_State : AMC_Hall.Hall_State;

      Angle_Raw : Angle_Erad;

      Delta_T : Seconds;

      Speed_Raw : Speed_Eradps;

      Speed_Timer_Overflow : Boolean;
   begin

      Hall_Data.Set (Position_Hall_Data'(Hall_State => AMC_Hall.State.Get,
                                         Angle      => 0.0,
                                         Speed_Raw  => 0.0));

      AMC.Wait_Until_Initialized;

      loop
         AMC_Hall.State.Await_New (New_State            => New_State,
                                   Time_Delta_s         => Delta_T,
                                   Speed_Timer_Overflow => Speed_Timer_Overflow);

         Hall_State_Log := UInt8 (New_State.Current.Bits);

         case Get_Hall_Direction (Hall => New_State) is
            when Cw =>
               Direction_Log := 2;
            when Ccw =>
               Direction_Log := 0;
            when Standstill =>
               Direction_Log := 1;
         end case;

         Angle_Raw := Hall_State_To_Angle (New_State);

         if Speed_Timer_Overflow then
            Speed_Raw := 0.0;
         else
            Speed_Raw := Speed_Eradps
               (2.0 * AMC_Math.Pi / (Float (AMC_Hall.Nof_Valid_Hall_States) * Delta_T));
         end if;


         Hall_Data.Set (Position_Hall_Data'(Hall_State => New_State,
                                            Angle      => Angle_Raw,
                                            Speed_Raw  => Speed_Raw));
      end loop;
   end Hall_State_Handler;

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
            return Hall_Data.Get.Angle;

         when Encoder =>
            return To_Erad (AMC_Encoder.Get_Angle);
      end case;
   end Get_Angle;

   procedure Set_Angle (Angle : in Angle_Erad)
   is
   begin
      case Config.Position_Sensor is
         when None =>
            null;

         when Hall =>
            Set_Hall_Angle (Wrap_To_2Pi (Angle));

         when Encoder =>
            declare
               A : constant Float :=
                  Float (Wrap_To_2Pi (Angle)) / Motor.Pole_Pairs;
            begin
               AMC_Encoder.Set_Angle (Angle_Rad (A));
            end;
      end case;
   end Set_Angle;

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

   Calmeas.Add (Symbol      => Direction_Log'Access,
                Name        => "Direction",
                Description => "");

   Calmeas.Add (Symbol      => Hall_State_Log'Access,
                Name        => "Hall_State",
                Description => "");

end Position;
