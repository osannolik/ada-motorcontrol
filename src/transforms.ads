with AMC_Types;

package Transforms is
   --  @summary
   --  Transforms
   --
   --  @description
   --  This package implements various transformations.
   --
   --  Clarke transform currently assumes the scaling factor k = 2/3
   --

   Factor_Default : constant Float := 2.0 / 3.0;


   function Clarke (X : in AMC_Types.Abc;
                    K : in Float := Factor_Default)
                    return AMC_Types.Alfa_Beta;
   --  Implements the Clarke transformation (Alpha-Beta), i.e. transforms
   --  a three-dimensional vector to a corresponding two-dimensional vector,
   --  assuming the vector components sum to 0.
   --  @param X Input vector.
   --  @param K Optional parameter defining the scaling.

   function Clarke_Inv (X : in AMC_Types.Alfa_Beta;
                        K : in Float := Factor_Default)
                        return AMC_Types.Abc;
   --  Implements the inverse Clarke transformation (Alpha-Beta), i.e. transforms
   --  a two-dimensional vector to a corresponding three-dimensional vector,
   --  assuming the final vector components sum to 0.
   --  @param X Input vector.
   --  @param K Optional parameter defining the scaling.

   function Park (X : in AMC_Types.Alfa_Beta;
                  Angle : in AMC_Types.Angle_Rad)
                  return AMC_Types.Dq;
   --  Transforms a balanced two-phase orthogonal stationary vector into an
   --  orthogonal rotating reference frame, given the an angle.
   --  @param X Input vector.
   --  @param Angle The angle between the first axis of the both reference frames.

   function Park (X : in AMC_Types.Alfa_Beta;
                  Angle : in AMC_Types.Angle)
                  return AMC_Types.Dq;
   --  Transforms a balanced two-phase orthogonal stationary vector into an
   --  orthogonal rotating reference frame, given the an angle.
   --  @param X Input vector.
   --  @param Angle The angle between the first axis of the both reference frames.

   function Park_Inv (X : in AMC_Types.Dq;
                      Angle : in AMC_Types.Angle_Rad)
                      return AMC_Types.Alfa_Beta;
   --  Implements the inverse transformation of Park transformation.
   --  @param X Input vector.
   --  @param Angle The angle between the first axis of the both reference frames.

   function Park_Inv (X : in AMC_Types.Dq;
                      Angle : in AMC_Types.Angle)
                      return AMC_Types.Alfa_Beta;
   --  Implements the inverse transformation of Park transformation.
   --  @param X Input vector.
   --  @param Angle The angle between the first axis of the both reference frames.

end Transforms;
