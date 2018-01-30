with HAL; use HAL;
with STM32.Device;
with STM32.PWM;
with STM32.WWDG;
with STM32_SVD.DBG;

package body AMC_WDG is
   use STM32.WWDG;

   --  Watchdog counter counts DOWN from Window_Start and causes a reset when
   --  when it passes Window_End, i.e. hits Window_End - 1.
   Counter_Start :          Downcounter := Downcounter'Last;
   Window_End    : constant Downcounter := Downcounter'First;

   procedure Initialize (Period    : AMC_Types.Seconds;
                         Tolerance : AMC_Types.Seconds)
   is
      use STM32.PWM;

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
         return Period_Plus_Tolerance (Prescaler, Cntr_Start) <= Period + Tolerance and then
            Window_Start (Prescaler, Tolerance) in Valid_Window'Range;
      end Is_Valid_Setting;

      Prescaler        : Prescalers := Prescalers'Last;
      Res_Window_Start : Integer;
      Found_Setting    : Boolean;
   begin
      Initialized := False;

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

         --  Init timer used to refresh watchdog
         STM32.PWM.Configure_PWM_Timer
            (Generator => Refresh_Timer'Access,
             Frequency => STM32.PWM.Hertz (1.0 / Period));

         STM32.Timers.Disable_Interrupt (Refresh_Timer, STM32.Timers.Timer_Update_Interrupt);

         STM32_SVD.DBG.DBG_Periph.DBGMCU_APB1_FZ.DBG_WWDG_STOP := True;
         STM32_SVD.DBG.DBG_Periph.DBGMCU_APB1_FZ.DBG_TIM6_STOP := True;

         Initialized := True;
      end if;

      --  TODO: Create ISR for pre-reset handling (Early_Wakeup_Interrupt)
   end Initialize;

   protected body Refresher is

      procedure Set_Counter (Val : in Natural) is
      begin
         if Timed_Out then
            --  We just missed the ISR-refresh, but the wdg has not caused a reset
            --  yet (due to the window size).
            --  Since everything obviously is fine => Do a refresh!
            Refresh_Watchdog_Counter (Counter_Start);
            Timed_Out := False;
         end if;
         Counter := Val;
      end Set_Counter;

      procedure ISR is
         use STM32.Timers;
      begin
         --AMC_Board.Turn_On (AMC_Board.Debug_Pin_3);

         if Status (Refresh_Timer, Timer_Update_Indicated) and then
            Interrupt_Enabled (Refresh_Timer, Timer_Update_Interrupt)
         then
            Clear_Pending_Interrupt (Refresh_Timer, Timer_Update_Interrupt);

            if Counter > 0 then
               Counter := Natural'Pred (Counter);
               Refresh_Watchdog_Counter (Counter_Start);
            else
               Timed_Out := True;
            end if;
         end if;

         --AMC_Board.Turn_Off (AMC_Board.Debug_Pin_3);
      end ISR;

   end Refresher;

   procedure Activate is
      use STM32.Timers;
   begin
      --AMC_Board.Turn_On (AMC_Board.Debug_Pin_1);

      Refresher.Set_Counter (1);

      Enable (Refresh_Timer);
      STM32.Timers.Set_Counter (Refresh_Timer, AMC_Types.UInt16'(0));
      Enable_Interrupt (Refresh_Timer, Timer_Update_Interrupt); -- Causes immediate irq

      Activate_Watchdog (Counter_Start);
      Activated := True;

      --AMC_Board.Turn_Off (AMC_Board.Debug_Pin_1);
   end Activate;

   function Is_Activated return Boolean is
      (Activated);

   procedure Refresh (N : in Positive := 1) is
   begin
      --AMC_Board.Turn_On (AMC_Board.Debug_Pin_2);
      Refresher.Set_Counter (N);
      --AMC_Board.Turn_Off (AMC_Board.Debug_Pin_2);
   end Refresh;

   function Is_Initialized return Boolean is
      (Initialized);

end AMC_WDG;
