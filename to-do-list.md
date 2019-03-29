
# To-do list

## Testing

Write code for testing this package together with a master test script.

 * `ShowCayleyGraph` with `ReturnJSON:=true`
    * should provide empty options object if none
    * should set correct defaults for missing options
    * should create/alter `Multiplication` and `MultString` options
    * should compute `Generators`
    * should create JSON with `tool:="cytoscape"`
    * should include in the graph's `Elements` member a vertex for
      each semigroup element
    * should include in the graph's `Elements` member an edge for
      each element-generator pair

## Finalizing

 * Show the package to Steve to see if it's what he was looking for.
    * In particular, is there any desire for a Cayley-graph-like
      visualization?  (Note the `Generators()` function in the
      semigroups package.)
 * Make any improvements he suggests.
 * Ask Alex if we can include this in the next GAP release.
