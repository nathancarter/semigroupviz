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

## Each test file should finish with the call of STOP_TEST.
## The first argument of STOP_TEST should be the name of the test file.
## The second argument is redundant and is used for backwards compatibility.
gap> STOP_TEST( "cayley-graph-json.tst", 10000 );

############################################################################
##
#E
