package Startup is
   --  @summary
   --  Startup Handling
   --
   --  @description
   --  This packages handles the startup procedures and initialization of used
   --  peripherals and other packages.
   --

   function Is_Initialized
      return Boolean;
   --  @return True when initialized.

   procedure Initialize;
   --  Initializes peripherals and configures them into a known state

private

   Initialized    : Boolean := False;

end Startup;
