generic

   N : Positive;

   type Datatype is digits <>;

package AMC_Utils.Moving_Avg is

   type History_Index is private;

   type History_Type is private;

   type Moving_Average is tagged private;

   procedure Update (Ma    : in out Moving_Average;
                     Value : in     Datatype);

   procedure Set (Ma    : in out Moving_Average;
                  Value : in     Datatype);

   function Get (Ma : in Moving_Average) return Datatype;

private

   type History_Index is new Positive range Positive'First .. N;

   type History_Type is array (History_Index'Range) of Datatype;

   Reset_Value : constant Datatype := 0.0;

   type Moving_Average is tagged record
      Index   : History_Index := History_Index'First;
      History : History_Type  := (others => Reset_Value);
      Output  : Datatype      := Reset_Value;
   end record;

end AMC_Utils.Moving_Avg;
