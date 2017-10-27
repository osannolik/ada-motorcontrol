package body AMC_Utils.Cum_Avg is

   procedure Add (C_Avg : in out Cumulative_Average;
                  Value : in     Element_T)
   is
      N : constant Natural := Natural'Succ (C_Avg.N);
   begin
      C_Avg := Cumulative_Average'
         (Mean => C_Avg.Mean + (Value - C_Avg.Mean) / Element_T (N),
          N    => N);
   end Add;

   procedure Set (C_Avg : in out Cumulative_Average;
                  Value : in     Element_T)
   is
   begin
      C_Avg := Cumulative_Average'(Mean => Value,
                                   N    => 1);
   end Set;

   function Get (C_Avg : in Cumulative_Average) return Element_T is
      (C_Avg.Mean);

end AMC_Utils.Cum_Avg;
