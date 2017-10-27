with AMC;
with AMC_Board;
with AMC_Utils.Moving_Avg;

package body Position.Estimation is

   function Hall_Angle_From_State (Hall : in AMC_Hall.Hall_State)
                                   return Angle_Erad
   is
   begin
      return Get_Hall_Sector_Angle
         (Sector    => Hall_Sector_Map.Get (Hall.Current.Bits),
          Direction => Get_Hall_Direction (Hall));
   end Hall_Angle_From_State;

   function Hall_Speed_From_Delta_T (Delta_T : in Seconds)
                                     return Speed_Eradps
   is
      Dt : constant Seconds := Seconds'Max (Seconds'Succ (0.0), Delta_T);
   begin
      return Speed_Eradps
         (2.0 * AMC_Math.Pi / (Float (AMC_Hall.Nof_Valid_Hall_States) * Dt));
   end Hall_Speed_From_Delta_T;

   function Calculate_Speed (Hall    : in AMC_Hall.Hall_State;
                             Delta_T : in Seconds)
                             return Speed_Eradps
   is
      Speed_Abs : constant Speed_Eradps := Speed_Eradps
         (AMC_Utils.Dead_Zone (X     =>  Float (Hall_Speed_From_Delta_T (Delta_T)),
                               Upper =>  Float (Hall_Speed_Estimate_Min),
                               Lower => -Float (Hall_Speed_Estimate_Min)));
   begin
      case Get_Hall_Direction (Hall) is
         when Ccw =>
            return Speed_Abs;
         when Cw =>
            return -Speed_Abs;
         when Standstill =>
            return 0.0;
      end case;
   end Calculate_Speed;

   procedure Hall_Angle_Update (Delta_T : in Seconds)
   is
      Angle_Est   : constant Angle_Erad := Hall_Angle_Est_Data.Get.Angle_Est;
      Speed       : constant Float      := Float (Hall_Speed_Est_Data.Get.Speed_Est);
      Delta_Angle : constant Angle_Erad := Angle_Erad (Float (Delta_T) * Speed);
   begin
      --  Simple linear interpolation
      Hall_Angle_Est_Data.Set
         ((Angle_Est => Wrap_To_2Pi (Angle_Est + Delta_Angle)));
   end Hall_Angle_Update;

   procedure Angle_Update (Delta_T : in Seconds)
   is
   begin
      case Config.Position_Sensor is
         when Hall =>
            Hall_Angle_Update (Delta_T => Delta_T);

         when Encoder =>
            null;

         when None =>
            raise Constraint_Error; -- TODO
      end case;
   end Angle_Update;

   function Get_Angle return Angle_Erad
   is
   begin
      case Config.Position_Sensor is
         when Hall =>
            return Hall_Angle_Est_Data.Get.Angle_Est;

         when Encoder =>
            --  Raw value good enough for now?
            return Get_Angle;

         when None =>
            raise Constraint_Error; -- TODO
      end case;
   end Get_Angle;

   function Get_Speed return Speed_Eradps
   is
   begin
      case Config.Position_Sensor is
         when Hall =>
            return Hall_Speed_Est_Data.Get.Speed_Est;

         when Encoder | None =>
            raise Constraint_Error; -- TODO
      end case;
   end Get_Speed;

   task body Hall_Handler is

      package MA is new AMC_Utils.Moving_Avg (N         => AMC_Hall.Nof_Valid_Hall_States,
                                              Element_T => Seconds);

      New_State            : AMC_Hall.Hall_State;
      Delta_T              : Seconds;
      Speed_Timer_Overflow : Boolean;

      Time_Filter : MA.Moving_Average;

      Angle_Raw : Angle_Erad;
   begin
      Time_Filter.Set (Value => 0.0);

      Hall_Speed_Est_Data.Set (Hall_Speed_Estimation_Data'(Speed_Est => 0.0));

      Hall_Angle_Est_Data.Set (Hall_Angle_Estimation_Data'(Angle_Est => 0.0));

      Hall_Data.Set (Position_Hall_Data'(Hall_State => AMC_Hall.State.Get,
                                         Angle_Raw  => 0.0,
                                         Speed_Raw  => 0.0));

      AMC.Wait_Until_Initialized;

      loop
         AMC_Hall.State.Await_New (New_State            => New_State,
                                   Time_Delta_s         => Delta_T,
                                   Speed_Timer_Overflow => Speed_Timer_Overflow);

         AMC_Board.Turn_On  (AMC_Board.Debug_Pin_2);
         AMC_Board.Turn_Off (AMC_Board.Debug_Pin_1);

         Angle_Raw := Hall_Angle_From_State (New_State);

         if Speed_Timer_Overflow then
            Time_Filter.Set (Seconds'Last);
         else
            Time_Filter.Update (Delta_T);
         end if;

         Hall_Angle_Est_Data.Set ((Angle_Est => Angle_Raw));

         Hall_Speed_Est_Data.Set
            ((Speed_Est => Calculate_Speed (Hall    => New_State,
                                            Delta_T => Time_Filter.Get)));

         Hall_Data.Set ((Hall_State => New_State,
                         Angle_Raw  => Angle_Raw,
                         Speed_Raw  => Calculate_Speed (Hall    => New_State,
                                                        Delta_T => Delta_T)));

         AMC_Board.Turn_Off  (AMC_Board.Debug_Pin_2);

      end loop;
   end Hall_Handler;

end Position.Estimation;
