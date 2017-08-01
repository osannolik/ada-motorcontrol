with AMC.Board;
--  with AMC.ADC;
with AMC.PWM;

pragma Elaborate(AMC.Board);
pragma Elaborate(AMC.PWM);

package body AMC is

   procedure Initialize
   is
   begin
      AMC.Board.Initialize;
      --  AMC.ADC.Initialize;
      AMC.PWM.Initialize;

      Initialized :=
        AMC.Board.Is_Initialized and
        --  AMC.ADC.Is_Initialized and
        AMC.PWM.Is_Initialized;
        --  and AMC.Child.Is_initialized;

   end Initialize;

   function Is_Initialized
      return Boolean is (Initialized);

begin

   Initialize;

end AMC;
