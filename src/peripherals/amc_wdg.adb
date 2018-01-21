with HAL; use HAL;
with STM32.Device;
with STM32.WWDG;

package body AMC_WDG is
   use STM32.WWDG;

   --  Watchdog counter counts DOWN from Window_Start and causes a reset when
   --  when it passes Window_End, i.e. hits Window_End - 1.
   Counter_Start : Downcounter := Downcounter'Last;
   Window_End    : constant Downcounter := Downcounter'First;

   procedure Initialize (Nominal_Period : AMC_Types.Seconds;
                         Tolerance      : AMC_Types.Seconds)
   is
      PCLK1_Freq : constant Float := Float (STM32.Device.System_Clock_Frequencies.PCLK1);
      Cntr_Freq  : constant array (Prescalers'Range) of Float :=
         (Divider_1 => PCLK1_Freq / (1.0 * 4096.0),
          Divider_2 => PCLK1_Freq / (2.0 * 4096.0),
          Divider_4 => PCLK1_Freq / (4.0 * 4096.0),
          Divider_8 => PCLK1_Freq / (8.0 * 4096.0));

      function Period_Plus_Tolerance (Prescaler  : in Prescalers;
                                      Cntr_Start : in Downcounter)
                                      return Float is
         (Float (Cntr_Start - Window_End) / Cntr_Freq (Prescaler));

      function Window_Start (Prescaler : in Prescalers;
                             Tolerance : in AMC_Types.Seconds)
                             return Integer is
         (Integer (Window_End) + Integer (2.0 * Float (Tolerance) * Cntr_Freq (Prescaler)));

      function Is_Valid_Setting (Prescaler  : in Prescalers;
                                 Cntr_Start : in Downcounter;
                                 Tolerance  : in AMC_Types.Seconds)
                                 return Boolean
      is
         subtype Valid_Window is Integer range Integer (Window_End) .. Integer (Cntr_Start);
      begin
         return Period_Plus_Tolerance (Prescaler, Cntr_Start) <= Nominal_Period + Tolerance and then
            Window_Start (Prescaler, Tolerance) in Valid_Window'Range;
      end Is_Valid_Setting;

      Prescaler        : Prescalers := Prescalers'Last;
      Res_Window_Start : Integer;
      Found_Setting    : Boolean;
   begin
      loop
         Found_Setting := Is_Valid_Setting (Prescaler, Counter_Start, Tolerance);
         Res_Window_Start := Window_Start (Prescaler, Tolerance);
         exit when Found_Setting or Prescaler = Prescalers'First;
         Prescaler := Prescalers'Pred (Prescaler);
      end loop;

      loop
         Found_Setting := Is_Valid_Setting (Prescaler, Counter_Start, Tolerance);
         exit when Found_Setting or
            Downcounter'Pred (Counter_Start) = Downcounter (Res_Window_Start);
         Counter_Start := Downcounter'Pred (Counter_Start);
      end loop;

      if Found_Setting then
         Enable_Watchdog_Clock;
         Reset_Watchdog;
         Set_Watchdog_Prescaler (Prescaler);
         Set_Watchdog_Window (Downcounter (Res_Window_Start));

         Initialized := True;
      else
         Initialized := False;
      end if;

   end Initialize;

   procedure Activate is
   begin
      Activate_Watchdog (Counter_Start);
   end Activate;

   procedure Refresh is
   begin
      Refresh_Watchdog_Counter (Counter_Start);
   end Refresh;

   function Is_Initialized return Boolean is
      (Initialized);

end AMC_WDG;
