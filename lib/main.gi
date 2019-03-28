

############
#
# LDefine new visualization tool
#
############

InstallVisualizationTool( "egg-box", ReadAll( InputTextFile(
    "/Users/nathan/.gap/pkg/semigroupviz/viz-tool-egg-box.js"
) ) );


InstallGlobalFunction( SGPVIZ_HClassToRecord,
function ( semigroup, hclass, options )
    local result, repr;
    repr := Representative( hclass );
    result := rec(
        size := Size( hclass ),
        representative := options.ToString( repr )
    );
    if options.NrElementsIncludedPerHClass = 1 then
        hclass := [ repr ];
    elif options.NrElementsIncludedPerHClass > 1
            and options.NrElementsIncludedPerHClass
             <= Length( hclass ) then
        hclass := hclass{[ 1 .. options.NrElementsIncludedPerHClass ]};
        if repr in hclass then
            Remove( hclass, Position( hclass, repr ) );
            Add( hclass, repr, 1 );
        else
            Add( hclass, repr, 1 );
            Remove( hclass );
        fi;
    fi;
    result.elements := List( hclass, options.ToString );
    return result;
end );


InstallGlobalFunction( SGPVIZ_DClassToRecord,
function ( semigroup, dclass, options )
    local result, next,
          lclass, lclasses, origl, rclass, rclasses, origr;
    result := rec(
        size := NrRClasses( dclass )
    );
    lclasses := LClasses( dclass );
    rclasses := RClasses( dclass );
    if options.NrLClassesIncludedPerRClass > 0
            and options.NrLClassesIncludedPerRClass
              < Size( lclasses ) then
        lclasses := lclasses{[ 1 ..
            options.NrLClassesIncludedPerRClass ]};
    fi;
    if options.NrRClassesIncludedPerDClass > 0
            and options.NrRClassesIncludedPerDClass
              < Size( rclasses ) then
        rclasses := rclasses{[ 1 ..
            options.NrRClassesIncludedPerDClass ]};
    fi;
    result.RClasses := List( rclasses, rclass -> rec(
        size := NrLClasses( dclass ),
        HClasses := List( lclasses, lclass ->
            SGPVIZ_HClassToRecord( semigroup,
                Intersection( lclass, rclass ), options ) )
    ) );
    return result;
end );


InstallGlobalFunction( SGPVIZ_EggBoxDiagramRecord,
function ( semigroup, options )
    local dclass, dclasses, result, smallerOptions, name;
    smallerOptions := rec( );
    for name in RecNames( options ) do
        if name <> "ToString" and name <> "name" then
            smallerOptions.(name) := options.(name);
        fi;
    od;
    result := rec(
        options := smallerOptions,
        size := NrDClasses( semigroup ),
        DClasses := [ ]
    );
    if not IsBound( result.name ) then
        name := StripLineBreakCharacters(
            ViewString( semigroup ) );
        name := name{[ 2 .. Length(name)-1 ]};
        result.name := name;
    fi;
    dclasses := IteratorOfDClasses( semigroup );
    for dclass in dclasses do
        Add( result.DClasses,
             SGPVIZ_DClassToRecord( semigroup, dclass, options ) );
        if options.NrDClassesIncluded > 0
                and options.NrDClassesIncluded
                 <= Length( result.DClasses ) then
            break;
        fi;
    od;
    return result;
end );


InstallGlobalFunction( ShowEggBoxDiagram,
function ( semigroup, options... )
    local dclass, rmax, lmax, emax;
    # Ensure options object exists
    if Length( options ) = 0 then
        options := rec();
    else
        options := options[1];
    fi;
    # Fill in defaults for unspecified options
    if not IsBound( options.ToString ) then
        options.ToString := PrintString;
    fi;
    if not IsBound( options.NrDClassesIncluded ) then
        options.NrDClassesIncluded := 20;
    fi;
    if not IsBound( options.NrRClassesIncludedPerDClass ) then
        options.NrRClassesIncludedPerDClass := 20;
    fi;
    if not IsBound( options.NrLClassesIncludedPerRClass ) then
        options.NrLClassesIncludedPerRClass := 20;
    fi;
    if not IsBound( options.NrElementsIncludedPerHClass ) then
        options.NrElementsIncludedPerHClass := 20;
    fi;
    # Ensure that the options have sensible values
    if options.NrDClassesIncluded < 0 then
        options.NrDClassesIncluded := 0;
    fi;
    if options.NrDClassesIncluded > NrDClasses( semigroup ) then
        options.NrDClassesIncluded := NrDClasses( semigroup );
    fi;
    rmax := 0;
    lmax := 0;
    emax := 0;
    for dclass in IteratorOfDClasses( semigroup ) do
        rmax := Maximum( rmax, NrRClasses( dclass ) );
        lmax := Maximum( lmax, NrLClasses( dclass ) );
        emax := Maximum( emax, Size( Intersection(
            LClasses( dclass )[1], RClasses( dclass )[1] ) ) );
    od;
    if options.NrRClassesIncludedPerDClass < 0 then
        options.NrRClassesIncludedPerDClass := 0;
    fi;
    if options.NrRClassesIncludedPerDClass > rmax then
        options.NrRClassesIncludedPerDClass := rmax;
    fi;
    if options.NrLClassesIncludedPerRClass < 0 then
        options.NrLClassesIncludedPerRClass := 0;
    fi;
    if options.NrLClassesIncludedPerRClass > lmax then
        options.NrLClassesIncludedPerRClass := lmax;
    fi;
    if options.NrElementsIncludedPerHClass < 0 then
        options.NrElementsIncludedPerHClass := 0;
    fi;
    if options.NrElementsIncludedPerHClass > emax then
        options.NrElementsIncludedPerHClass := emax;
    fi;
    # Create JSON and pass to visualization library
    return CreateVisualization( rec(
        tool := "egg-box",
        data := GapToJsonString( SGPVIZ_EggBoxDiagramRecord(
            semigroup, options ) )
    ) );
end );


InstallGlobalFunction( SGPVIZ_HSV2RGB,
function ( hue, sat, val ) # hue, saturation, value
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
end );


InstallGlobalFunction( SGPVIZ_GeneratorsAreSufficient,
function ( semigroup, generators, options )
    local generator, connections;
    connections := [ ];
    for generator in generators do
        connections := Concatenation( connections,
            List( Elements( semigroup ), elt -> [ elt,
                options.Multiplication( elt, generator ) ] ) );
    od;
    return Size( EquivalenceClasses( EquivalenceRelationByPairs(
        semigroup, connections ) ) ) = 1;
end );


InstallGlobalFunction( SGPVIZ_GeneratorsSmallSubset,
function ( semigroup, generators, options )
    local i, withouti;
    for i in [ 1 .. Length( generators ) ] do
        withouti := generators{ Concatenation(
            [ 1 .. i-1 ], [ i+1 .. Length( generators ) ] ) };
        if SGPVIZ_GeneratorsAreSufficient(
                semigroup, withouti, options ) then
            # greedy algorithm, just to save time
            return SGPVIZ_GeneratorsSmallSubset(
                semigroup, withouti, options );
        fi;
    od;
    return generators;
end );


InstallGlobalFunction( ShowCayleyGraph,
function ( semigroup, options... )
    local elements, generator, color, counter, json;
    # Ensure options object exists
    if Length( options ) = 0 then
        options := rec();
    else
        options := options[1];
    fi;
    # Fill in defaults for unspecified options
    # and convert mult option to corresponding functions
    if not IsBound( options.ToString ) then
        options.ToString := PrintString;
    fi;
    if not IsBound( options.Multiplication ) then
        options.Multiplication := "right";
    fi;
    if options.Multiplication = "right" then
        options.Multiplication :=
            function ( a, b ) return a * b; end;
        options.MultString := function ( a, b )
            return Concatenation( options.ToString( a ), "*",
                options.ToString( b ) );
        end;
    else
        options.Multiplication :=
            function ( a, b ) return b * a; end;
        options.MultString := function ( a, b )
            return Concatenation( options.ToString( b ), "*",
                options.ToString( a ) );
        end;
    fi;
    if not IsBound( options.Generators ) then
        options.Generators := SGPVIZ_GeneratorsSmallSubset(
            semigroup, GeneratorsOfSemigroup( semigroup ),
            options );
    fi;
    if not IsBound( options.ShowElementNames ) then
        options.ShowElementNames := true;
    fi;
    if not IsBound( options.ShowActionNames ) then
        options.ShowActionNames := false;
    fi;
    # Create JSON for graph vertices
    elements := List( Elements( semigroup ), elt ->
        rec(
            group := "nodes",
            data := rec( id := options.ToString( elt ) )
        )
    );
    # Create JSON for graph edges
    counter := 0;
    for generator in options.Generators do
        color := SGPVIZ_HSV2RGB(
            counter * 360.0 / Size( options.Generators ),
            1.0, 0.7 );
        elements := Concatenation( elements,
            List( Elements( semigroup ), elt ->
                rec(
                    data := rec(
                        id := options.MultString( elt, generator ),
                        label := options.ToString( generator ),
                        source := options.ToString( elt ),
                        target := options.ToString(
                            options.Multiplication( elt, generator ) ),
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
    # Format JSON and pass to visualization library
    json := rec(
        tool := "cytoscape",
        height := 800,
        data := rec(
            elements := elements,
            layout := rec( name := "cose" ),
            style := [ ]
        )
    );
    if options.ShowElementNames then
        Add( json.data.style, rec(
            selector := "node",
            style := rec(
                content := "data(id)",
                ("font-size") := 6,
                ("text-halign") := "center",
                ("text-valign") := "center"
            )
        ) );
    fi;
    if options.ShowActionNames then
        Add( json.data.style, rec(
            selector := "edge",
            style := rec(
                content := "data(label)",
                ("font-size") := 6
            )
        ) );
    fi;
    return CreateVisualization( json );
end );
