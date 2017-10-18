with Motor;
with AMC_Encoder;

package body Position.Alignment is

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

   procedure Set_Encoder_Angle (Angle : in Angle_Erad)
   is
      A : constant Float := Float (Wrap_To_2Pi (Angle)) / Motor.Pole_Pairs;
   begin
      AMC_Encoder.Set_Angle (Angle_Rad (A));
   end Set_Encoder_Angle;

   function Is_Done (Alignment : in Alignment_Data) return Boolean is
      (Alignment.State = Done);

   procedure Hall_Alignment_Update (Alignment         : in out Alignment_Data;
                                    Period            : in Seconds;
                                    To_Angle          : out Angle;
                                    Current_Set_Point : out Space_Vector)
   is
      Current : Current_A  := 0.0;
      Angle   : constant Angle_Erad :=
         Get_Hall_Sector_Center_Angle (Alignment.To_Sector);
   begin
      case Alignment.State is
         when Not_Performed =>
            Alignment.State := Rotation;
            Alignment.Timer.Reset (1.0);
            Alignment.To_Sector := Hall_Sector'First;

         when Rotation =>
            if Alignment.Timer.Tick (Period) then
               Alignment.Timer.Reset;
               if Alignment.To_Sector = Hall_Sector'Last then
                  Alignment.State := Probing;
               else
                  Alignment.To_Sector := Hall_Sector'Succ (Alignment.To_Sector);
               end if;
            end if;
            Current  := 12.0;

         when Probing =>
            if Alignment.Timer.Tick (Period) then
               Alignment.Timer.Reset;

               Set_Hall_Angle (Angle);

               if Alignment.To_Sector = Hall_Sector'First then
                  Alignment.State := Done;
               else
                  Alignment.To_Sector := Hall_Sector'Pred (Alignment.To_Sector);
               end if;
            end if;
            Current  := 12.0;

         when Done =>
            null;

      end case;

      To_Angle := Compose (Angle);

      Current_Set_Point :=
         Space_Vector'(Reference_Frame  => Rotor,
                       Rotor_Fixed      => (D => Current,
                                            Q => 0.0));
   end Hall_Alignment_Update;

   procedure Encoder_Alignment_Update (Alignment         : in out Alignment_Data;
                                       Period            : in Seconds;
                                       To_Angle          : out Angle;
                                       Current_Set_Point : out Space_Vector)
   is
      Current : Current_A := 0.0;
   begin
      case Alignment.State is
         when Not_Performed =>
            Alignment.State := Probing;
            Alignment.Timer.Reset (2.0);

         when Rotation | Probing =>
            if Alignment.Timer.Tick (Period) then
               Alignment.Timer.Reset;
               Set_Encoder_Angle (0.0);
            else
               Current  := 12.0;
            end if;

         when Done =>
            null;

      end case;

      To_Angle := Compose (0.0);

      Current_Set_Point :=
         Space_Vector'(Reference_Frame  => Rotor,
                       Rotor_Fixed      => (D => Current,
                                            Q => 0.0));
   end Encoder_Alignment_Update;

   procedure Align_To_Sensor_Update (Alignment         : in out Alignment_Data;
                                     Period            : in Seconds;
                                     To_Angle          : out Angle;
                                     Current_Set_Point : out Space_Vector)
   is
   begin
      case Alignment.Sensor is
         when None =>
            raise Constraint_Error; --  TODO

         when Hall =>
            Hall_Alignment_Update (Alignment         => Alignment,
                                   Period            => Period,
                                   To_Angle          => To_Angle,
                                   Current_Set_Point => Current_Set_Point);

         when Encoder =>
            Encoder_Alignment_Update (Alignment         => Alignment,
                                      Period            => Period,
                                      To_Angle          => To_Angle,
                                      Current_Set_Point => Current_Set_Point);
      end case;
   end Align_To_Sensor_Update;

end Position.Alignment;
