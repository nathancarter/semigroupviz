

############
#
# Load tools
#
############

Read( "semigroup-setup.g" );


############
#
# Do some testing of the above routines
#
############

S := Monoid( [ Transformation( [ 2, 4, 3, 4 ] ),
               Transformation( [ 3, 3, 2, 3, 3 ] ) ] );;
Size( S );;
T := Semigroup( [ Transformation( [ 3, 5, 4, 2, 6, 3 ] ) ] );;
Size( T );;
DP := DirectProduct( S, T );;
Size( DP );;

# ShowSemigroup( DP );
# ShowSemigroup( CatalanMonoid( 4 ) );
ShowSemigroup(
    SingularTransformationSemigroup( 4 ),
    rec(
        ToString := x -> String( ListTransformation( x ) )#,
        #NrDClassesIncluded := -20,
        #NrRClassesIncludedPerDClass := -20,
        #NrLClassesIncludedPerRClass := -20,
        #NrElementsIncludedPerHClass := -20
    )
);
