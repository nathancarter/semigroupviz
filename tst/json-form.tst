############################################################################
##
#A  json-form.tst      SemigroupViz Package           Nathan Carter
##
gap> START_TEST("SemigroupViz package: json-form.tst");

# Ensure that the JSON form produced by EggBoxDiagramJSON is correct.

# Tell the package we're inside a Jupyter notebook.
gap> Read( "semigroup-setup.g" ); # later this will be LoadPackage(_,false);
#I  method installed for Matrix matches more than one declaration

# Verify the function exists
gap> IsBound( EggBoxDiagramJSON );
true

#############
#
#
#
# Obviously many more tests need to be added here; this is not complete.
#
#
#
#############

## Each test file should finish with the call of STOP_TEST.
## The first argument of STOP_TEST should be the name of the test file.
## The second argument is redundant and is used for backwards compatibility.
gap> STOP_TEST( "json-form.tst", 10000 );

############################################################################
##
#E
