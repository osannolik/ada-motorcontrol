with System;

generic
   type Item_Type is private;
   Items_Max : Positive;

package Generic_Queue is

   Queue_Is_Full  : exception;
   Queue_Is_Empty : exception;

   type Item_Array is array (Natural range <>) of Item_Type;

   subtype Index is Natural range 0 .. Items_Max;
   --  Length is Items_Max + 1

   protected type Protected_Queue (Ceiling : System.Priority) is

      function Is_Empty return Boolean;

      function Is_Full return Boolean;

      procedure Push (Item : in Item_Type);

      procedure Push (Items : in Item_Array);

      procedure Pull (Item : out Item_Type);

      procedure Pull (N : in Natural;
                      Items_Access : access Item_Array);

      function Peek (N : in Positive) return Item_Type;

      function Peek return Item_Type;

      function Peek (N : in Positive) return Item_Array;

      function Occupied_Slots return Natural;

      function Empty_Slots return Natural;

      procedure Flush (N : in Natural);

      procedure Flush_All;

   private
      pragma Priority (Ceiling);
      --  All callers must have priority no greater than Ceiling

      QItems   : Item_Array (Index'Range);

      Idx_New : Index := 0;
      Idx_Old : Index := 0;

   end Protected_Queue;

end Generic_Queue;
