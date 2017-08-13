with AMC_Types;

package Transforms is
   --  Clarke transform currently assumes k = 2/3

   Factor_Default : constant Float := 2.0 / 3.0;

   function Factor return Float;

   function Clarke (X : in AMC_Types.Abc;
                    K : in Float := Factor_Default)
                    return AMC_Types.Alfa_Beta;

   function Clarke_Inv (X : in AMC_Types.Alfa_Beta;
                        K : in Float := Factor_Default)
                        return AMC_Types.Abc;

   function Park (X : in AMC_Types.Alfa_Beta;
                  Angle : in AMC_Types.Angle_Rad)
                  return AMC_Types.Dq;

   function Park (X : in AMC_Types.Alfa_Beta;
                  Angle : in AMC_Types.Angle)
                  return AMC_Types.Dq;

   function Park_Inv (X : in AMC_Types.Dq;
                      Angle : in AMC_Types.Angle_Rad)
                      return AMC_Types.Alfa_Beta;

   function Park_Inv (X : in AMC_Types.Dq;
                      Angle : in AMC_Types.Angle)
                      return AMC_Types.Alfa_Beta;

end Transforms;
