with AMC;
with Calmeas;
with AMC_Board;

package body Position.Estimation is

   Hall_State_Log : aliased UInt8;
   Direction_Log  : aliased UInt8;
   Speed_Timer_Overflow_Log : aliased UInt8;

   Index_History : Hall_Sector := Hall_Sector'First;
   Hall_Speed_History : array (Hall_Sector'Range) of Speed_Eradps := (others => 0.0);


   function Hall_State_To_Angle (Hall : in AMC_Hall.Hall_State)
                                 return Angle_Erad
   is
   begin
      return Get_Hall_Sector_Angle
         (Sector    => Hall_Sector_Map.Get (Hall.Current.Bits),
          Direction => Get_Hall_Direction (Hall));
   end Hall_State_To_Angle;

   function Calculate_Speed_Raw (Hall    : in AMC_Hall.Hall_State;
                                 Delta_T : in Seconds)
                                 return Speed_Eradps
   is
      Speed_Abs : constant Speed_Eradps :=
         Speed_Eradps (2.0 * AMC_Math.Pi / (Float (AMC_Hall.Nof_Valid_Hall_States) * Delta_T));
   begin
      case Get_Hall_Direction (Hall) is
         when Ccw =>
            return Speed_Abs;
         when Cw =>
            return -Speed_Abs;
         when Standstill =>
            return 0.0;
      end case;
   end Calculate_Speed_Raw;

   procedure Hall_Angle_Update (Delta_T : in Seconds)
   is
      Angle_Est   : constant Angle_Erad := Hall_Angle_Est_Data.Get.Angle_Est;
      Speed       : constant Float      := Float (Hall_Speed_Est_Data.Get.Speed_Est);
      Delta_Angle : constant Angle_Erad := Angle_Erad (Float (Delta_T) * Speed);
   begin
      --  Simple linear interpolation
      Hall_Angle_Est_Data.Set
         (Hall_Angle_Estimation_Data'(Angle_Est => Wrap_To_2Pi (Angle_Est + Delta_Angle)));
   end Hall_Angle_Update;

   procedure Hall_Angle_Set (Angle : in Angle_Erad)
   is
   begin
      Hall_Angle_Est_Data.Set
         (Hall_Angle_Estimation_Data'(Angle_Est => Angle));
   end Hall_Angle_Set;

   procedure Hall_Speed_Update (Speed : in Speed_Eradps)
   is
      Sum : Speed_Eradps := 0.0;
   begin
      Hall_Speed_History (Index_History) := Speed;

      if Index_History = Hall_Sector'Last then
         Index_History := Hall_Sector'First;
      end if;

      for S of Hall_Speed_History loop
         Sum := Sum + S;
      end loop;

      Hall_Speed_Est_Data.Set
         ((Speed_Est => Sum / Speed_Eradps (AMC_Hall.Nof_Valid_Hall_States)));
   end Hall_Speed_Update;

   procedure Hall_Speed_Set (Speed : in Speed_Eradps)
   is
   begin
      Hall_Speed_History := (others => Speed);
   end Hall_Speed_Set;

   procedure Angle_Update (Delta_T : in Seconds)
   is
   begin
      case Config.Position_Sensor is
         when Hall =>
            Hall_Angle_Update (Delta_T => Delta_T);

         when Encoder | None =>
            raise Constraint_Error; -- TODO
      end case;
   end Angle_Update;

   function Get_Angle return Angle_Erad
   is
   begin
      case Config.Position_Sensor is
         when Hall =>
            return Hall_Angle_Est_Data.Get.Angle_Est;

         when Encoder | None =>
            raise Constraint_Error; -- TODO
      end case;
   end Get_Angle;

   task body Hall_Handler is
      New_State : AMC_Hall.Hall_State;

      Angle_Raw : Angle_Erad;

      Delta_T : Seconds;

      Speed_Raw : Speed_Eradps;

      Speed_Timer_Overflow : Boolean;
   begin

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

         Speed_Raw := Calculate_Speed_Raw (Hall    => New_State,
                                           Delta_T => Delta_T);

         if Speed_Timer_Overflow then
            Hall_Speed_Set (0.0);
            Speed_Timer_Overflow_Log := 1;
         else
            Speed_Timer_Overflow_Log := 0;
         end if;

         Hall_Speed_Update (Speed => Speed_Raw);

         Hall_Data.Set (Position_Hall_Data'(Hall_State => New_State,
                                            Angle_Raw  => Angle_Raw,
                                            Speed_Raw  => Speed_Raw));

         Hall_Angle_Set (Angle => Angle_Raw);

         AMC_Board.Turn_Off  (AMC_Board.Debug_Pin_2);

      end loop;
   end Hall_Handler;

begin

   Calmeas.Add (Symbol      => Speed_Timer_Overflow_Log'Access,
                Name        => "Speed_Timer_Overflow",
                Description => "");

   Calmeas.Add (Symbol      => Direction_Log'Access,
                Name        => "Direction",
                Description => "");

   Calmeas.Add (Symbol      => Hall_State_Log'Access,
                Name        => "Hall_State",
                Description => "");

end Position.Estimation;
