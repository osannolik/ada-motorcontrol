with System;

generic
   type Item_Type is private;
   Items_Max : Positive;

package Generic_Queue is
   --  @summary
   --  FIFO queue implementation
   --
   --  @description
   --  Implements a generic first-in-first-out queue object that is thread safe.
   --

   Queue_Is_Full  : exception;
   Queue_Is_Empty : exception;

   type Item_Array is array (Natural range <>) of Item_Type;

   subtype Index is Natural range 0 .. Items_Max;
   --  Length is Items_Max + 1

   protected type Protected_Queue (Ceiling : System.Priority) is

      function Is_Empty return Boolean;
      --  @return True if the queue if empty.

      function Is_Full return Boolean;
      --  @return True if the queue if full.

      procedure Push (Item : in Item_Type);
      --  Push an item into the queue and put it last.
      --  @param Item The item.

      procedure Push (Items : in Item_Array);
      --  Push an array of items into the queue and put it last.
      --  @param Items The item array.

      procedure Pull (Item : out Item_Type);
      --  Pull an item from the front of the queue.
      --  @param Item The item.

      procedure Pull (N : in Natural;
                      Items_Access : access Item_Array);
      --  Pull N items from the front of the queue.
      --  @param N The number of items.
      --  @param Items_Access A reference to the item array the pulled items will
      --  be placed in.

      function Peek (N : in Positive) return Item_Type;
      --  Peek N slots into the queue. N=1 is the front most item.
      --  @param N The number of queue slots.

      function Peek return Item_Type;
      --  Peek the front item.
      --  @return The front most queue item.

      function Peek (N : in Positive) return Item_Array;
      --  Peek N number of items.
      --  @param N The number of items to peek.
      --  @return An array of the peeked items.

      function Occupied_Slots return Natural;
      --  @return The number of items in the queue.

      function Empty_Slots return Natural;
      --  @return The number of available slots in the queue.

      procedure Flush (N : in Natural);
      --  Throw away N number of items from the front of the queue.
      --  @param N The number of items to flush.

      procedure Flush_All;
      --  Empty the queue, i.e. remove all items.

   private
      pragma Priority (Ceiling);
      --  All callers must have priority no greater than Ceiling

      QItems   : Item_Array (Index'Range);

      Idx_New : Index := 0;
      Idx_Old : Index := 0;

   end Protected_Queue;

end Generic_Queue;
