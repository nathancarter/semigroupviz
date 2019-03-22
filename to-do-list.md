
# To-do list

## Bug fixing

 * If the number of elements included in each H-class is smaller than
   the actual number in the H-class in the semigroup, then clicking
   the H-class takes away the ellipsis, even though not all elements
   are shown.
 * If the number of elements included in each H-class is smaller than
   the actual number in the H-class in the semigroup, then two bugs
   show up:
    1. Even after clicking the ellipsis to expand to show the number
       included, the ellipsis remains.
    2. While the ellipsis remains, it is still a link, but clicking
       it does nothing.
 * Same as the previous, but for R-classes in a D-class.
 * Same as the previous, but for L-classes in a D-class.
 * If the number of elements included in each H-class is smaller than
   the actual number in the H-class in the semigroup, then hovering
   the mouse over a cell claims to show all _n_ elements of the
   H-class, but that is incorrect.
 * The note that there are more D-classes not shown is not a
   hyperlink for exposing them.  Once you've fixed this bug,
   re-capture the screenshot for page 8 of the manual, so that the
   text is the correct color, matching the link color in the other
   screenshots.

## Polishing

 * Create the other files necessary to create a manual.
 * Write code for testing this package together with a master test script.
 * Show the package to Steve to see if it's what he was looking for.
    * In particular, is there any desire for a Cayley-graph-like
      visualization?  (Note the `Generators()` function in the
      semigroups package.)
 * Make any improvements he suggests.
 * Publish this to GitHub.
 * Ask Alex if we can include this in the next GAP release.
