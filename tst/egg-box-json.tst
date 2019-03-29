############################################################################
##
#A  egg-box-json.tst      SemigroupViz Package           Nathan Carter
##
gap> START_TEST("SemigroupViz package: egg-box-json.tst");

# Ensure that the JSON form produced by EggBoxDiagramJSON is correct.

gap> LoadPackage( "semigroupviz", false );
true

# Verify the function exists
gap> IsBound( SGPVIZ_EggBoxDiagramRecord );
true

# Create a small semigroup (two elements)
gap> twoelts := Semigroup( [ Transformation( [ 1, 1, 1 ] ), Transformation( [ 1, 2, 2 ] ) ] );;

# Compute its default Egg-Box Diagram record and verify that it's correct.
gap> SGPVIZ_EggBoxDiagramRecord( twoelts, rec( ToString := x -> String( ListTransformation( x ) ), NrDClassesIncluded := 0, NrRClassesIncludedPerDClass := 0, NrLClassesIncludedPerRClass := 0, NrElementsIncludedPerHClass := 0 ) );
rec(
  DClasses := [ rec(
          RClasses := [ rec(
                  HClasses := [ rec(
                          elements := [ "[ 1, 1, 1 ]" ],
                          representative := "[ 1, 1, 1 ]",
                          size := 1 ) ],
                  size := 1 ) ],
          size := 1 ), rec(
          RClasses := [ rec(
                  HClasses := [ rec(
                          elements := [ "[ 1, 2, 2 ]" ],
                          representative := "[ 1, 2, 2 ]",
                          size := 1 ) ],
                  size := 1 ) ],
          size := 1 ) ],
  name := "transformation semigroup of degree 3 with 2 generators",
  options := rec(
      NrDClassesIncluded := 0,
      NrElementsIncludedPerHClass := 0,
      NrLClassesIncludedPerRClass := 0,
      NrRClassesIncludedPerDClass := 0 ),
  size := 2 )

# Compute a small subset of that diagram record and verify that it's correct.
gap> SGPVIZ_EggBoxDiagramRecord( twoelts, rec( ToString := x -> String( ListTransformation( x ) ), NrDClassesIncluded := 1, NrRClassesIncludedPerDClass := 1, NrLClassesIncludedPerRClass := 1, NrElementsIncludedPerHClass := 1 ) );
rec(
  DClasses := [ rec(
          RClasses := [ rec(
                  HClasses := [ rec(
                          elements := [ "[ 1, 1, 1 ]" ],
                          representative := "[ 1, 1, 1 ]",
                          size := 1 ) ],
                  size := 1 ) ],
          size := 1 ) ],
  name := "transformation semigroup of degree 3 with 2 generators",
  options := rec(
      NrDClassesIncluded := 1,
      NrElementsIncludedPerHClass := 1,
      NrLClassesIncludedPerRClass := 1,
      NrRClassesIncludedPerDClass := 1 ),
  size := 2 )

# Define a larger semigroup
gap> larger := SingularTransformationSemigroup( 4 );;

# Compute its full Egg Box Diagram and verify the sizes of things.
gap> tmp := SGPVIZ_EggBoxDiagramRecord( larger, rec( ToString := x -> String( ListTransformation( x ) ), NrDClassesIncluded := 0, NrRClassesIncludedPerDClass := 0, NrLClassesIncludedPerRClass := 0, NrElementsIncludedPerHClass := 0, name := "testing name" ) );;
gap> tmp.options.NrDClassesIncluded; # option was set to 0
0
gap> tmp.size; # thus we included all three D-classes
3
gap> Length( tmp.DClasses );
3
gap> tmp.options.NrRClassesIncludedPerDClass; # option set to 0
0
gap> tmp.DClasses[1].size; # so each D-class has all its R-classes
6
gap> Length( tmp.DClasses[1].RClasses );
6
gap> tmp.DClasses[2].size;
7
gap> Length( tmp.DClasses[2].RClasses );
7
gap> tmp.DClasses[3].size;
1
gap> Length( tmp.DClasses[3].RClasses );
1
gap> tmp.options.NrLClassesIncludedPerRClass; # option set to 0
0
gap> tmp.DClasses[1].RClasses[1].size; # so each R-class has all its L-classes
4
gap> Length( tmp.DClasses[1].RClasses[1].HClasses );
4
gap> tmp.DClasses[2].RClasses[1].size;
6
gap> Length( tmp.DClasses[2].RClasses[1].HClasses );
6
gap> tmp.DClasses[3].RClasses[1].size;
4
gap> Length( tmp.DClasses[3].RClasses[1].HClasses );
4
gap> tmp.options.NrElementsIncludedPerHClass; # option set to 0
0
gap> tmp.DClasses[1].RClasses[1].HClasses[1].size; # so each H-class has all its elements
6
gap> Length( tmp.DClasses[1].RClasses[1].HClasses[1].elements );
6
gap> tmp.DClasses[2].RClasses[1].HClasses[1].size;
2
gap> Length( tmp.DClasses[2].RClasses[1].HClasses[1].elements );
2
gap> tmp.DClasses[3].RClasses[1].HClasses[1].size;
1
gap> Length( tmp.DClasses[3].RClasses[1].HClasses[1].elements );
1
gap> tmp.name; # did it copy the name we specified?
"testing name"
gap> IsBound( tmp.options.name ); # but not into the options record
false

# Compute a portion of the same Egg Box Diagram and verify the sizes of things.
gap> tmp := SGPVIZ_EggBoxDiagramRecord( larger, rec( ToString := x -> String( ListTransformation( x ) ), NrDClassesIncluded := 2, NrRClassesIncludedPerDClass := 2, NrLClassesIncludedPerRClass := 2, NrElementsIncludedPerHClass := 2 ) );;
gap> tmp.options.NrDClassesIncluded; # option was set to 2
2
gap> tmp.size; # thus we included only 2 D-classes out of 3
3
gap> Length( tmp.DClasses );
2
gap> tmp.options.NrRClassesIncludedPerDClass; # option set to 2
2
gap> tmp.DClasses[1].size; # this D-class has 2 of its 6 R-classes
6
gap> Length( tmp.DClasses[1].RClasses );
2
gap> tmp.DClasses[2].size;
7
gap> Length( tmp.DClasses[2].RClasses );
2
gap> tmp.options.NrLClassesIncludedPerRClass; # option set to 2
2
gap> tmp.DClasses[1].RClasses[1].size; # this R-class has 2 of its 4 L-classes
4
gap> Length( tmp.DClasses[1].RClasses[1].HClasses );
2
gap> tmp.DClasses[2].RClasses[1].size; # this one has 2 of 6
6
gap> Length( tmp.DClasses[2].RClasses[1].HClasses );
2
gap> tmp.options.NrElementsIncludedPerHClass; # option set to 2
2
gap> tmp.DClasses[1].RClasses[1].HClasses[1].size; # this H-class has 2 of its 6 elements
6
gap> Length( tmp.DClasses[1].RClasses[1].HClasses[1].elements );
2
gap> tmp.DClasses[2].RClasses[1].HClasses[1].size;
2
gap> Length( tmp.DClasses[2].RClasses[1].HClasses[1].elements );
2

# Let's try getting the same data a different way.
# This time we provide a minimal options record, and defaults are filled in.
gap> tmp := ShowEggBoxDiagram( larger, rec( ReturnJSON := true ) );;
gap> tmp.tool;
"egg-box"
gap> IsRecord( tmp.data );
true
gap> tmpdata := tmp.data;;
gap> tmpdata.options.NrDClassesIncluded;
3
gap> tmpdata.options.NrRClassesIncludedPerDClass;
7
gap> tmpdata.options.NrLClassesIncludedPerRClass;
6
gap> tmpdata.options.NrElementsIncludedPerHClass;
6
gap> tmpdata.options.ReturnJSON;
true

# This time we provide a bounds too large, and they get shrunk.
gap> tmp := ShowEggBoxDiagram( larger, rec( ReturnJSON := true, NrDClassesIncluded := 1000, NrRClassesIncludedPerDClass := 1000, NrLClassesIncludedPerRClass := 1000, NrElementsIncludedPerHClass := 1000 ) );;
gap> tmpdata := tmp.data;;
gap> tmpdata.options.NrDClassesIncluded;
3
gap> tmpdata.options.NrRClassesIncludedPerDClass;
7
gap> tmpdata.options.NrLClassesIncludedPerRClass;
6
gap> tmpdata.options.NrElementsIncludedPerHClass;
6
gap> tmpdata.options.ReturnJSON;
true

# Now we test the inner SGPVIZ_HClassToRecord function
gap> G := Group( [ (1,2,3) ] );;
gap> opts := rec(ToString:=PrintString);;
gap> D := DClasses(G)[1];;
gap> H := Intersection(RClasses(D)[1],LClasses(D)[1]);;
gap> Size(H);
3
gap> Elements(H);
[ (), (1,2,3), (1,3,2) ]
gap> opts.NrElementsIncludedPerHClass := 10;;
gap> SGPVIZ_HClassToRecord(G,H,opts);
rec( elements := [ "()", "(1,2,3)", "(1,3,2)" ],
  representative := "()", size := 3 )
gap> opts.NrElementsIncludedPerHClass := 1;;
gap> SGPVIZ_HClassToRecord(G,H,opts);
rec( elements := [ "()" ],
  representative := "()", size := 3 )
gap> opts.NrElementsIncludedPerHClass := 2;;
gap> SGPVIZ_HClassToRecord(G,H,opts);
rec( elements := [ "()", "(1,2,3)" ],
  representative := "()", size := 3 )
gap> opts.NrElementsIncludedPerHClass := 3;;
gap> SGPVIZ_HClassToRecord(G,H,opts);
rec( elements := [ "()", "(1,2,3)", "(1,3,2)" ],
  representative := "()", size := 3 )
gap> opts.ToString := x -> ReplacedString(PrintString(x),",",".");;
gap> SGPVIZ_HClassToRecord(G,H,opts);
rec( elements := [ "()", "(1.2.3)", "(1.3.2)" ],
  representative := "()", size := 3 )

## Each test file should finish with the call of STOP_TEST.
## The first argument of STOP_TEST should be the name of the test file.
## The second argument is redundant and is used for backwards compatibility.
gap> STOP_TEST( "egg-box-json.tst", 10000 );

############################################################################
##
#E
