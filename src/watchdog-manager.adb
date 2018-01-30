with Ada.Real_Time;
with AMC_WDG;
with AMC_Types;
with AMC;

package body Watchdog.Manager is

   procedure Refresh is
   begin
      AMC_WDG.Refresh;
   end Refresh;

   task body Watchdog_Manager is
      use Ada.Real_Time;
      use Config;

      Next_Release : Time := Clock;
      Refresh : Boolean;

      procedure Delay_Nominal_Period is
      begin
         Next_Release := Next_Release + Milliseconds (Base_Period_Ms);
         delay until Next_Release;
      end Delay_Nominal_Period;
   begin
      Initialize (Instance);

      AMC_WDG.Initialize
         (Period    => AMC_Types.Seconds (Float (Base_Period_Ms) / 1000.0),
          Tolerance => 200.0e-6);

      if not AMC_WDG.Is_Initialized then
         raise Failed_Watchdog_Init;
      end if;

      loop
         Delay_Nominal_Period;
         exit when AMC.Is_Initialized;
      end loop;

      loop
         if not AMC_WDG.Is_Activated then
            if Config.Enable_Watchdog then
               AMC_WDG.Activate; --  Also refreshes
            end if;
         else
            Update (Instance, Refresh);
            if Refresh then
               AMC_WDG.Refresh;
            end if;
         end if;

         Delay_Nominal_Period;
      end loop;
   end Watchdog_Manager;

end Watchdog.Manager;
