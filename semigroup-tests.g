

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
    if options.HLimit = 1 then
        hclass := [ repr ];
    elif options.HLimit > 1
            and options.HLimit <= Length( hclass ) then
        hclass := hclass{[ 1 .. options.HLimit ]};
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
    if options.LLimit > 0 and options.LLimit < origl then
        lclasses := lclasses{[ 1 .. options.LLimit ]};
    fi;
    if options.RLimit > 0 and options.RLimit < origr then
        rclasses := rclasses{[ 1 .. options.RLimit ]};
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
        if options.DLimit > 0
                and options.DLimit <= Length( result.DClasses ) then
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
# DLimit: maximum number of D-classes to show in the diagram
#   (defaults to 20, set to 0 for no limit)
# RLimit: maximum number of R-classes to show in any one D-class
#   (defaults to 20, set to 0 for no limit)
# LLimit: maximum number of L-classes to show in any one D-class
#   (defaults to 20, set to 0 for no limit)
# HLimit: maximum number of H elements to show in any one H-class
#   (defaults to 20, set to 0 for no limit)
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
    if not IsBound( options.DLimit ) then
        options.DLimit := 20;
    fi;
    if not IsBound( options.LLimit ) then
        options.LLimit := 20;
    fi;
    if not IsBound( options.RLimit ) then
        options.RLimit := 20;
    fi;
    if not IsBound( options.HLimit ) then
        options.HLimit := 20;
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
    rec( ToString := x -> String( ListTransformation( x ) ),
         HLimit := 0, LLimit := 0, RLimit := 0, DLimit := 2 )
);
