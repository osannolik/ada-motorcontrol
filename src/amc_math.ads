with Ada.Numerics.Elementary_Functions;
with Cortex_M.FPU;

package AMC_Math is
   --  @summary
   --  Ada Motor Controller math functionality
   --
   --  @description
   --  This package includes some mathematical constants and functions.
   --

   Pi : constant Float := Ada.Numerics.Pi;

   function Sqrt (X : in Float) return Float renames Cortex_M.FPU.Sqrt;
   --  Uses the built-in square root instruction of the FPU
   --  @param X Input
   --  @return The square root of input X

   --------------------------------------------------------
   --  The following requires the use of ravenscar-full  --
   --------------------------------------------------------

   function Sin (X : in Float) return Float renames
      Ada.Numerics.Elementary_Functions.Sin;
   --  @param X Input angle in [rad]
   --  @return Sin of input X

   function Cos (X : in Float) return Float renames
      Ada.Numerics.Elementary_Functions.Cos;
   --  @param X Input angle in [rad]
   --  @return Cos of input X

   function Log (X : in Float) return Float renames
      Ada.Numerics.Elementary_Functions.Log;
   --  @param X Input
   --  @return Logarithm of input X

end AMC_Math;
