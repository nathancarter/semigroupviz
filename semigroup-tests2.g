

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
# Define helper functions
#
############

HSV2RGB := function ( hue, sat, val ) # hue, saturation, value
    local tmp, diff, in6, build;
    # utility function for building RGB triples of bytes (range 0-255)
    build := function ( r, g, b ) # accepts r,g,b in [0,1]
        return [ Int( r * 255 ), Int( g * 255 ), Int( b * 255 ) ];
    end;
    # hue must be an integer in the range [0,360]
    hue := Int( hue ) mod 360;
    # sat and val must be in the range [0.0,1.0]
    sat := Minimum( Maximum( sat, 0.0 ), 1.0 );
    val := Minimum( Maximum( val, 0.0 ), 1.0 );
    # handle grayscale situation
    if ( sat = 0.0 ) then return build( val, val, val ); fi;
    # compute intermediate values
    tmp := ( ( 1.0 - sat ) * val );
    diff := val - tmp;
    # return a result based on which sixth of the color wheel we're in
    in6 := hue mod 60;
    if ( hue < 60 ) then
        return build( val, diff * in6 / 60 + tmp, tmp );
    fi;
    if ( hue < 120 ) then
        return build( diff * ( 60 - in6 ) / 60 + tmp, val, tmp );
    fi;
    if ( hue < 180 ) then
        return build( tmp, val, diff * in6 / 60 + tmp );
    fi;
    if ( hue < 240 ) then
        return build( tmp, diff * ( 60 - in6 ) / 60 + tmp, val );
    fi;
    if ( hue < 300 ) then
        return build( diff * in6 / 60 + tmp, tmp, val );
    fi;
    return build( val, tmp, diff * ( 60 - in6 ) / 60 + tmp );
end;

GeneratorsAreSufficient := function ( semigroup, generators )
    local generator, connections;
    connections := [ ];
    for generator in generators do
        connections := Concatenation( connections,
            List( Elements( semigroup ),
                  elt -> [ elt, elt * generator ] ) );
    od;
    return Size( EquivalenceClasses( EquivalenceRelationByPairs(
        semigroup, connections ) ) ) = 1;
end;
GeneratorsSmallSubset := function ( semigroup, generators )
    local i, withouti;
    for i in [ 1 .. Length( generators ) ] do
        withouti := generators{ Concatenation(
            [ 1 .. i-1 ], [ i+1 .. Length( generators ) ] ) };
        if GeneratorsAreSufficient( semigroup, withouti ) then
            # greedy algorithm, just to save time
            return GeneratorsSmallSubset( semigroup, withouti );
        fi;
    od;
    return generators;
end;


############
#
# Define main function
#
############

ShowCayleyGraph := function ( semigroup, options )
    local elements, generator, color, counter, json;
    if not IsBound( options.ToString ) then
        options.ToString := PrintString;
    fi;
    if not IsBound( options.generators ) then
        options.Generators := GeneratorsSmallSubset(
            semigroup, GeneratorsOfSemigroup( semigroup ) );
    fi;
    elements := List( Elements( semigroup ), elt ->
        rec(
            group := "nodes",
            data := rec( id := options.ToString( elt ) )
        )
    );
    counter := 0;
    for generator in options.Generators do
        color := HSV2RGB(
            counter * 360.0 / Size( options.Generators ),
            1.0, 0.7 );
        elements := Concatenation( elements,
            List( Elements( semigroup ), elt ->
                rec(
                    data := rec(
                        id := Concatenation( options.ToString( elt ),
                            "*", options.ToString( generator ) ),
                        source := options.ToString( elt ),
                        target := options.ToString( elt * generator ),
                        bgcolor := color
                    ),
                    style := rec(
                        ("line-color") := color,
                        ("mid-target-arrow-color") := color,
                        ("mid-target-arrow-shape") := "triangle",
                        ("arrow-scale") := 2
                    )
                )
            )
        );
        counter := counter + 1;
    od;
    json := rec(
        tool := "cytoscape",
        height := 800,
        data := rec(
            elements := elements,
            layout := rec( name := "cose" ),
            style := [
                rec(
                    selector := "node",
                    style := rec(
                        content := "data(id)",
                        ("font-size") := 6,
                        ("text-halign") := "center",
                        ("text-valign") := "center"
                    )
                )
            ]
        )
    );
    return CreateVisualization( json );
end;


############
#
# Make a picture
#
############

Pr := x -> ReplacedString( String( ListTransformation( x ) ), " ", "" );
ShowCayleyGraph( F4, rec( ToString := Pr ) );
