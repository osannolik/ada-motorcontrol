with Generic_ABC;

generic
   type Datatype is digits <>;
   --  Datatype is used as type for each component.
   --  Must have Float as basis.
package Generic_DQ is



   type Dq is tagged record
      D : Datatype;
      Q : Datatype;
   end record;

   function "+"(X,Y : in Dq) return Dq;

   function "-"(X,Y : in Dq) return Dq;

   function "*"(X : in Dq; c : in Datatype) return Dq;

   function "*"(c : in Datatype; X : in Dq) return Dq;

   function "/"(X : in Dq; c : in Datatype) return Dq;

   function Magnitude(X : in Dq) return Datatype
      with
         Inline;

   procedure Normalize(X : in out Dq);

end Generic_DQ;
