#!
#! @Chapter Purpose
#! @ChapterLabel purpose
#!
#! This package adds visualization tools for semigroups.  It is built on the
#! <Package>JupyterViz</Package> package, which means that the
#! visualizations it creates can be used either in Jupyter notebooks or
#! from the &GAP; REPL.
#!
#! When called from a Jupyter notebook input cell, functions like
#! <Ref Func="ShowEggBoxDiagram"/> produce a visualization in the corresponding
#! output cell.  When called from the &GAP; REPL, the same function would
#! show the same visualization by opening it in the user's default web
#! browser.
#!
#! In either case, such visualizations support some level of interactivity,
#! primarily because semigroups can be very large and thuse the user is
#! permitted to select the subset of it that they wish to see.  More
#! documentation on this appears in Section <Ref Sect="Section_interact"/>.
#!
#! At present, there is only one visualization provided for semigroups,
#! the egg-box diagram, which is documented in Chapter <Ref Chap="Chapter_eggbox"/>.
#! This package may be extended with other visualizations in the future.
#!
