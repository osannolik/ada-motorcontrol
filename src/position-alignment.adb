with Motor;
with AMC_Encoder;

package body Position.Alignment is

   procedure Map_Pattern_To_Sector (Pattern : in AMC_Hall.Hall_Pattern;
                                    Sector  : in Hall_Sector)
   is
      use type AMC_Types.Hall_Bits;
      Hall_Map : Pattern_To_Sector_Map := Hall_Sector_Map.Get;
   begin
      for P in Hall_Map'Range loop
         if P = Pattern.Bits then
            Hall_Map (P) := Sector;
            exit;
         end if;
      end loop;

      Hall_Sector_Map.Set (Hall_Map);
   end Map_Pattern_To_Sector;

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
                                    Current_Set_Point : out Current_A)
   is
   begin
      Current_Set_Point := 0.0;

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
            Current_Set_Point  := 12.0;

         when Probing =>
            if Alignment.Timer.Tick (Period) then
               Alignment.Timer.Reset;

               Map_Pattern_To_Sector
                  (Pattern => AMC_Hall.State.Get.Current,
                   Sector  => Alignment.To_Sector);

               if Alignment.To_Sector = Hall_Sector'First then
                  Alignment.State := Done;
               else
                  Alignment.To_Sector := Hall_Sector'Pred (Alignment.To_Sector);
               end if;
            end if;
            Current_Set_Point  := 12.0;

         when Done =>
            null;

      end case;

      To_Angle := Compose (Get_Hall_Sector_Center_Angle (Alignment.To_Sector));

   end Hall_Alignment_Update;

   procedure Encoder_Alignment_Update (Alignment         : in out Alignment_Data;
                                       Period            : in Seconds;
                                       To_Angle          : out Angle;
                                       Current_Set_Point : out Current_A)
   is
   begin
      Current_Set_Point := 0.0;

      case Alignment.State is
         when Not_Performed =>
            Alignment.State := Probing;
            Alignment.Timer.Reset (2.0);

         when Rotation | Probing =>
            if Alignment.Timer.Tick (Period) then
               Alignment.Timer.Reset;
               Set_Encoder_Angle (0.0);
            else
               Current_Set_Point  := 12.0;
            end if;

         when Done =>
            null;

      end case;

      To_Angle := Compose (0.0);

   end Encoder_Alignment_Update;

   procedure Align_To_Sensor_Update (Alignment         : in out Alignment_Data;
                                     Period            : in Seconds;
                                     To_Angle          : out Angle;
                                     Current_Set_Point : out Current_A)
   is
   begin
      case Alignment.Sensor is
         when None =>
            raise Constraint_Error; --  TODO

         when Hall =>
            Hall_Alignment_Update
               (Alignment         => Alignment,
                Period            => Period,
                To_Angle          => To_Angle,
                Current_Set_Point => Current_Set_Point);

         when Encoder =>
            Encoder_Alignment_Update
               (Alignment         => Alignment,
                Period            => Period,
                To_Angle          => To_Angle,
                Current_Set_Point => Current_Set_Point);
      end case;
   end Align_To_Sensor_Update;

end Position.Alignment;
