package body Generic_Queue is

   protected body Protected_Queue is

      function Is_Empty return Boolean is
         (Idx_Old = Idx_New);

      function Is_Full return Boolean is
         (Idx_Old = ((Idx_New + 1) mod (Index'Last + 1)));

      procedure Push (Item : in Item_Type) is
         Idx_Next : constant Index := (Idx_New + 1) mod (Index'Last + 1);
      begin
         if Idx_Next = Idx_Old then
            raise Queue_Is_Full;
         end if;
         QItems (Idx_New) := Item;
         Idx_New := Idx_Next;
      end Push;

      procedure Push (Items : in Item_Array) is
      begin
         if Items'Length > Empty_Slots then
            raise Constraint_Error;
         end if;
         for I of Items loop
            Push (Item => I);
         end loop;
      end Push;

      procedure Pull (Item : out Item_Type) is
      begin
         if Is_Empty then
            raise Queue_Is_Empty;
         end if;
         Item := QItems (Idx_Old);
         Idx_Old := (Idx_Old + 1) mod (Index'Last + 1);
      end Pull;

      procedure Pull (N : in Natural;
                      Items_Access : access Item_Array) is
      begin
         if Is_Empty then
            raise Queue_Is_Empty;
         elsif N > Occupied_Slots then
            raise Constraint_Error;
         end if;
         for Idx in Index'First .. Index'First + N - 1 loop
            Pull (Item => Items_Access (Idx));
         end loop;
      end Pull;

      function Peek (N : in Positive) return Item_Type is
         Idx_Peek : constant Index := (Idx_Old + N - 1) mod (Index'Last + 1);
      begin
         if Is_Empty then
            raise Queue_Is_Empty;
         elsif N > Occupied_Slots then
            raise Constraint_Error;
         end if;
         return QItems (Idx_Peek);
      end Peek;

      function Peek return Item_Type is
      begin
         if Is_Empty then
            raise Queue_Is_Empty;
         end if;
         return QItems (Idx_Old);
      end Peek;

      function Occupied_Slots return Natural is
      begin
         if Idx_New >= Idx_Old then
            return Idx_New - Idx_Old;
         else
            return Index'Last - Idx_Old + 1 + Idx_New - Index'First;
         end if;
      end Occupied_Slots;

      function Empty_Slots return Natural is
      begin
         return Items_Max - Occupied_Slots;
      end Empty_Slots;

      procedure Flush (N : in Natural) is
      begin
         Idx_Old := (Idx_Old + N) mod (Index'Last + 1);
      end Flush;

      procedure Flush_All is
      begin
         Idx_Old := Idx_New;
      end Flush_All;

   end Protected_Queue;

end Generic_Queue;
