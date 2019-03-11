
# This file follows the pattern set down in the Example package.
# It runs all .tst files in this same directory.

# Later you will uncomment this line, when this is a package.
# LoadPackage( "package-name" );

TestDirectory(
  # Later you will uncomment this line, when this is a package.
  # DirectoriesPackageLibrary( "package-name", "tst" ),
  # Until then, just use a hard-coded string:
  "/Users/nathan/.gap/pkg/semigroupviz/",
  rec( exitGAP     := true,
       testOptions := rec( compareFunction := "uptowhitespace" ) ) );

FORCE_QUIT_GAP(1); # if we ever get here, there was an error
