############################################################################
##
#A  cayley-graph-json.tst      SemigroupViz Package       Nathan Carter
##
gap> START_TEST("SemigroupViz package: cayley-graph-json.tst");

# Ensure that the JSON form produced by ShowCayleyGraph is correct.

gap> LoadPackage( "semigroupviz", false );
#I  method installed for Matrix matches more than one declaration
true

# Verify that the helper function for converting colors does its job
# At full saturation and brightness,
# the color wheel moves through these six colors:
gap> SGPVIZ_HSV2RGB(  0,1,1); # hue=  0 => red
[ 255, 0, 0 ]
gap> SGPVIZ_HSV2RGB( 60,1,1); # hue= 60 => yellow
[ 255, 255, 0 ]
gap> SGPVIZ_HSV2RGB(120,1,1); # hue=120 => green
[ 0, 255, 0 ]
gap> SGPVIZ_HSV2RGB(180,1,1); # hue=180 => cyan
[ 0, 255, 255 ]
gap> SGPVIZ_HSV2RGB(240,1,1); # hue=240 => blue
[ 0, 0, 255 ]
gap> SGPVIZ_HSV2RGB(300,1,1); # hue=300 => magenta
[ 255, 0, 255 ]
gap> SGPVIZ_HSV2RGB(360,1,1); # hue=360 => back to red b/c 360 is 0
[ 255, 0, 0 ]

# At full saturation and half brightness,
# we get the exact same results but with half intensity
gap> SGPVIZ_HSV2RGB(  0,1,0.5);
[ 127, 0, 0 ]
gap> SGPVIZ_HSV2RGB( 60,1,0.5);
[ 127, 127, 0 ]
gap> SGPVIZ_HSV2RGB(120,1,0.5);
[ 0, 127, 0 ]
gap> SGPVIZ_HSV2RGB(180,1,0.5);
[ 0, 127, 127 ]
gap> SGPVIZ_HSV2RGB(240,1,0.5);
[ 0, 0, 127 ]
gap> SGPVIZ_HSV2RGB(300,1,0.5);
[ 127, 0, 127 ]
gap> SGPVIZ_HSV2RGB(360,1,0.5);
[ 127, 0, 0 ]

# At half saturation and half brightness,
# we get the same results but with half white mixed in.
gap> SGPVIZ_HSV2RGB(  0,0.5,0.5);
[ 127, 63, 63 ]
gap> SGPVIZ_HSV2RGB( 60,0.5,0.5);
[ 127, 127, 63 ]
gap> SGPVIZ_HSV2RGB(120,0.5,0.5);
[ 63, 127, 63 ]
gap> SGPVIZ_HSV2RGB(180,0.5,0.5);
[ 63, 127, 127 ]
gap> SGPVIZ_HSV2RGB(240,0.5,0.5);
[ 63, 63, 127 ]
gap> SGPVIZ_HSV2RGB(300,0.5,0.5);
[ 127, 63, 127 ]
gap> SGPVIZ_HSV2RGB(360,0.5,0.5);
[ 127, 63, 63 ]

# If brightness is zero, no matter the other parameters, we get black.
gap> SGPVIZ_HSV2RGB(263,0.3820,0);
[ 0, 0, 0 ]
gap> SGPVIZ_HSV2RGB(19,1,0);
[ 0, 0, 0 ]
gap> SGPVIZ_HSV2RGB(345,0.2,0);
[ 0, 0, 0 ]

# If saturation is zero, no matter the hue, we get gray,
# scaled by the brightness parameter.
# I will use 1/2^n as brightnesses, so we can easily expect
# various 2^k-1 as outputs (since 255=2^8-1).
gap> SGPVIZ_HSV2RGB(0,0,0.5);
[ 127, 127, 127 ]
gap> SGPVIZ_HSV2RGB(100,0,0.5);
[ 127, 127, 127 ]
gap> SGPVIZ_HSV2RGB(274,0,0.5);
[ 127, 127, 127 ]
gap> SGPVIZ_HSV2RGB(75,0,0.25);
[ 63, 63, 63 ]
gap> SGPVIZ_HSV2RGB(352,0,0.125);
[ 31, 31, 31 ]

# Now we begin tests for SGPVIZ_GeneratorsAreSufficient.
# I create a small semigroup with 7 elements.
gap> g1 := Transformation( [ 4, 2, 3, 4 ] );;
gap> g2 := Transformation( [ 3, 2, 1 ] );;
gap> mul := function ( a, b ) return a * b; end;;
gap> g3 := mul( g1, g2 );
Transformation( [ 4, 2, 1, 4 ] )
gap> g4 := mul( g2, g1 );
Transformation( [ 3, 2, 4, 4 ] )
gap> S := SemigroupByGenerators( [ g1, g2 ] );;
gap> Size( S );
7
gap> opts := rec( Multiplication := mul );;
gap> SGPVIZ_GeneratorsAreSufficient( S, [ ], opts );
false
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g1 ], opts );
false
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g2 ], opts );
false
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g3 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g4 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g1, g2 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g1, g3 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g1, g4 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g2, g3 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g2, g4 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g3, g4 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g1, g2, g3 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g1, g2, g4 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g1, g3, g4 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g2, g3, g4 ], opts );
true
gap> SGPVIZ_GeneratorsAreSufficient( S, [ g1, g2, g3, g4 ], opts );
true

# Does the SGP_GeneratorsSmallSubset function process all the above
# cases correctly, that is, by removing the first generator on the
# list that isn't needed, iteratively?
gap> SGPVIZ_GeneratorsSmallSubset( S, [ ], opts );
[ ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g1 ], opts );
[ Transformation( [ 4, 2, 3, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g2 ], opts );
[ Transformation( [ 3, 2, 1 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g3 ], opts );
[ Transformation( [ 4, 2, 1, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g4 ], opts );
[ Transformation( [ 3, 2, 4, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g1, g2 ], opts );
[ Transformation( [ 4, 2, 3, 4 ] ), Transformation( [ 3, 2, 1 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g1, g3 ], opts );
[ Transformation( [ 4, 2, 1, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g3, g1 ], opts );
[ Transformation( [ 4, 2, 1, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g1, g4 ], opts );
[ Transformation( [ 3, 2, 4, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g4, g1 ], opts );
[ Transformation( [ 3, 2, 4, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g2, g3 ], opts );
[ Transformation( [ 4, 2, 1, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g3, g2 ], opts );
[ Transformation( [ 4, 2, 1, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g2, g4 ], opts );
[ Transformation( [ 3, 2, 4, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g4, g2 ], opts );
[ Transformation( [ 3, 2, 4, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g3, g4 ], opts );
[ Transformation( [ 3, 2, 4, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g4, g3 ], opts );
[ Transformation( [ 4, 2, 1, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g1, g2, g3 ], opts );
[ Transformation( [ 4, 2, 1, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g3, g1, g2 ], opts );
[ Transformation( [ 4, 2, 3, 4 ] ), Transformation( [ 3, 2, 1 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g1, g2, g4 ], opts );
[ Transformation( [ 3, 2, 4, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g4, g1, g2 ], opts );
[ Transformation( [ 4, 2, 3, 4 ] ), Transformation( [ 3, 2, 1 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g1, g3, g4 ], opts );
[ Transformation( [ 3, 2, 4, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g2, g3, g4 ], opts );
[ Transformation( [ 3, 2, 4, 4 ] ) ]
gap> SGPVIZ_GeneratorsSmallSubset( S, [ g1, g2, g3, g4 ], opts );
[ Transformation( [ 3, 2, 4, 4 ] ) ]

# Check the ShowCayleyGraph function by asking for its JSON.
# Ensure several properties of that resulting JSON.
gap> tmp := ShowCayleyGraph( S, rec( ReturnJSON := true ) );;
gap> tmp.tool;
"cytoscape"
gap> tmpdata := tmp.data;;
gap> IsBound( tmpdata.elements );
true
gap> IsBound( tmpdata.layout );
true
gap> IsBound( tmpdata.style );
true

# Ensure the first node is the first element of the semigroup,
# represented using the default PrintString function.
gap> firstVertex := tmpdata.elements[1];;
gap> firstVertex.group;
"nodes"
gap> firstVertex.data.id;
"\>IdentityTransformation\<"

# Ensure the first edge is the first element times the first generator,
# represented using the default PrintString function.
gap> firstEdge := tmpdata.elements[Size(S)+1];;
gap> IsBound( firstEdge.group );
false
gap> firstEdge.data.id;
"\>IdentityTransformation\<*\>Transformation( [ \>4\<,\> 2\<,\> 3\<,\> 4\< ] )\<"

# Ask for the same data structure, but providing my own ToString method.
gap> AsIndex := elt -> String(Position(Elements(S),elt));;
gap> tmp := ShowCayleyGraph( S, rec( ReturnJSON := true, ToString := AsIndex ) );;
gap> tmpdata := tmp.data;;

# Verify that it was used when creating node names.
gap> firstVertex := tmpdata.elements[1];;
gap> firstVertex.group;
"nodes"
gap> firstVertex.data.id;
"1"

# Verify that it was used when creating edge names.
gap> firstEdge := tmpdata.elements[Size(S)+1];;
gap> IsBound( firstEdge.group );
false
gap> firstEdge.data.id; # turns out elements 6,7 are used as generators
"1*6"

# Ask for the same data structure, but with left multiplication.
gap> AsIndex := elt -> String(Position(Elements(S),elt));;
gap> tmp := ShowCayleyGraph( S, rec( ReturnJSON := true, ToString := AsIndex, Multiplication := "left" ) );;
gap> tmpdata2 := tmp.data;;

# Ensure the result is not the same.
gap> tmpdata2.elements[20] = tmpdata.elements[20];
false

# Ask for the same data structure, but using my own generators.
gap> AsIndex := elt -> String(Position(Elements(S),elt));;
gap> tmp := ShowCayleyGraph( S, rec( ReturnJSON := true, Generators := [ g1, g2 ] ) );;
gap> tmpdata2 := tmp.data;;

# Ensure that the collection of edges respects my choice.
gap> firstEdge := tmpdata2.elements[Size(S)+1];;
gap> firstEdge.data.label;
"\>Transformation( [ \>4\<,\> 2\<,\> 3\<,\> 4\< ] )\<"
gap> firstEdgeOfGen2 := tmpdata2.elements[2*Size(S)+1];;
gap> firstEdgeOfGen2.data.label;
"\>Transformation( [ \>3\<,\> 2\<,\> 1\< ] )\<"

# Check to be sure the node styles were included by default.
gap> tmpdata.style[1].selector;
"node"

# Check to be sure the edge styles were excluded by default.
gap> Length( tmpdata.style );
1

# Now ask for the edge styles but not the node styles.
gap> tmp := ShowCayleyGraph( S, rec( ReturnJSON := true, ShowElementNames := false, ShowActionNames := true ) );;
gap> tmpdata := tmp.data;;

# Ensure the edge styles were included this time.
gap> tmpdata.style[1].selector;
"edge"

# Ensure the node styles were excluded this time.
gap> Length( tmpdata.style );
1


## Each test file should finish with the call of STOP_TEST.
## The first argument of STOP_TEST should be the name of the test file.
## The second argument is redundant and is used for backwards compatibility.
gap> STOP_TEST( "cayley-graph-json.tst", 10000 );

############################################################################
##
#E
