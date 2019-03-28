
# To-do list

## Testing

Write code for testing this package together with a master test script.

 * `SGPVIZ_HSV2RGB`
    * should give the correct results on a wide array of example
      input values taken from actual color examples on the web
 * `SGPVIZ_GeneratorsAreSufficient`
    * should judge correctly whether a given set of generators creates
      a connected graph
 * `SGPVIZ_GeneratorsSmallSubset`
    * should drop a redundant generator (start with something that
      is judged sufficient, add something, and ensure something is
      dropped)
 * `SGPVIZ_HClassToRecord`
    * should fill in the correct size (not the imposed limit)
    * should fill in a representative, respecting the `ToString` option
    * should fill in all elements if the options permit, again
      respecting `ToString`
    * should fill in fewer elements if the options require it, again
      respecting `ToString`
    * should guarantee that the representative is the first element,
      even if it was specified in options as something different
 * `SGPVIZ_DClassToRecord`
    * should fill in the correct size (not the imposed limit)
    * should fill in all R-classes if the options permit
    * should fill in fewer R-classes if the options require it
    * should give each R-class the correct size (not the imposed limit)
    * each R-class should fill in all H-classes if the options permit
    * each R-class should fill in fewer H-classes if the options require
 * `SGPVIZ_EggBoxDiagramRecord`
    * should fill in the correct size (not the imposed limit)
    * should copy the options record into its result, minus `ToString`
      and `name`
    * should respect the name given in the options if there is one
    * should create a name if none given in the options
    * should fill in all D-classes if the options permit
    * should fill in fewer D-classes if the options require it
 * `ShowEggBoxDiagram` with `ReturnJSON:=true`
    * should provide empty options object if none
    * should set correct defaults for missing options
    * should put correct boundaries on numerical options
    * should create JSON with `tool:="egg-box"`
    * no need to test more, because that's tested in the tests of
      `SGPVIZ_EggBoxDiagramRecord`
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
