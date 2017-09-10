with AMC_Types; use AMC_Types;
with System;
with Communication;

package Calmeas is

   Nof_Symbols_Max : constant Positive := 32;

   subtype Symbol_Index is Natural range Natural'First .. Nof_Symbols_Max - 1;

   function Nof_Symbols_Added return Natural;

   procedure Add (Symbol : access AMC_Types.UInt8;
                  Name   : String)
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;

   procedure Add (Symbol : access AMC_Types.UInt16;
                  Name   : String)
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;

   procedure Add (Symbol : access AMC_Types.UInt32;
                  Name   : String)
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;

   procedure Add (Symbol : access AMC_Types.Int8;
                  Name   : String)
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;


   procedure Add (Symbol : access AMC_Types.Int16;
                  Name   : String)
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;


   procedure Add (Symbol : access AMC_Types.Int32;
                  Name   : String)
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;

   procedure Add (Symbol : access Float;
                  Name   : String)
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;

   function Get_Symbol_Value (Index : in Symbol_Index)
                              return AMC_Types.Byte_Array
   with
      Pre => Index < Nof_Symbols_Added;


   Communication_Interface : aliased Communication.Interface_Type;

   procedure Callback_Handler (Identifier : in Communication.Identifier_Type;
                               Data       : access Byte_Array;
                               From_Port  : in out Communication.Port_Type);

   Must_Provide_Symbol_Name : exception;

private



   type Typecode is (Tc_Address,
                     Tc_UInt8,
                     Tc_UInt16,
                     Tc_UInt32,
                     Tc_Int8,
                     Tc_Int16,
                     Tc_Int32,
                     Tc_Float);

   for Typecode use
      (Tc_Address => 16#00#,
       Tc_UInt8   => 16#01#,
       Tc_UInt16  => 16#02#,
       Tc_UInt32  => 16#04#,
       Tc_Int8    => 16#81#,
       Tc_Int16   => 16#82#,
       Tc_Int32   => 16#84#,
       Tc_Float   => 16#94#);

   type Type_Access (Tc : Typecode := Tc_Address)
   is record
      case Tc is
         when Tc_Address =>
            Address : System.Address;

         when Tc_UInt8 =>
            UInt8_Access : access AMC_Types.UInt8;

         when Tc_UInt16 =>
            UInt16_Access : access AMC_Types.UInt16;

         when Tc_UInt32 =>
            UInt32_Access : access AMC_Types.UInt32;

         when Tc_Int8 =>
            Int8_Access : access AMC_Types.Int8;

         when Tc_Int16 =>
            Int16_Access : access AMC_Types.Int16;

         when Tc_Int32 =>
            Int32_Access : access AMC_Types.Int32;

         when Tc_Float =>
            Float_Access : access Float;

      end case;
   end record;

   Char_NUL : constant Character := Character'Val (0);

   Name_Length_Max : constant Positive := 20;

   Desc_Length_Max : constant Positive := 20;

   subtype Name_String_Index is Positive range Positive'First .. Name_Length_Max;

   subtype Desc_String_Index is Positive range Positive'First .. Desc_Length_Max;

   type Symbol_Meta is record
      Is_Set        : Boolean := False;
      Name          : aliased String (Name_String_Index'Range) := (others => Char_NUL);
      Description   : aliased String (Desc_String_Index'Range) := (others => Char_NUL);
      Symbol_Access : Type_Access;
   end record;

   type Symbol_Table is array (Symbol_Index'Range) of Symbol_Meta;

   type Rasters is (Raster_1, Raster_2, Raster_3);

   Raster_Periods : array (Rasters'Range) of Positive :=
      (10, 100, 1000);


   Symbols     : Symbol_Table;
   Nof_Symbols : Natural := 0;


   Interface_Number : constant Communication.Interface_Number_Type := 3;

   Id_Meta           : constant Communication.Identifier_Type := 0;
   Id_All            : constant Communication.Identifier_Type := 1;
   Id_Stream_All     : constant Communication.Identifier_Type := 2;
   Id_Raster         : constant Communication.Identifier_Type := 3;
   Id_Raster_Set     : constant Communication.Identifier_Type := 4;
   Id_Symbol_Name    : constant Communication.Identifier_Type := 5;
   Id_Symbol_Desc    : constant Communication.Identifier_Type := 6;
   Id_Raster_Periods : constant Communication.Identifier_Type := 7;



end Calmeas;
