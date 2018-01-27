package body Watchdog is

   procedure Set_Counter (Wdg        : in out Watchdog_Type;
                          Checkpoint : in     Checkpoint_Valid_Id;
                          Value      : in     Natural)
   is
      Tmp : Counter_Array := Wdg.Counters.Get;
   begin
      Tmp (Checkpoint) := Value;
      Wdg.Counters.Set (Tmp);
   end Set_Counter;

   procedure Reset_Counters (Wdg : in out Watchdog_Type) is
   begin
      Wdg.Counters.Set (Counter_Array'(others => 0));
   end Reset_Counters;

   procedure Update (Wdg     : in out Watchdog_Type;
                     Refresh :    out Boolean)
   is
      Counters : Counter_Array := Wdg.Counters.Get;
   begin
      Refresh := True;

      for Id in Counters'First .. Wdg.Nof_Monitored_Checkpoints loop
         declare
            Check : Supervision_Data renames Wdg.Supervision (Id);
         begin
            Check.Counter := Natural'Succ (Check.Counter);
            if Check.Counter = Check.Factor then
               Check.Counter := 0;

               if Counters (Id) < Check.Minimum_Nof_Visits then
                  Check.Nof_Misses := Natural'Succ (Check.Nof_Misses);
                  if Check.Nof_Misses > Check.Nof_Misses_Max then
                     Refresh := False;
                  end if;
               else
                  Check.Nof_Misses := 0;
               end if;

               Counters (Id) := 0;
            end if;
         end;
      end loop;

      Wdg.Counters.Set (Counters);
   end Update;

   procedure Visit (Wdg        : in out Watchdog_Type;
                    Checkpoint : in     Checkpoint_Valid_Id)
   is
      Counters : Counter_Array := Wdg.Counters.Get;
   begin
      Counters (Checkpoint) := Natural'Succ (Counters (Checkpoint));
      Wdg.Counters.Set (Counters);
   end Visit;

   procedure Initialize (Wdg : in out Watchdog_Type) is
   begin
      Reset_Counters (Wdg);
      Wdg.Is_Init := True;
   end Initialize;

   function Is_Initialized (Wdg : in Watchdog_Type) return Boolean is
      (Wdg.Is_Init);

   procedure Initialize_Checkpoint
      (Wdg                : in out Watchdog_Type;
       Checkpoint         :    out Checkpoint_Id;
       Period_Factor      : in     Positive;
       Minimum_Nof_Visits : in     Natural;
       Allowed_Misses     : in     Natural)
   is
      Id : constant Checkpoint_Valid_Id :=
         Checkpoint_Id'Succ (Wdg.Nof_Monitored_Checkpoints);
   begin
      Wdg.Supervision (Id) := (Factor             => Period_Factor,
                               Counter            => 0,
                               Minimum_Nof_Visits => Minimum_Nof_Visits,
                               Nof_Misses         => 0,
                               Nof_Misses_Max     => Allowed_Misses);

      Wdg.Set_Counter (Id, 0);
      Wdg.Nof_Monitored_Checkpoints := Id;
      Checkpoint := Id;
   end Initialize_Checkpoint;

end Watchdog;
