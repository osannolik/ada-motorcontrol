with System;

generic
   type Datatype is private;
package Generic_PO is
   protected type Shared_Data (Ceiling : System.Priority) is

      function Get return Datatype;

      procedure Set (Value : in Datatype);

   private
      pragma Priority (Ceiling);
      --  All callers must have priority no greater than Ceiling

      Data : Datatype;

   end Shared_Data;
end Generic_PO;
