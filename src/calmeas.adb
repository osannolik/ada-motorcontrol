with Ada.Unchecked_Conversion;

package body Calmeas is

   function Get_Symbol_Address (M : in Symbol_Meta)
                                return System.Address;

   function Get_Symbol_Size (Index : in Symbol_Index)
                             return Natural;

   function Get_Symbol_Value (Index : in Symbol_Index)
                              return AMC_Types.Byte_Array
   with
      Pre => Index < Nof_Symbols_Added;

   procedure Add (Tc          : Type_Access;
                  Name        : String;
                  Description : String);

   procedure Send_Meta (To_Port : access Communication.Port_Type;
                        Error   : out Boolean);

   procedure Send_Raster_Periods (To_Port : access Communication.Port_Type;
                                  Error   : out Boolean);

   procedure Send_Symbol_Name (Data    : access Byte_Array;
                               To_Port : access Communication.Port_Type;
                               Error   : out Boolean);

   procedure Send_Symbol_Description (Data    : access Byte_Array;
                                      To_Port : access Communication.Port_Type;
                                      Error   : out Boolean);

   procedure Set_Rasters (Data    : access Byte_Array;
                          Error   : out Boolean);



   procedure Sample (To_Port : access Communication.Port_Type) is
   begin
      for I in Rasters'Range loop
         declare
            R : Raster renames Rasters (I);
         begin
            R.Cnt := R.Cnt + 1;
            if R.Cnt >= Raster_Periods (I) then
               R.Cnt := 0;
               if R.Nof_Selected > 0 then
                  declare
                     Buffer : Byte_Array (0 .. R.Buffer_Length);
                     Symbol_Size : Natural;
                     Idx : Natural := 1;
                  begin
                     Buffer (0) := AMC_Types.UInt8 (I);
                     for Sym_Idx of R.List (1 .. R.Nof_Selected) loop
                        Symbol_Size := Get_Symbol_Size (Sym_Idx);
                        Buffer (Idx .. Idx + Symbol_Size - 1) := Get_Symbol_Value (Sym_Idx);
                        Idx := Idx + Symbol_Size;
                     end loop;
                     if To_Port /= null then
                        Communication_Interface.Send (Port       => To_Port,
                                                      Identifier => Id_Raster,
                                                      Data       => Buffer);
                     end if;
                  end;
               end if;
            end if;
         end;
      end loop;
   end Sample;


   procedure Set_Rasters (Data    : access Byte_Array;
                          Error   : out Boolean) is
      Raster : Raster_Index;
      Data_Length : constant Natural := Data'Length;
   begin
      Error := (Data_Length = 0) or (Data_Length - 1 > Raster_List_Length_Max);
      if not Error then
         Raster := Raster_Index (Data (0));
         Rasters (Raster).Nof_Selected := Data_Length - 1;
         Rasters (Raster).Buffer_Length := 0;
         for I in 1 .. Data_Length - 1 loop
            declare
               Sym_Idx : constant Symbol_Index := Symbol_Index (Data (I));
            begin
               Rasters (Raster).List (I) := Sym_Idx;
               Rasters (Raster).Buffer_Length :=
                  Rasters (Raster).Buffer_Length + Get_Symbol_Size (Sym_Idx);
            end;
         end loop;
      end if;
   end Set_Rasters;


   procedure Send_Symbol_Description (Data    : access Byte_Array;
                                      To_Port : access Communication.Port_Type;
                                      Error   : out Boolean) is
      Index : Symbol_Index;
      Stop_Idx : Desc_String_Index := Desc_String_Index'First;
   begin
      Error := (Data'Length /= 1);

      if not Error then
         Index := Symbol_Index (Data (0));
         loop
            exit when Symbols (Index).Description (Stop_Idx) = Char_NUL;
            Stop_Idx := Desc_String_Index'Succ (Stop_Idx);
         end loop;

         if Stop_Idx /= Desc_String_Index'First then
            Stop_Idx := Desc_String_Index'Pred (Stop_Idx); --  Skip nul
            declare
               subtype Desc_Array is Byte_Array (0 .. Stop_Idx - 1);
               subtype Desc_String is String (1 .. Stop_Idx);
               function To_Array is new Ada.Unchecked_Conversion (Source => Desc_String,  Target => Desc_Array);
            begin
               Communication_Interface.Send
                  (Port       => To_Port,
                   Identifier => Id_Symbol_Desc,
                   Data       => To_Array (Symbols (Index).Description (1 .. Stop_Idx)));
            end;
         else
            Communication_Interface.Send
               (Port       => To_Port,
                Identifier => Id_Symbol_Desc,
                Data       => AMC_Types.Empty_Byte_Array);
         end if;
      end if;
   end Send_Symbol_Description;


   procedure Send_Symbol_Name (Data    : access Byte_Array;
                               To_Port : access Communication.Port_Type;
                               Error   : out Boolean) is
      Index :  Symbol_Index;
      Stop_Idx : Name_String_Index := Name_String_Index'First;
   begin
      Error := (Data'Length /= 1);

      if not Error then
         Index := Symbol_Index (Data (0));
         loop
            exit when Symbols (Index).Name (Stop_Idx) = Char_NUL;
            Stop_Idx := Name_String_Index'Succ (Stop_Idx);
         end loop;

         Stop_Idx := Name_String_Index'Pred (Stop_Idx); --  Skip nul

         declare
            subtype Name_Array is Byte_Array (0 .. Stop_Idx - 1);
            subtype Name_String is String (1 .. Stop_Idx);
            function To_Array is new Ada.Unchecked_Conversion (Source => Name_String,  Target => Name_Array);
         begin
            Communication_Interface.Send
               (Port       => To_Port,
                Identifier => Id_Symbol_Name,
                Data       => To_Array (Symbols (Index).Name (1 .. Stop_Idx)));
         end;
      end if;
   end Send_Symbol_Name;


   procedure Send_Raster_Periods (To_Port : access Communication.Port_Type;
                                  Error   : out Boolean) is
      type Send_Raster_Periods_Template is
         array (0 .. Raster_Periods'Length - 1) of AMC_Types.UInt32;

      Length : constant Natural := (Send_Raster_Periods_Template'Size / 8);

      subtype Raster_Array is Byte_Array (0 .. Length - 1);
      function To_Array is new Ada.Unchecked_Conversion
         (Source => Send_Raster_Periods_Template,  Target => Raster_Array);

      Raster_Data : Send_Raster_Periods_Template;
      Idx : Natural := 0;
   begin
      for I in Raster_Periods'Range loop
         Raster_Data (Idx) := AMC_Types.UInt32 (Raster_Periods (I));
         Idx := Natural'Succ (Idx);
      end loop;

      Communication_Interface.Send
         (Port       => To_Port,
          Identifier => Id_Raster_Periods,
          Data       => To_Array (Raster_Data));

      Error := False;
   end Send_Raster_Periods;


   procedure Send_Meta (To_Port : access Communication.Port_Type;
                        Error   : out Boolean) is

      type Send_Meta_Template is record
         Tc        : Typecode;
         Name_Addr : System.Address;
         Sym_Addr  : System.Address;
         Desc_Addr : System.Address;
      end record
         with Size => 104;

      for Send_Meta_Template use record
         Tc        at 0 range 0 .. 7;
         Name_Addr at 0 range 8 .. 39;
         Sym_Addr  at 0 range 40 .. 71;
         Desc_Addr at 0 range 72 .. 103;
      end record;

      Item_Length : constant Natural := Send_Meta_Template'Size / 8;

      subtype Meta_Array_Item is Byte_Array (0 .. Item_Length - 1);
      function To_Array is new Ada.Unchecked_Conversion (Source => Send_Meta_Template,  Target => Meta_Array_Item);

      Meta_Data      : Byte_Array (0 .. Nof_Symbols * Item_Length - 1);
      Meta_Tmp       : Send_Meta_Template;
      Item_Start_Idx : Natural := Natural'First;
   begin
      for M of Symbols loop
         if M.Is_Set then
            Meta_Tmp := Send_Meta_Template'(Tc        => M.Symbol_Access.Tc,
                                            Name_Addr => M.Name'Address,
                                            Sym_Addr  => Get_Symbol_Address (M),
                                            Desc_Addr => M.Description'Address);
            Meta_Data (Item_Start_Idx .. Item_Start_Idx + Item_Length - 1) :=
               To_Array (Meta_Tmp);
            Item_Start_Idx := Item_Start_Idx + Item_Length;
         end if;
      end loop;

      Communication_Interface.Send
         (Port       => To_Port,
          Identifier => Id_Meta,
          Data       => Meta_Data);

      Error := False;
   end Send_Meta;


   procedure Callback_Handler (Identifier : in Communication.Identifier_Type;
                               Data       : access Byte_Array;
                               From_Port  : access Communication.Port_Type) is
      Error : Boolean;
   begin

      case Identifier is
         when Id_Meta =>
            Send_Meta (To_Port => From_Port,
                       Error   => Error);

         when Id_Raster_Set =>
            Set_Rasters (Data    => Data,
                         Error   => Error);

         when Id_Symbol_Name =>
            Send_Symbol_Name (Data    => Data,
                              To_Port => From_Port,
                              Error   => Error);

         when Id_Symbol_Desc =>
            Send_Symbol_Description (Data    => Data,
                                     To_Port => From_Port,
                                     Error   => Error);

         when Id_Raster_Periods =>
            Send_Raster_Periods (To_Port => From_Port,
                                 Error   => Error);

         when Id_All =>
            null;

         when Id_Stream_All =>
            null;

         when Id_Raster =>
            null;

         when others =>
            Error := True;

      end case;

      if Error then
         Communication.Commands_Send_Error (Port                     => From_Port,
                                            Causing_Interface_Number => Interface_Number);
      end if;
   end Callback_Handler;


   procedure Add (Tc          : Type_Access;
                  Name        : String;
                  Description : String)
   is
      Meta     : Symbol_Meta;
      Name_Tmp : String (Name_String_Index'Range) := (others => Char_NUL);
      Desc_Tmp : String (Desc_String_Index'Range) := (others => Char_NUL);
   begin
      if Name = "" then
         raise Must_Provide_Symbol_Name;
      end if;

      if Name'Length > Name_Length_Max or Description'Length > Desc_Length_Max then
         raise Constraint_Error;
      end if;

      for I in Name'Range loop
         Name_Tmp (I) := Name (I);
      end loop;

      for I in Description'Range loop
         Desc_Tmp (I) := Description (I);
      end loop;

      Meta := Symbol_Meta'(Is_Set        => True,
                           Name          => Name_Tmp,
                           Description   => Desc_Tmp,
                           Symbol_Access => Tc);

      Symbols (Nof_Symbols) := Meta;

      Nof_Symbols := Natural'Succ (Nof_Symbols);
   end Add;


   procedure Add (Symbol : access AMC_Types.UInt8;
                  Name   : String;
                  Description : String := "")
   is
      Tc : constant Type_Access := Type_Access'(Tc            => Tc_UInt8,
                                                UInt8_Access  => Symbol);
   begin
      Add (Tc          => Tc,
           Name        => Name,
           Description => Description);
   end Add;

   procedure Add (Symbol      : access AMC_Types.UInt16;
                  Name        : String;
                  Description : String := "")
   is
      Tc : constant Type_Access := Type_Access'(Tc            => Tc_UInt16,
                                                UInt16_Access => Symbol);
   begin
      Add (Tc          => Tc,
           Name        => Name,
           Description => Description);
   end Add;

   procedure Add (Symbol      : access AMC_Types.UInt32;
                  Name        : String;
                  Description : String := "")
   is
      Tc : constant Type_Access := Type_Access'(Tc            => Tc_UInt32,
                                                UInt32_Access => Symbol);
   begin
      Add (Tc          => Tc,
           Name        => Name,
           Description => Description);
   end Add;

   procedure Add (Symbol      : access AMC_Types.Int8;
                  Name        : String;
                  Description : String := "")
   is
      Tc : constant Type_Access := Type_Access'(Tc          => Tc_Int8,
                                                Int8_Access => Symbol);
   begin
      Add (Tc          => Tc,
           Name        => Name,
           Description => Description);
   end Add;

   procedure Add (Symbol      : access AMC_Types.Int16;
                  Name        : String;
                  Description : String := "")
   is
      Tc : constant Type_Access := Type_Access'(Tc           => Tc_Int16,
                                                Int16_Access => Symbol);
   begin
      Add (Tc          => Tc,
           Name        => Name,
           Description => Description);
   end Add;

   procedure Add (Symbol      : access AMC_Types.Int32;
                  Name        : String;
                  Description : String := "")
   is
      Tc : constant Type_Access := Type_Access'(Tc          => Tc_Int32,
                                                Int32_Access => Symbol);
   begin
      Add (Tc          => Tc,
           Name        => Name,
           Description => Description);
   end Add;

   procedure Add (Symbol      : access Float;
                  Name        : String;
                  Description : String := "")
   is
      Tc : constant Type_Access := Type_Access'(Tc           => Tc_Float,
                                                Float_Access => Symbol);
   begin
      Add (Tc          => Tc,
           Name        => Name,
           Description => Description);
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

         when Tc_Address =>
            return AMC_Types.Empty_Byte_Array;

      end case;
   end Get_Symbol_Value;

   function Get_Symbol_Address (M : in Symbol_Meta)
                                return System.Address is
   begin
      case M.Symbol_Access.Tc is
         when Tc_Float =>
            return M.Symbol_Access.Float_Access.all'Address;

         when Tc_UInt8 =>
            return M.Symbol_Access.UInt8_Access.all'Address;

         when Tc_UInt16 =>
            return M.Symbol_Access.UInt16_Access.all'Address;

         when Tc_UInt32 =>
            return M.Symbol_Access.UInt32_Access.all'Address;

         when Tc_Int8 =>
            return M.Symbol_Access.Int8_Access.all'Address;

         when Tc_Int16 =>
            return M.Symbol_Access.Int16_Access.all'Address;

         when Tc_Int32 =>
            return M.Symbol_Access.Int32_Access.all'Address;

         when Tc_Address =>
            return M.Symbol_Access.Address;

      end case;
   end Get_Symbol_Address;

   function Get_Symbol_Size (Index : in Symbol_Index)
                             return Natural is
      M : Symbol_Meta renames Symbols (Index);
   begin
      case M.Symbol_Access.Tc is
         when Tc_Float =>
            return M.Symbol_Access.Float_Access.all'Size / 8;

         when Tc_UInt8 =>
            return M.Symbol_Access.UInt8_Access.all'Size / 8;

         when Tc_UInt16 =>
            return M.Symbol_Access.UInt16_Access.all'Size / 8;

         when Tc_UInt32 =>
            return M.Symbol_Access.UInt32_Access.all'Size / 8;

         when Tc_Int8 =>
            return M.Symbol_Access.Int8_Access.all'Size / 8;

         when Tc_Int16 =>
            return M.Symbol_Access.Int16_Access.all'Size / 8;

         when Tc_Int32 =>
            return M.Symbol_Access.Int32_Access.all'Size / 8;

         when Tc_Address =>
            return 0;

      end case;
   end Get_Symbol_Size;

   function Nof_Symbols_Added return Natural is
      (Nof_Symbols);

begin

   Communication_Interface.Initialize (Interface_Number => Interface_Number);

end Calmeas;
