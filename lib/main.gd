############################################################################
##
##
#W  main.gd              SemigroupViz Package                Nathan Carter
##
##  Declaration file for functions of the SemigroupViz package.
##
#Y  Copyright (C) 2019 University of St. Andrews, North Haugh,
#Y                     St. Andrews, Fife KY16 9SS, Scotland
##

#! @Chapter Function reference
#! @ChapterLabel funcref

#! @Section Private API

#! @Arguments semigroup, hclass, options
#! @Returns a &GAP; record obeying the options passed in the third argument
#! @Description
#!  This function converts the given H-class from the given semigroup
#!  into a &GAP; record amenable to conversion to JSON for passing to one
#!  of the HTML-based visualization tools from the
#!  <Package>JupyterViz</Package> package.
#!  Such conversion can be done by &GAP;'s <Package>JSON</Package> package.
#!
#!  <List>
#!    <Item>The first parameter must be a semigroup, as created by &GAP;'s
#!      <Package>Semigroups</Package> Package.</Item>
#!    <Item>The second argument must be a single H-class from that semigroup,
#!      which you can form in a number of ways, such as by choosing a
#!      D-class, lifting out its first R- and L-classes, and interesecting
#!      them.</Item>
#!    <Item>The final argument should be a &GAP; record whose contents will
#!      govern how this function does its work, as indicated below.</Item>
#!  </List>
#!
#!  Attributes in the resulting record include:
#!  <List>
#!    <Item><Code>size</Code> is the number of elements in the H-class</Item>
#!    <Item><Code>representative</Code> is a string representation of the
#!      H-class's representative.  The string representation will be computed
#!      by passing the H-class's representative element to the
#!      <Code>options.ToString</Code> function.</Item>
#!    <Item><Code>elements</Code> is an array of string representations of
#!      all the elements in the class, by default, or some subset of them
#!      if <Code>options.NrElementsIncludedPerHClass > 0</Code> and smaller
#!      than the number of elements in this particular class.  The
#!      representative is always first on this list.  These string
#!      representations are also computed by <Code>options.ToString</Code>.
#!       </Item>
#!  </List>
DeclareGlobalFunction( "HClassToRecord" );


#! @Arguments semigroup, dclass, options
#! @Returns a &GAP; record obeying the options passed in the third argument
#! @Description
#!  This function converts the given D-class from the given semigroup
#!  into a &GAP; record amenable to conversion to JSON for passing to one
#!  of the HTML-based visualization tools from the
#!  <Package>JupyterViz</Package> package.
#!  Such conversion can be done by &GAP;'s <Package>JSON</Package> package.
#!
#!  <List>
#!    <Item>The first parameter must be a semigroup, as created by &GAP;'s
#!      <Package>Semigroups</Package> Package.</Item>
#!    <Item>The second argument must be a single D-class from that semigroup,
#!      which you can form in a number of ways, such as
#!      <Code>Dclasses(semigroup)[1]</Code>.</Item>
#!    <Item>The final argument should be a &GAP; record whose contents will
#!      govern how this function does its work, as indicated below.</Item>
#!  </List>
#!
#!  Attributes in the resulting record include:
#!  <List>
#!    <Item><Code>size</Code> is the number of R-classes in the D-class</Item>
#!    <Item><Code>RClasses</Code> is an array of records,
#!        each of which has the following attributes:
#!      <List>
#!        <Item><Code>size</Code> is the number of L-classes in the R-class
#!          (though not all of these need be included in the return value;
#!          you can set a smaller limit in
#!          <Code>options.NrRClassesIncludedPerDClass</Code>)</Item>
#!        <Item><Code>HClasses</Code> is an array of records,
#!          each of which is produced by a call to
#!          <Ref Func="HClassToRecord"/>, passing this
#!          <Code>semigroup</Code>, one of its H-classes, and the same
#!          <Code>options</Code> object passed to us.  See that function,
#!          above, for details on its output format.
#!          (Not all H-classes need be included in the return value;
#!          you can set a smaller limit in
#!          <Code>options.NrLClassesIncludedPerRClass</Code>, recalling that
#!          choosing an L-class and an R-class determines an H-class.)</Item>
#!      </List>
#!    </Item>
#!  </List>
DeclareGlobalFunction( "DClassToRecord" );


#! @Arguments semigroup, options
#! @Returns a &GAP; record obeying the options passed in the third argument
#! @Description
#!  This function converts the given semigroup into a &GAP; record
#!  amenable to conversion to JSON for passing to one of the HTML-based
#!  visualization tools from the <Package>JupyterViz</Package> package.
#!  Such conversion can be done by &GAP;'s <Package>JSON</Package> package.
#!
#!  <List>
#!    <Item>The first parameter must be a semigroup, as created by &GAP;'s
#!      <Package>Semigroups</Package> Package.</Item>
#!    <Item>The second argument should be a &GAP; record whose contents will
#!      govern how this function does its work, as indicated below.</Item>
#!  </List>
#!
#!  Attributes in the resulting record include:
#!  <List>
#!    <Item><Code>name</Code> is a string describing the semigroup.
#!      This will come directly from <Code>options.name</Code> if you
#!      include such a field, or will be computed from
#!      <Code>ViewString(semigroup)</Code> if you do not (by removing
#!      angle brackets and line break characters).</Item>
#!    <Item><Code>size</Code> is the number of D-classes in the
#!      semigroup</Item>
#!    <Item><Code>DClasses</Code> is an array of records,
#!      each of which is produced by a call to
#!      <Ref Func="DClassToRecord"/>, passing this
#!      <Code>semigroup</Code>, one of its D-classes, and the same
#!      <Code>options</Code> object passed to us.  See that function,
#!      above, for details on its output format.
#!      (Not all D-classes need be included in the return value;
#!      you can set a smaller limit in
#!      <Code>options.NrDClassesIncluded</Code>.)</Item>
#!    <Item><Code>options</Code> is a copy of the options record
#!      passed as the second parameter, with the exception of its
#!      <Code>ToString</Code> and <Code>name</Code> fields.  (This is
#!      because the <Code>ToString</Code> field is a function, and
#!      thus not amenable to JSON conversion, and the <Code>name</Code>
#!      field has already been included as the <Code>name</Code> field
#!      of the entire return value.)</Item>
#!  </List>
DeclareGlobalFunction( "EggBoxDiagramRecord" );


#! @Section Public API

#! @Arguments semigroup[, options]
#! @Returns nothing
#! @Description
#!  This function displays a visualization of the given semigroup to the
#!  user by calling the display tools in the underlying
#!  <Package>JupyterViz</Package> package.  This means that one of two
#!  methods will be used for showing the user the resulting visualization:
#!  <List>
#!    <Item>If this function is called in a Jupyter Notebook, it returns
#!      an object that, when rendered by that notebook, will result in
#!      the visualization appearing in the correct output cell.</Item>
#!    <Item>If run outside of a Jupyter Notebook, such as in the &GAP;
#!      REPL, this function creates an HTML page containing the given
#!      visualization and then opens the page in the system default web
#!      browser.</Item>
#!  </List>
#!
#!  It accepts the following arguments.
#!  <List>
#!    <Item>The first parameter must be a semigroup, as created by &GAP;'s
#!      <Package>Semigroups</Package> Package.</Item>
#!    <Item>The second argument is optional but if it is present, it
#!      should be a &GAP; record whose contents will
#!      govern how this function does its work, as indicated below.</Item>
#!  </List>
#!
#!  The fields you can provide in the <Code>options</Code> parameter are
#!  as follows.  Each is optional, and its default value is documented
#!  below.
#!  <List>
#!    <Item><Code>ToString</Code> can be a function mapping elements of
#!      the semigroup to strings, as documented in
#!      <Ref Func="HClassToRecord"/>.</Item>
#!    <Item><Code>NrDClassesIncluded</Code> can be the maximum number of
#!      D-classes to compute and include in the JSON object to be
#!      visualized.  This is useful if the semigroup is extremely large,
#!      and you want to send only a manageable amount of JSON data to
#!      be displayed, so that the computation becomes feasible.
#!      This defaults to 20.  Set it to 0 for no limit (if you know your
#!      semigroup is of a reasonable size).</Item>
#!    <Item><Code>NrRClassesIncludedPerDClass</Code> can be the maximum
#!      number of R-classes to compute for any one D-class and include
#!      in the JSON, for the same reasons as described above for
#!      <Code>NrDClassesIncluded</Code>.
#!      This defaults to 20.  Set it to 0 for no limit (if you know your
#!      semigroup's D-classes have a reasonable number of R-classes
#!      each).</Item>
#!    <Item><Code>NrLClassesIncludedPerRClass</Code> can be the maximum
#!      number of L-classes to compute for any one D/R-class and include
#!      in the JSON, for the same reasons as described above for
#!      <Code>NrDClassesIncluded</Code>.
#!      This defaults to 20.  Set it to 0 for no limit (if you know your
#!      semigroup's D-classes have a reasonable number of L-classes
#!      each).</Item>
#!    <Item><Code>NrElementsIncludedPerHClass</Code> can be the maximum
#!      number of elements to compute for any one H-class and include
#!      in the JSON, for the same reasons as described above for
#!      <Code>NrDClassesIncluded</Code>.
#!      This defaults to 20.  Set it to 0 for no limit (if you know your
#!      semigroup's H-classes have a reasonable number of elements
#!      each).</Item>
#!  </List>
DeclareGlobalFunction( "ShowSemigroup" );
