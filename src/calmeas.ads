with AMC_Types; use AMC_Types;
with System;
with Communication;

package Calmeas is
   --  @summary
   --  Calibration and Measurement
   --
   --  @description
   --  A tool that allows the user to add which variables that shall be
   --  available for logging and/or tuning.
   --
   --  The following example would declare X as a Calmeas symbol:
   --
   --   X : aliased Float;
   --   Calmeas.Add
   --     (Symbol      => X'Access,
   --      Name        => "X_Name",
   --      Description => "My X variable");
   --
   --  X is can then be found in the host gui.
   --
   --  See https://github.com/osannolik/calmeas for more info
   --

   Nof_Symbols_Max : constant Positive := 32;


   function Nof_Symbols_Added return Natural;
   --  @return The number of symbols that has been added


   procedure Add (Symbol      : access AMC_Types.UInt8;
                  Name        : String;
                  Description : String := "")
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;
   --  Make a UInt8 type symbol available for logging and tuning using the
   --  Calmeas host gui.
   --  @param Symbol An access to the variable to be added
   --  @param Name The name of the variable as seen on the gui
   --  @param Description An optional description string
   --  @exception Must_Provide_Symbol_Name raised
   --     if Name is empty.

   procedure Add (Symbol      : access AMC_Types.UInt16;
                  Name        : String;
                  Description : String := "")
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;
   --  Make a UInt16 type symbol available for logging and tuning using the
   --  Calmeas host gui.
   --  @param Symbol An access to the variable to be added
   --  @param Name The name of the variable as seen on the gui
   --  @param Description An optional description string
   --  @exception Must_Provide_Symbol_Name raised
   --     if Name is empty.

   procedure Add (Symbol      : access AMC_Types.UInt32;
                  Name        : String;
                  Description : String := "")
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;
   --  Make a UInt32 type symbol available for logging and tuning using the
   --  Calmeas host gui.
   --  @param Symbol An access to the variable to be added
   --  @param Name The name of the variable as seen on the gui
   --  @param Description An optional description string
   --  @exception Must_Provide_Symbol_Name raised
   --     if Name is empty.

   procedure Add (Symbol      : access AMC_Types.Int8;
                  Name        : String;
                  Description : String := "")
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;
   --  Make a Int8 type symbol available for logging and tuning using the
   --  Calmeas host gui.
   --  @param Symbol An access to the variable to be added
   --  @param Name The name of the variable as seen on the gui
   --  @param Description An optional description string
   --  @exception Must_Provide_Symbol_Name raised
   --     if Name is empty.

   procedure Add (Symbol      : access AMC_Types.Int16;
                  Name        : String;
                  Description : String := "")
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;
   --  Make a Int16 type symbol available for logging and tuning using the
   --  Calmeas host gui.
   --  @param Symbol An access to the variable to be added
   --  @param Name The name of the variable as seen on the gui
   --  @param Description An optional description string
   --  @exception Must_Provide_Symbol_Name raised
   --     if Name is empty.

   procedure Add (Symbol      : access AMC_Types.Int32;
                  Name        : String;
                  Description : String := "")
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;
   --  Make a Int32 type symbol available for logging and tuning using the
   --  Calmeas host gui.
   --  @param Symbol An access to the variable to be added
   --  @param Name The name of the variable as seen on the gui
   --  @param Description An optional description string
   --  @exception Must_Provide_Symbol_Name raised
   --     if Name is empty.

   procedure Add (Symbol      : access Float;
                  Name        : String;
                  Description : String := "")
   with
      Pre => Nof_Symbols_Added < Nof_Symbols_Max;
   --  Make a Float type symbol available for logging and tuning using the
   --  Calmeas host gui.
   --  @param Symbol An access to the variable to be added
   --  @param Name The name of the variable as seen on the gui
   --  @param Description An optional description string
   --  @exception Must_Provide_Symbol_Name raised
   --     if Name is empty.

   procedure Sample (To_Port : access Communication.Port_Type);
   --  Samples the added symbols and sends the data to the specified Port.
   --  Note: This needs to be run at a periodicity at least as short as the
   --  fastest raster period.
   --  @param To_Port Where to send the logged data


   Communication_Interface : aliased Communication.Interface_Type;
   --  An instance of an interface used to connect to a Communication.Port_Type


   procedure Callback_Handler (Identifier : in Communication.Identifier_Type;
                               Data       : access Byte_Array;
                               From_Port  : access Communication.Port_Type);
   --  This is called when new data is received on From_Port.
   --  Requests send available symbols, start raster sampling etc. is done via
   --  this callback.
   --  @param Identifier The Id number of the callback.
   --  @param Data An array containing the received data. It could be empty.
   --  @param From_Port The port from wich the data triggering the callback origins.

   Must_Provide_Symbol_Name : exception;
   --  Raised if the name string is empty

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

   Desc_Length_Max : constant Positive := 40;

   subtype Name_String_Index is Positive range Positive'First .. Name_Length_Max;

   subtype Desc_String_Index is Positive range Positive'First .. Desc_Length_Max;

   type Symbol_Meta is record
      Is_Set        : Boolean := False;
      Name          : aliased String (Name_String_Index'Range) := (others => Char_NUL);
      Description   : aliased String (Desc_String_Index'Range) := (others => Char_NUL);
      Symbol_Access : Type_Access;
   end record;

   subtype Symbol_Index is Natural range Natural'First .. Nof_Symbols_Max - 1;

   type Symbol_Table is array (Symbol_Index'Range) of Symbol_Meta;

   subtype Raster_Index is Natural range 0 .. 2;

   Raster_Periods : array (Raster_Index'Range) of Positive :=
      (1, 10, 100);

   Raster_List_Length_Max : constant Natural := 256;

   type Raster_List is array (1 .. Raster_List_Length_Max) of Symbol_Index;

   type Raster is record
      Cnt           : Natural := 0;
      Nof_Selected  : Natural := 0;
      List          : Raster_List;
      Buffer_Length : Natural := 0;
   end record;


   Rasters     : array (Raster_Index'Range) of Raster;
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
