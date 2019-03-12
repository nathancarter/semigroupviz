
# To-do list

## Fixing mistakes and cleaning up code

 * Create an example visualization in which
   `0<NrDClassesIncluded<NrDClasses(S)` and ensure that the following
   properties hold in the visualization.
    * Only `NrDClassesIncluded` are shown and the "more" ellipsis makes it
      clear that the visualization does not have the data to show more.
      The user would need to regenerate the diagram with different
      parameters to see more D-classes.
    * Ensure that the D-class slider has the correct range of values,
      which in this case goes from 1 to `NrDClassesIncluded`.
    * Ensure that all positions on that slider do something sensible; the
      highest position says the comment about no more data available,
      while all the other positions do not.
 * Create an example visualization in which
   `0<NrRClassesIncludedPerDClass<NrRClasses(dclass)` for various values
   of `dclass` and ensure that the following properties hold in the
   visualizations.
    * Only `NrRClassesIncludedPerDClass` are shown and the "more" ellipsis
      makes it clear that the visualization does not have the data to show
      more.  The user would need to regenerate the diagram with different
      parameters to see more R-classes.
    * Ensure that the R-class sliders for the relevant D-classes has the
      correct range of values, which in this case goes from 1 to
      `NrRClasses(dclass)`.
    * Ensure that all positions on that slider do something sensible; the
      highest position says the comment about no more data available,
      while all the other positions do not.
 * Create an example visualization in which
   `0<NrLClassesIncludedPerDClass<NrLClasses(dclass)` and ensure that the
   following properties hold in the visualization.
    * Only `NrLClassesIncludedPerDClass` are shown and the "more" ellipsis
      makes it clear that the visualization does not have the data to show
      more.  The user would need to regenerate the diagram with different
      parameters to see more L-classes (equivalently, H-classes).
    * Ensure that the L-class sliders for the relevant D-classes have the
      correct range of values, which in this case goes from 1 to
      `NrLClasses(dclass)`.
    * Ensure that all positions on that slider do something sensible; the
      highest position says the comment about no more data available,
      while all the other positions do not.
 * Create an example visualization in which
   `0<NrElementsIncludedPerHClass<Size(dclass.RClasses[0].HClasses[0])`
   and ensure that the following properties hold in the visualization.
    * Only `NrElementsIncludedPerHClass` are shown and the "more" ellipsis
      makes it clear that the visualization does not have the data to show
      more.  The user would need to regenerate the diagram with different
      parameters to see more elements.
    * Ensure that the H-class sliders for the relevant D-classes have the
      correct range of values, which in this case goes from 1 to
      `Size(dclass.RClasses[0].HClasses[0])`.
    * Ensure that all positions on that slider do something sensible; the
      highest position says the comment about no more data available,
      while all the other positions do not.

## Finishing first draft of desired features

 * Make "...n more H-classes" a link that expands all rows of the table
   to show them.  Imitate the `toggleViews()` code in `renderHClass()`.
 * Make "...n more R-classes" a link that expands the table to show
   more rows.  Imitate the `toggleViews()` code in `renderHClass()`.
 * Make "...n more D-classes" a link that expands the table to show
   more rows.  Imitate the `toggleViews()` code in `renderHClass()`.

## Feedback

 * Show the package to Steve to see if it's what he was looking for.
 * Make any improvements he suggests.

## Packaging

 * Remove any vestigial code from the `.js` file.
 * Document the whole `.js` file.
 * Factor the `.g` file into `.gi` and `.gd`.
 * Document the `.gd` file.
 * Go through the process for turning this repo into a GAP package repo.
 * Create the other files necessary to create a manual.
 * Make a build script for the manual.
 * Write code for testing this package together with a master test script.
 * Add a README and publish this to GitHub.
 * If Steve's changes have been included, ask Alex if we can include this
   in the next GAP release.
