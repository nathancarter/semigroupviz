
# To-do list

## Options

 * Create in the settings controls a drop-down for choosing a D-class
   and then a spinner for updating that D-class's number.

## Interactivity

 * Make each H-class clickable, with a mouse cursor that is a hand, to
   toggle between "...n more elements" mode and a version with all the
   details available in the JSON.
   (Whenever you create an H-class td, create two divs inside, one with
   class 'default-view' and one with class 'expanded-view'.  Give the
   parent td the class 'view-container'.  After putting the diagram in
   the DOM, find all things in the document with class 'default-view'
   and give them a click event that does this:  Find the nearest ances-
   tor with class 'view-container' and then within that ancestor,
   recursively search downward for each thing with class 'default-view'
   or 'expanded-view' and toggle its visibility; do not recur inside.
   Also, do not recur inside other 'view-container's.)
 * Make the hover text for a row's "...n more" cell show the represent-
   atives for all the hidden H-classes.
 * Make "...n more H-classes" a link that expands all rows of the table
   to show them.  Do this by making that td the 'default-view' class
   in its tr, but make there be several other tds that show all the
   missing pieces, and have class 'expanded-view'.  The row is the
   'view-container' in this case.
 * Make the hover text for a table's "...n more" row show the represent-
   atives for all the H-classes in all the hidden rows.
 * Make "...n more R-classes" a link that expands the table to show
   more rows.  Do this by making that tr the 'default-view' class
   in its table, but make there be several other trs that show all the
   missing pieces, and have class 'expanded-view'.  The table is the
   'view-container' in this case.
 * Make the hover text for a diagrams's "...n more" row show a represent-
   atives for each of the D-classes in all the hidden rows.
 * Make "...n more D-classes" a link that expands the table to show
   more rows.  Do this by making that tr the 'default-view' class
   in its table, but make there be several other trs that show all the
   missing pieces, and have class 'expanded-view'.  The table is the
   'view-container' in this case.  Note that there will therefore be
   some empty columns on the right hand side of the table when it's in
   collapsed view, so that all rows can have the same width, and this is
   not going to hurt anything.
