with AMC;
with Calmeas;

package body Position.Estimation is

   Hall_State_Log : aliased UInt8;
   Direction_Log  : aliased UInt8;

   function Hall_State_To_Angle (Hall : in AMC_Hall.Hall_State)
                                 return Angle_Erad
   is
   begin
      return Get_Hall_Sector_Angle
         (Sector    => Hall_Sector_Map.Get (Hall.Current.Bits),
          Direction => Get_Hall_Direction (Hall));
   end Hall_State_To_Angle;

   function Calculate_Speed_Raw (Delta_T : Seconds)
                                 return Speed_Eradps
   is
   begin
      return Speed_Eradps
               (2.0 * AMC_Math.Pi / (Float (AMC_Hall.Nof_Valid_Hall_States) * Delta_T));
   end Calculate_Speed_Raw;

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
            Speed_Raw := Calculate_Speed_Raw (Delta_T);
         end if;


         Hall_Data.Set (Position_Hall_Data'(Hall_State => New_State,
                                            Angle_Raw  => Angle_Raw,
                                            Speed_Raw  => Speed_Raw));
      end loop;
   end Hall_Handler;

begin

   Calmeas.Add (Symbol      => Direction_Log'Access,
                Name        => "Direction",
                Description => "");

   Calmeas.Add (Symbol      => Hall_State_Log'Access,
                Name        => "Hall_State",
                Description => "");

end Position.Estimation;
