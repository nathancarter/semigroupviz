

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
DeclareGlobalFunction( "HClassToRecord" );


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
DeclareGlobalFunction( "DClassToRecord" );


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
DeclareGlobalFunction( "EggBoxDiagramRecord" );


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
DeclareGlobalFunction( "ShowSemigroup" );
