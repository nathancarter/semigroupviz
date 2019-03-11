

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


# This function converts the given H-class from the given semigroup
# into a GAP record, obeying the options passed in the third argument.
#
# All records formed by this package are of a form amenable to
# conversion to JSON via GAP's JSON package.
#
# The first parameter must be a semigroup, as created by GAP's
# Semigroups Package.
# The second argument must be a single H-class from that semigroup,
# which you can form in a number of ways, such as by choosing a
# D-class, lifting out its first R- and L-classes, and interesecting
# them.
# The final argument should be a GAP record whose contents will
# govern how this function does its work, as indicated below.
#
# Attributes in the resulting record include:
#  - size := the number of elements in the H-class
#  - representative := a string representation of the H-class's
#        representative.  The string representation will be computed
#        by passing the H-class's representative element to the
#        options.ToString function.
#  - elements := an array of string representations of all the
#        elements in the class, by default, or some subset of them
#        if options.NrElementsIncludedPerHClass > 0 and smaller than
#        the number of elements in this particular class.  The
#        representative is always first on this list.  These string
#        representations are also computed by options.ToString.
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


# This function converts the given D-class from the given semigroup
# into a GAP record, obeying the options passed in the third argument.
#
# All records formed by this package are of a form amenable to
# conversion to JSON via GAP's JSON package.
#
# The first parameter must be a semigroup, as created by GAP's
# Semigroups Package.
# The second argument must be a single D-class from that semigroup,
# which you can form in a number of ways, including
# DClasses(semigroup)[1].
# The final argument should be a GAP record whose contents will
# govern how this function does its work, as indicated below.
#
# Attributes in the resulting record include:
#  - size := the number of R-classes in the D-class
#  - RClasses := an array of records, each of which has the
#        following attributes:
#    - size := the number of L-classes in the R-class (though not
#        all of these may be included in the return value; you can
#        set a smaller limit in options.NrRClassesIncludedPerDClass)
#    - HClasses := an array of records, each of which is produced
#        by a call to HClassToRecord(), passing this semigroup,
#        one of its H-classes, and the same options object passed
#        to us.  See that function, above, for details on its
#        output format.  (Not all H-classes may be included in the
#        return value; you can set a smaller limit in
#        options.NrLClassesIncludedPerRClass, recalling that a
#        choice of L-class and R-class determines an H-class.)
DClassToRecord := function ( semigroup, dclass, options )
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
            HClassToRecord( semigroup,
                Intersection( lclass, rclass ), options ) )
    ) );
    return result;
end;


# This function converts the given semigroup into a GAP record,
# obeying the options passed in the second argument.
#
# All records formed by this package are of a form amenable to
# conversion to JSON via GAP's JSON package.
#
# The first parameter must be a semigroup, as created by GAP's
# Semigroups Package.
# The second argument should be a GAP record whose contents will
# govern how this function does its work, as indicated below.
#
# Attributes in the resulting record include:
#  - name := a string describing the semigroup.  This will come
#        directly from options.name, if you include such a field,
#        or will be computed from ViewString(semigroup) if you do
#        not, removing the <, >, \<, and \> characters first.
#  - size := the number of D-classes in the semigroup
#  - DClasses := an array of records, each of which has the
#        following attributes:
#    - size := the number of L-classes in the R-class (though not
#        all of these may be included in the return value; you can
#        set a smaller limit in options.NrRClassesIncludedPerDClass)
#    - DClasses := an array of records, each of which is produced
#        by a call to DClassToRecord(), passing this semigroup,
#        one of its D-classes, and the same options object passed
#        to us.  See that function, above, for details on its
#        output format.  (Not all D-classes may be included in the
#        return value; you can set a smaller limit in
#        options.NrDClassesIncluded.)
#  - options := a copy of the options record passed as input,
#        with the exception of the ToString and name fields
EggBoxDiagramRecord := function ( semigroup, options )
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
             DClassToRecord( semigroup, dclass, options ) );
        if options.NrDClassesIncluded > 0
                and options.NrDClassesIncluded
                 <= Length( result.DClasses ) then
            break;
        fi;
    od;
    return result;
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
        data := GapToJsonString( EggBoxDiagramRecord(
            semigroup, options ) )
    ) );
end;
