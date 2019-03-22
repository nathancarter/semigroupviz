

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


InstallGlobalFunction( ShowSemigroup,
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
