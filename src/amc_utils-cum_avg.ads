generic

   type Datatype is digits <>;

package AMC_Utils.Cum_Avg is

   type Cumulative_Average is tagged private;

   procedure Add (C_Avg : in out Cumulative_Average;
                  Value : in     Datatype);

   procedure Set (C_Avg : in out Cumulative_Average;
                  Value : in     Datatype);

   function Get (C_Avg : in Cumulative_Average)
                 return Datatype;

private

   type Cumulative_Average is tagged record
      Mean : Datatype := 0.0;
      N    : Natural  := Natural'First;
   end record;

end AMC_Utils.Cum_Avg;
