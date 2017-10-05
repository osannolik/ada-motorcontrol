with AMC;
with AMC_Utils;
with AMC_Encoder;
with Motor;

package body Position is


   type Hall_Sector is (H1, H2, H3, H4, H5, H6);

   type Hall_Direction is (Standstill, Cw, Ccw);

   type Pattern_To_Sector_Map is array (AMC_Hall.Valid_Hall_Bits'Range) of Hall_Sector;

   Hall_Sector_Map : Pattern_To_Sector_Map :=
      (2#001# => H1,
       2#011# => H2,
       2#010# => H3,
       2#110# => H4,
       2#100# => H5,
       2#101# => H6);

   Hall_Sector_Angle : constant Angle_Erad := 2.0 * Pi / 6.0;

   Sector_Angle_Ccw : constant array (Hall_Sector'Range) of Angle_Erad :=
      (0.0,
       1.0 * Pi / 3.0,
       2.0 * Pi / 3.0,
       3.0 * Pi / 3.0,
       4.0 * Pi / 3.0,
       5.0 * Pi / 3.0);

--     type Hall_Angle_Map is
--        array (AMC_Hall.Valid_Hall_Bits'Range, AMC_Hall.Valid_Hall_Bits'Range) of AMC_Types.Angle_Erad;
--
--     type Hall_Direction_Map is
--        array (AMC_Hall.Valid_Hall_Bits'Range, AMC_Hall.Valid_Hall_Bits'Range) of Float;
--
--     package Angle_PO is new Generic_PO (Hall_Angle_Map);
--     package Direction_PO is new Generic_PO (Hall_Direction_Map);
--
--     Hall_State_To_Angle     : Angle_PO.Shared_Data (Config.Protected_Object_Prio);
--     Hall_State_To_Direction : Direction_PO.Shared_Data (Config.Protected_Object_Prio);


   procedure Map_Pattern_To_Sector (Pattern : in AMC_Hall.Hall_Pattern;
                                    Sector  : in Hall_Sector)
   is
      use type AMC_Hall.Hall_Bits;
   begin
      for P in Hall_Sector_Map'Range loop
         if P = Pattern.Bits then
            Hall_Sector_Map (P) := Sector;
         end if;
      end loop;
   end Map_Pattern_To_Sector;

   procedure Set_Hall_Angle (Angle : in Angle_Erad)
   is
      Hall : constant AMC_Hall.Hall_State := AMC_Hall.State.Get;

      function Is_Within_Sector (Angle  : in Angle_Erad;
                                 Sector : in Hall_Sector)
                                 return Boolean is

      begin
         return Sector_Angle_Ccw (Sector) <= Angle and then
                Angle < Sector_Angle_Ccw (Sector) + Hall_Sector_Angle;
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
      Current_Sector  : constant Hall_Sector := Hall_Sector_Map (Hall.Current.Bits);
      Previous_Sector : constant Hall_Sector := Hall_Sector_Map (Hall.Previous.Bits);
      Is_Ccw : Boolean;
   begin
      if AMC_Hall.Is_Standstill then
         return Standstill;
      end if;

      case Current_Sector is
         when H1 =>
            Is_Ccw := (Previous_Sector = H6);

         when H2 | H3 | H4 | H5 | H6 =>
            Is_Ccw := (Current_Sector = Hall_Sector'Pred (Previous_Sector));
      end case;

      if Is_Ccw then
         return Ccw;
      end if;

      return Cw;
   end Get_Hall_Direction;

   function Hall_State_To_Angle (Hall : in AMC_Hall.Hall_State)
                                 return Angle_Erad
   is
      Sector : constant Hall_Sector := Hall_Sector_Map (Hall.Current.Bits);
   begin
      case Get_Hall_Direction (Hall) is
         when Ccw | Standstill =>
            return Sector_Angle_Ccw (Sector);

         when Cw =>
            return Wrap_To_2Pi (Sector_Angle_Ccw (Sector) + Hall_Sector_Angle);
      end case;
   end Hall_State_To_Angle;

   task body Hall_State_Handler is
      New_State : AMC_Hall.Hall_State;

      Angle_Raw : Angle_Erad;

      Delta_T : Seconds;

      Speed_Raw : Speed_Eradps;
   begin

      AMC.Wait_Until_Initialized;

      loop
         AMC_Hall.State.Await_New (New_State    => New_State,
                                   Time_Delta_s => Delta_T);

         Angle_Raw := Hall_State_To_Angle (New_State);

         if not AMC_Hall.Is_Standstill and then Delta_T /= 0.0 then
            Speed_Raw := Speed_Eradps
               (2.0 * AMC_Math.Pi / (Float (AMC_Hall.Nof_Valid_Hall_States) * Delta_T));
         else
            Speed_Raw := 0.0;
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

end Position;
