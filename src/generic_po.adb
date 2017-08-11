package body Generic_PO is
   protected body Shared_Data is

      function Get return Datatype is
      begin
         return Data;
      end Get;

      procedure Set(Value : in Datatype) is
      begin
         Data := Value;
      end Set;

   end Shared_Data;
end Generic_PO;
