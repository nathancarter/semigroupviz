

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
        #NrDClassesIncluded := 2,
        #NrRClassesIncludedPerDClass := 2,
        #NrLClassesIncludedPerRClass := 2,
        #NrElementsIncludedPerHClass := 2
    )
);
# Sm := Semigroup( [
#     Transformation( [ 1, 1, 1 ] ),
#     Transformation( [ 1, 2, 2 ] )
# ] );
# Print( EggBoxDiagramRecord( Sm, rec(
#     ToString := x -> String( ListTransformation( x ) ),
#     NrDClassesIncluded := 0,
#     NrRClassesIncludedPerDClass := 0,
#     NrLClassesIncludedPerRClass := 0,
#     NrElementsIncludedPerHClass := 0
# ) ), "\n" );
