generic
   type Datatype is digits <>;
   --  Datatype is used as type for each component.
   --  Must have Float as basis.
package Generic_ABC is

   type Abc is tagged record
      A : Datatype;
      B : Datatype;
      C : Datatype;
   end record;

   function "+"(X,Y : in Abc) return Abc;

   function "-"(X,Y : in Abc) return Abc;

   function "*"(X : in Abc; c : in Datatype) return Abc;

   function "*"(c : in Datatype; X : in Abc) return Abc;

   function "/"(X : in Abc; c : in Datatype) return Abc;

   function Magnitude(X : in Abc) return Datatype
      with
         Inline;

   procedure Normalize(X : in out Abc);

end Generic_ABC;
