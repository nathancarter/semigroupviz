

############
#
# Load tools
#
############

LoadPackage( "semigroupviz" );


############
#
# Create example semigroups to visualize
#
############

MD := Monoid( [ Transformation( [ 2, 4, 3, 4 ] ),
                Transformation( [ 3, 3, 2, 3, 3 ] ) ] ); # size 7
Z3 := Semigroup( [ Transformation( [ 2, 3, 1 ] ) ] ); # size 3
Z5 := Semigroup( [ Transformation( [ 3, 5, 4, 2, 6, 3 ] ) ] ); # size 5
P1 := DirectProduct( MD, Z3 ); # size 35
P2 := DirectProduct( MD, Z5 ); # size 21
P3 := DirectProduct( Z3, Z5 ); # size 15
S2 := SingularTransformationSemigroup( 2 ); # size 2
S3 := SingularTransformationSemigroup( 3 ); # size 21
S4 := SingularTransformationSemigroup( 4 ); # size 232
S5 := SingularTransformationSemigroup( 5 ); # size 3005
F2 := FullTransformationSemigroup( 2 ); # size 4
F3 := FullTransformationSemigroup( 3 ); # size 27
F4 := FullTransformationSemigroup( 4 ); # size 256
F5 := FullTransformationSemigroup( 5 ); # size 3125


############
#
# Make a picture
#
############

Pr := x -> ReplacedString( String( ListTransformation( x ) ), " ", "" );
ShowCayleyGraph(
    Group( [ (1,2), (1,2,3) ] ),
    rec(
        # ToString := Pr,
        ShowActionNames := true#,
        #Multiplication := "left",
        #ReturnJSON := true
    )
);
