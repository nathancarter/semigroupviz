#############################################################################
##
##  PackageInfo.g for the package `SemigroupViz'             Nathan Carter
##  (copied and edited from the Example package)
##
##  This file contains meta-information on the package. It is used by
##  the package loading mechanism and the upgrade mechanism for the
##  redistribution of the package via the GAP website.
##
##  For the LoadPackage mechanism in GAP >= 4.5 the minimal set of needed
##  entries is .PackageName, .Version, and .AvailabilityTest, and an error
##  will occur if any of them is missing. Other important entries are
##  .PackageDoc and .Dependencies. The other entries are relevant if the
##  package will be distributed for other GAP users, in particular if it
##  will be redistributed via the GAP Website.
##
##  With a new release of the package at least the entries .Version, .Date
##  and .ArchiveURL must be updated.

SetPackageInfo( rec(


#########
#
#  Name and version
#
#########

PackageName := "SemigroupViz",
Subtitle    := "Visualization Tools for Semigroups",
Version     := "1.0.0",
Date        := "21/03/2019", # Release date of current version, dd/mm/yyyy

##  Optional: if the package manual uses GAPDoc, you may duplicate the
##  version and the release date as shown below to read them while building
##  the manual using GAPDoc facilities to distibute documents across files.
##  <#GAPDoc Label="PKGVERSIONDATA">
##  <!ENTITY VERSION "1.0.0">
##  <!ENTITY RELEASEDATE "21 March 2019">
##  <#/GAPDoc>


#########
#
#  Topic and dependencies
#
#########

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
Status := "dev",
##  If this package is refereed and accepted, you must provide:
# CommunicatedBy := "Person Name (Place Name)",
# AcceptDate := "mm/yyyy",

Keywords := [
  "Semigroups", "visualization", "Green's relations", "egg-box diagram", "HTML"
],

Dependencies := rec(
  GAP := ">= 4.9",
  NeededOtherPackages := [
    [ "JupyterViz",    "1.5.1"   ],
    [ "semigroups",    "3.0.20"  ],
    [ "GAPDoc",        "1.3"     ]
  ],
  SuggestedOtherPackages := [ ]
),


#########
#
#  URLs
#
#########

PackageWWWHome   := Concatenation( "https://nathancarter.github.io/",
                                   LowercaseString( ~.PackageName ) ),
##  Later, if this becomes part of GAP, use:
##  Concatenation( "https://gap-packages.github.io/", LowercaseString( ~.PackageName ) ),
SourceRepository := rec( Type := "git",
                         URL  := Concatenation( "https://github.com/nathancarter/",
                                                LowercaseString( ~.PackageName ) ) ),
IssueTrackerURL  := Concatenation( ~.SourceRepository.URL, "/issues" ),
SupportEmail     := "ncarter@bentley.edu",
README_URL       := Concatenation( ~.PackageWWWHome, "/README.md" ),
PackageInfoURL   := Concatenation( ~.PackageWWWHome, "/PackageInfo.g" ),

##  URL of the archive(s) of the current package release, but *without*
##  the format extension(s), like '.tar.gz' or '-win.zip', which are given next.
##  The archive file name *must be changed* with each version of the archive
##  (and probably somehow contain the package name and version).
##  The paths of the files in the archive must begin with the name of the
##  directory containing the package (in our "example" probably:
##  example/init.g, ...    or example-3.3/init.g, ...  )
ArchiveURL := Concatenation( ~.SourceRepository.URL,
                             "/releases/download/v", ~.Version, "/",
                             LowercaseString( ~.PackageName ), "-", ~.Version ),
ArchiveFormats := ".tar.gz",


#########
#
#  Contact info
#
#########

Persons := [
  rec(
    FirstNames    := "Nathan",
    LastName      := "Carter",
    IsAuthor      := true,
    IsMaintainer  := true,
    Email         := "ncarter@bentley.edu",
    WWWHome       := "http://nathancarter.github.io",
    PostalAddress := Concatenation( [
                       "175 Forest St.\n",
                       "Waltham, MA  02452\n",
                       "USA" ] ),
    Place         := "Waltham",
    Institution   := "Bentley University"
  )
],


#########
#
#  Documentation
#
#########

##  Provide a short (up to a few lines) abstract in HTML format, explaining
##  the package content. This text will be displayed on the package overview
##  Web page. Please use '<span class="pkgname">GAP</span>' for GAP and
##  '<span class="pkgname">MyPKG</span>' for specifing package names.
##
# AbstractHTML := "This package provides  a collection of functions for \
# computing the Smith normal form of integer matrices and some related \
# utilities.",
AbstractHTML :=
  "The <span class=\"pkgname\">SemigroupViz</span> package \
   adds visualization tools for semigroups to GAP. \
   These can be used in Jupyter notebooks or from the GAP REPL.",

PackageDoc := rec(
  BookName  := "SemigroupViz",
  ArchiveURLSubset := [ "doc" ],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Visualization Tools for Semigroups",
),


#########
#
#  Tests
#
#########

##  Provide a test function for the availability of this package.
##  For packages containing nothing but GAP code, just say 'ReturnTrue' here.
##  With the package loading mechanism of GAP >=4.4, the availability
##  tests of other packages, as given under .Dependencies above, will be
##  done automatically and need not be included in this function.
##
AvailabilityTest := ReturnTrue,
TestFile := "tst/testall.g"

) );
