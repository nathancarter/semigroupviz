

############
#
# Load visualization library and define new visualization tool
#
############

LoadPackage( "jupyterviz" );

InstallVisualizationTool( "egg-box", ReadAll( InputTextFile(
    "/Users/nathan/.gap/pkg/semigroupviz/viz-tool-egg-box.js"
) ) );


############
#
# Create GAP functions for using that new visualiation tool
#
############

LoadPackage( "semigroups" );

HClassToRecord := function ( semigroup, hclass, options )
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
end;

DClassToRecord := function ( semigroup, dclass, options )
    local result, next,
          lclass, lclasses, origl, rclass, rclasses, origr;
    result := rec(
        size := NrRClasses( dclass )
    );
    lclasses := LClasses( dclass );
    rclasses := RClasses( dclass );
    origl := Size( lclasses );
    origr := Size( rclasses );
    if options.NrLClassesIncludedPerRClass > 0
            and options.NrLClassesIncludedPerRClass < origl then
        lclasses := lclasses{[ 1 ..
            options.NrLClassesIncludedPerRClass ]};
    fi;
    if options.NrRClassesIncludedPerDClass > 0
            and options.NrRClassesIncludedPerDClass < origr then
        rclasses := rclasses{[ 1 ..
            options.NrRClassesIncludedPerDClass ]};
    fi;
    result.RClasses := List( rclasses, rclass -> rec(
        size := NrLClasses( dclass ),
        HClasses := List( lclasses, lclass ->
            HClassToRecord( semigroup,
                Intersection( lclass, rclass ), options ) )
    ) );
    return result;
end;

EggBoxDiagramJSON := function ( semigroup, options )
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
        name := ViewString( semigroup );
        name := ReplacedString( name, "\<", "" );
        name := ReplacedString( name, "\>", "" );
        name := name{[ 2 .. Length(name)-1 ]};
        result.name := name;
    fi;
    dclasses := IteratorOfDClasses( semigroup );
    for dclass in dclasses do
        Add( result.DClasses,
             DClassToRecord( semigroup, dclass, options ) );
        if options.NrDClassesIncluded > 0
                and options.NrDClassesIncluded
                 <= Length( result.DClasses ) then
            break;
        fi;
    od;
    Print( result );
    return GapToJsonString( result );
end;

# Documented options:
# ToString: a function mapping elements of the semigroup to strings.
#   This defaults to PrintString, but if you have something better,
#   go ahead and provide it.
# NrDClassesIncluded: maximum number of D-classes to compute and
#   include in the JSON object to be visualized.
#   This is useful if the semigroup is extremely large, and you want
#   to send a manageable amount of JSON data to the visualization,
#   to see a subset of the semigroup.
#   (defaults to 20, set to 0 for no limit)
# NrRClassesIncludedPerDClass: maximum number of R-classes to
#   compute for any one D-class and include in the JSON.
#   (defaults to 20, set to 0 for no limit)
#   See above for explanation of why you might want to do this.
# NrLClassesIncludedPerRClass: maximum number of L-classes to
#   compute for any one D/R-class and include in the JSON.
#   (defaults to 20, set to 0 for no limit)
#   See above for explanation of why you might want to do this.
# NrElementsIncludedPerHClass: maximum number of elements to
#   compute for any one H-class and include in the JSON.
#   (defaults to 20, set to 0 for no limit)
#   See above for explanation of why you might want to do this.
ShowSemigroup := function ( semigroup, options... )
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
    # Create JSON and pass to visualization library
    return CreateVisualization( rec(
        tool := "egg-box",
        data := EggBoxDiagramJSON( semigroup, options )
    ) );
end;


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
        ToString := x -> String( ListTransformation( x ) ),
        NrDClassesIncluded := 2,
        NrRClassesIncludedPerDClass := 0,
        NrLClassesIncludedPerRClass := 0,
        NrElementsIncludedPerHClass := 0
    )
);
