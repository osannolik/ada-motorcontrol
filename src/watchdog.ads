with Generic_PO;
with Config;

package Watchdog is
   --  @summary
   --  Watchdog Controller
   --
   --  @description
   --  ...
   --

   Nof_Checkpoints_Max : constant := 4;

   type Checkpoint_Id is new Natural range 0 .. Nof_Checkpoints_Max;

   subtype Checkpoint_Valid_Id is Checkpoint_Id range 1 .. Checkpoint_Id'Last;

   type Watchdog_Type is tagged limited private;

   procedure Update (Wdg     : in out Watchdog_Type;
                     Refresh :    out Boolean);

   procedure Visit (Wdg        : in out Watchdog_Type;
                    Checkpoint : in     Checkpoint_Valid_Id);

   procedure Initialize (Wdg : in out Watchdog_Type);

   function Is_Initialized (Wdg : in Watchdog_Type) return Boolean;

   procedure Initialize_Checkpoint
      (Wdg                : in out Watchdog_Type;
       Checkpoint         :    out Checkpoint_Id;
       Period_Factor      : in     Positive;
       Minimum_Nof_Visits : in     Natural;
       Allowed_Misses     : in     Natural)
      with Post => Checkpoint >= Checkpoint_Valid_Id'First;

private

   type Counter_Array is array (Checkpoint_Valid_Id'Range) of Natural;

   package PO_Pack is new Generic_PO (Counter_Array);
   subtype Protected_Counter_Array is
      PO_Pack.Shared_Data (Config.Protected_Object_Prio);

   type Supervision_Data is record
      Factor             : Positive;
      Counter            : Natural;
      Minimum_Nof_Visits : Natural;
      Nof_Misses         : Natural;
      Nof_Misses_Max     : Natural;
   end record;

   type Supervision_Data_Array is array (Checkpoint_Valid_Id'Range) of Supervision_Data;

   type Watchdog_Type is tagged limited record
      Counters                  : Protected_Counter_Array;
      Supervision               : Supervision_Data_Array;
      Nof_Monitored_Checkpoints : Checkpoint_Id := 0;
      Is_Init                   : Boolean := False;
   end record;

end Watchdog;
