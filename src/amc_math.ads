with Ada.Numerics.Elementary_Functions;
with Cortex_M.FPU;

package AMC_Math is
   --  Ada Motor Controller math functions

   Pi : constant Float := Ada.Numerics.Pi;

   function Sqrt (X : in Float) return Float renames Cortex_M.FPU.Sqrt;
   --  Uses the built-in square root instruction of the FPU

   --------------------------------------------------------
   --  The following requires the use of ravenscar-full  --
   --------------------------------------------------------

   function Sin (X : in Float) return Float renames
      Ada.Numerics.Elementary_Functions.Sin;

   function Cos (X : in Float) return Float renames
      Ada.Numerics.Elementary_Functions.Cos;

end AMC_Math;
