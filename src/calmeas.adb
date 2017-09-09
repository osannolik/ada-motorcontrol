with Ada.Unchecked_Conversion;

package body Calmeas is

   procedure Add (Tc   : Type_Access;
                  Name : String);


   procedure Add (Tc   : Type_Access;
                  Name : String)
   is
      Meta : Symbol_Meta;
      Name_Tmp : String (Name_String_Index'Range) := (others => Char_NUL);
   begin
      for I in Name'Range loop
         Name_Tmp (I) := Name (I);
      end loop;

      Meta := Symbol_Meta'(Name          => Name_Tmp,
                           Symbol_Access => Tc);

      Symbols (Nof_Symbols) := Meta;

      Nof_Symbols := Natural'Succ (Nof_Symbols);
   end Add;


   procedure Add (Symbol : access AMC_Types.UInt8;
                  Name   : String)
   is
      Tc : constant Type_Access := Type_Access'(Tc            => Tc_UInt8,
                                                UInt8_Access  => Symbol);
   begin
      Add (Tc   => Tc,
           Name => Name);
   end Add;

   procedure Add (Symbol : access AMC_Types.UInt16;
                  Name   : String)
   is
      Tc : constant Type_Access := Type_Access'(Tc            => Tc_UInt16,
                                                UInt16_Access => Symbol);
   begin
      Add (Tc   => Tc,
           Name => Name);
   end Add;

   procedure Add (Symbol : access AMC_Types.UInt32;
                  Name   : String)
   is
      Tc : constant Type_Access := Type_Access'(Tc            => Tc_UInt32,
                                                UInt32_Access => Symbol);
   begin
      Add (Tc   => Tc,
           Name => Name);
   end Add;

   procedure Add (Symbol : access AMC_Types.Int8;
                  Name   : String)
   is
      Tc : constant Type_Access := Type_Access'(Tc          => Tc_Int8,
                                                Int8_Access => Symbol);
   begin
      Add (Tc   => Tc,
           Name => Name);
   end Add;

   procedure Add (Symbol : access AMC_Types.Int16;
                  Name   : String)
   is
      Tc : constant Type_Access := Type_Access'(Tc           => Tc_Int16,
                                                Int16_Access => Symbol);
   begin
      Add (Tc   => Tc,
           Name => Name);
   end Add;

   procedure Add (Symbol : access AMC_Types.Int32;
                  Name   : String)
   is
      Tc : constant Type_Access := Type_Access'(Tc          => Tc_Int32,
                                                Int32_Access => Symbol);
   begin
      Add (Tc   => Tc,
           Name => Name);
   end Add;

   procedure Add (Symbol : access Float;
                  Name   : String)
   is
      Tc : constant Type_Access := Type_Access'(Tc           => Tc_Float,
                                                Float_Access => Symbol);
   begin
      Add (Tc   => Tc,
           Name => Name);
   end Add;

   function Get_Symbol_Value (Index : in Symbol_Index)
                              return AMC_Types.Byte_Array
   is
      subtype Array_1B is Byte_Array (0 .. 0);
      subtype Array_2B is Byte_Array (0 .. 1);
      subtype Array_4B is Byte_Array (0 .. 3);
      function To_Array is new Ada.Unchecked_Conversion (Source => AMC_Types.UInt8,  Target => Array_1B);
      function To_Array is new Ada.Unchecked_Conversion (Source => AMC_Types.Int8,   Target => Array_1B);
      function To_Array is new Ada.Unchecked_Conversion (Source => AMC_Types.UInt16, Target => Array_2B);
      function To_Array is new Ada.Unchecked_Conversion (Source => AMC_Types.Int16,  Target => Array_2B);
      function To_Array is new Ada.Unchecked_Conversion (Source => AMC_Types.UInt32, Target => Array_4B);
      function To_Array is new Ada.Unchecked_Conversion (Source => AMC_Types.Int32,  Target => Array_4B);
      function To_Array is new Ada.Unchecked_Conversion (Source => Float,            Target => Array_4B);

      M : constant Symbol_Meta := Symbols (Index);
   begin
      case M.Symbol_Access.Tc is
         when Tc_Float =>
            return To_Array (M.Symbol_Access.Float_Access.all);

         when Tc_UInt8 =>
            return To_Array (M.Symbol_Access.UInt8_Access.all);

         when Tc_UInt16 =>
            return To_Array (M.Symbol_Access.UInt16_Access.all);

         when Tc_UInt32 =>
            return To_Array (M.Symbol_Access.UInt32_Access.all);

         when Tc_Int8 =>
            return To_Array (M.Symbol_Access.Int8_Access.all);

         when Tc_Int16 =>
            return To_Array (M.Symbol_Access.Int16_Access.all);

         when Tc_Int32 =>
            return To_Array (M.Symbol_Access.Int32_Access.all);

         when Tc_Unset =>
            return AMC_Types.Empty_Byte_Array;

      end case;
   end Get_Symbol_Value;


   function Nof_Symbols_Added return Natural is
      (Nof_Symbols);

end Calmeas;
