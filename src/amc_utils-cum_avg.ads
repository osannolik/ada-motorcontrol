generic

   type Element_T is digits <>;

package AMC_Utils.Cum_Avg is

   type Cumulative_Average is tagged record
      Mean : Element_T := 0.0;
      N    : Natural   := Natural'First;
   end record;

   procedure Add (C_Avg : in out Cumulative_Average;
                  Value : in     Element_T);

   procedure Set (C_Avg : in out Cumulative_Average;
                  Value : in     Element_T);

   function Get (C_Avg : in Cumulative_Average)
                 return Element_T;

end AMC_Utils.Cum_Avg;
