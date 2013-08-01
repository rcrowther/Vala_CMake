==========
Vala CMake
==========
:Authors: 
    Jakob Westhoff, Daniel Pfeifer, Robert Crowther
:Version:
    Draft


About
=====

This code was originally a fork of Jakob Westhoff's `CMake Vala` code, as updated by Daniel Pfeifer. It is now a stand-alone project. See also the fork-within-a-project slovnik-gui_ by pjanouch.

For code on a conceptually higher level, try looking at autovala_.

This CMake module is not compatible with CMake Vala code available elsewhere.``CMakeLists.txt`` files will need to be converted.

Compared to the modules linked above, this module has another basic step, extended documentation, and a by-design approach to handling sources in larger projects. It also has more options. 

If you wish to work on the code, the macros are (are intended to be...) formatted to current cmake requirements, and include `debug` options.

CMake version XXX or greater required.

Please note that these modules have only been tested on apt-get packaged operating systems.



Overview
========

Vala CMake is a collection of macros for the CMake_ build system. The macros handle the creation and management of projects developed using the Vala_ programming language, or it's "Genie" flavor (untested).

This version of Vala CMake contains macros which form a rough analogy to CMake's C compiler syntax.



Installation
============

To use the Vala macros in your own project you need to copy the macro files to
an arbitrary folder in your projects directory. Then reference them in your
``CMakeLists.txt`` file.

Assuming the macros are stored under ``cmake/vala`` in your projects folder, add the following information to your base ``CMakeLists.txt``::

    list(APPEND CMAKE_MODULE_PATH 
        ${CMAKE_SOURCE_DIR}/cmake/vala
    )

After the new module path as been added you can simply include() the provided
modules or use the provided FindXXX() routines.

``Include`` calls for all the packages mentioned below.::

  # Macros for Vala precompiling
  include(FindValaBinding)
  include(FindValaBindingLocations)
  include(UseVala)
  include(UseValadoc)



Finding Vala
============

The FindVala module works like other Find modules in CMake. You can
use it by simply calling the usual ``find_package`` function. Default
parameters like ``REQUIRED`` and ``QUIETLY`` are supported, as are
version arguments and ``EXACT``::

    find_package(Vala 0.16 REQUIRED)

After a successful call to the find_package function the following variables 
will be set:

VALA_FOUND
    Whether the vala compiler has been found or not

VALA_EXECUTABLE
    Full path to the valac executable. if it has been found

VALA_VERSION_STRING
    Version number, as a string, of the available valac

...and some variables, mainly of internal use.


Finding pkg-config, libraries, and bindings
===========================================
This set of CMake modules allows very full and granular detection of
libraries, pkg-config, and bindings. This matches the structure in
other CMake language modules, and allows the coder very granular
control. A machine with two compilers and several bindings is no
problem, and these can even be switched.

However, the Vala compiler, 'valac', has an ability to hunt for
libraries and headers, requiring only a list of pkg-config
specifications. This is rather wonderful. As a gesture towards this,
Vala_CMake includes the AutoVala module, with some functions which
generalizxe the process. If the code has no special binding
requirements, the macros there may be most of what is needed. And they
make the main CMakeLists.txt file much shorter and easier to maintain.



AutoVala
========
Compile vala files to their c equivalents for further processing

The vala compiler, 'valac', has an ability to hunt for libraries and
headers, requiring only a list of pkg-config specifications.

This module contains some code to replicate some of that ability. Not
all of the guesswork is included, as the modules will always be
constructed to capable of mimicking cmake stock setups.

The vala_autopackage() command checks package names, then assembles
lists of package details. It removes most of the bulk of checking
packages, gathering flags, and library testing from the main
CMakeLists.txt file. It sets some common variables via, ::

  add_definitions(${_cflags})
  link_directories(${_library_dirs})

Library details are passed out in a variable, as CMake has deprecated
the general functions for setting these.

Usage:
  vala_autopackage([REQUIRED] [QUIET] [<package name>]*)


Defines:
AUTOVALA_LIBRARIES
   A list of libraries for a target_link_libraries() call.




Finding Vala '.vapi' binding sources
==================================== 

Valac has it's own magic for finding bindings. The source code
includes binding sets as a fallback. The source also has a build which
ensures binding files are installed in predefined directories. This
means an installed valac can find binding sets without needing full
paths.

However, this version of Vala CMake has a macro which explicitly
searches for bindings because,

- The build tool(cmake) should detect and react to the lack of bindings, not
  cause valac to fail.
- Vapi bindings are not a direct map to the underlying libraries, so need
  listing.
- Building a list of flags should be a separate component.

Use the FindValaBindingLocation macro to set the sources of bindings.


GROUP_ID
  Namespacing for each invocation of the macro. This means each group
  of found binding sources can be cached and handled separately. The action
  is similar to the PREFIX arg in FindPkgConfig. The intention is to make
  handling of alternative groups of bindings reasonably evident. If multiple
  groups of bindings are namespaced, i.e this macro is called several
  times, each invocation should have a unique GROUP_ID, otherwise they
  will wipe each other out.

INCLUDE_GENERIC_SYSTEM_DIRECTORY
  Will search for a generic binding directory installed on the system.

INCLUDE_SYSTEM_DIRECTORY
  Will search for a binding directory installed on the system. The path
  is built from version information found by the module FindVala.

CUSTOM_BINDING_DIRECTORIES
  Add custom binding directories. These are relative to the source
  directory.


The following call is a simple example to the macro showing some examples of optional sections ::

  include(FindValaBindingLocations)

  vala_find_binding_locations(BINDINGS1
    INCLUDE_GENERIC_SYSTEM_DIRECTORY
    INCLUDE_SYSTEM_DIRECTORY
    CUSTOM_BINDING_DIRECTORIES
      vapi
    REQUIRED
    )

This will establish a set of variables with a GROUP_ID of ``BINDINGS1``, which can be referenced later. INCLUDE_GENERIC_SYSTEM_DIRECTORY and  INCLUDE_SYSTEM_DIRECTORY will find installed binding locations (only tested on apt-get packaged systems).



Finding Vala '.vapi' bindings
=============================

The ``vala_check_binding`` macro is similar to the ``pkg_check_modules`` function in the CMake module PkgConfig. You can use it by including the function then calling the ``vala_check_binding`` macro, ::

  vala_check_binding(<Group Id> [binding names]...)

The following call is a simple example, ::

  include(FindValaBinding)

  vala_check_binding(BINDINGS1
    REQUIRED
    posix
    gio-2.0
    gtk+-2.0
    gee-1.0
    ) 

Using the ``BINDINGS1`` set of locations, find these bindings and make them REQUIRED (compilation will fail if they are not present).



.. _gathering source files:

Gathering source files
======================

In most projects the CMake build should gather all the source files, then call Valac once. Otherwise valac will complain about missing dependencies (this may not be true for projects with sub-builds producing executables or libraries, but we will ignore that possibility here. These macros can handle that possibility too, if necessary).

This version of the Valac macros can handle source files in subdirectories anywhere. The code can do this by demanding that source files are supplied as full paths (``/home/rodger/ValaProject/src/main.vala``, not ``main.vala``).

Here is a method to get full-path source listings from a subdirectory named ``/examples``. Add a ``CMakeLists.txt`` file to the directory containing,

::

  # This code returns the filepaths of source files from the local
  # directory ending in .vala. It is a drop in to a subfolder, and can be
  # executed using the add_directory()  or include() macros.

  file(GLOB paths *.vala)
  set(VALA_SUB_SRCS ${paths} PARENT_SCOPE)

The directory is GLOBed for all vala sources. GLOB returns full paths. These are set in the variable VALA_SUB_SRCS in the PARENT_SCOPE.

In a top-level ``CMakeLists.txt`` file, add, ::

  add_subdirectory("/examples")
  list(APPEND VALA_SRCS ${VALA_SUB_SRCS})

The ``add_subdirectory`` macro executes the subdirectory ``CMakeLists.txt`` we created, which sets VALA_SUB_SRCS to the GLOB filelist (fullpaths!), then appends the found list to VALA_SRCS. ``add_subdirectory`` also creates a folder in the build tree, reflecting the structure of the source tree.

Repeat for every subdirectory containing Vala code.

When constructing build code, there are many needs. For example, if the directories contain redundant code, a GLOB will fail. The build will need to target specific filenames, so name the files then append CMAKE_CURRENT_LIST_DIRECTORY, to generate full paths ::

  # This code returns the filepaths of name source files from the local
  # directory. It should be customised to a subfolder filelist, and can be
  # executed using the add_directory()  or include() macros.

  set(_vala_sub_paths 
      file1.vala
      file2.vala
      file3.vala
      ...
    )

  foreach(_vala_sub_path ${_vala_sub_paths})
    list(APPEND _paths "${CMAKE_CURRENT_LIST_DIRECTORY}${_vala_sub_path}")
  endforeach()

  set(VALA_SUB_SRCS ${_paths} PARENT_SCOPE)

The above are examples, but will work for many needs.



Precompiler definitions
=======================

At this point, if successfully built, the previous macros have gathered a great deal of data. They know where valac is, they know the flags needed on the compile line, and they can respond to a list of source files. You may wish to add some tweaks to the valac compile, though.

The provision of the following macro may seem fussy, if consistent. But Valac has it's own simplified `code preprocessor`_ for conditional compilation.

Flags can be added by including the UseVala module then calling the ``vala_precompile_add_definitions`` macro. ::

  include(UseVala)

  vala_precompile_add_definitions(
    "--disable-assert"
    "--enable-experimental"
    )

Once custom definitions have been added, use the same macro to add the binding ``--pkg=XXX`` declarations from the bindings. This example follows from the ``vala_check_binding`` example above. ::

  vala_precompile_add_definitions(${BINDINGS1_VALA_BINDINGS_CFLAGS})

Although Valac will not accept `-D` flags through CMake, these macros will recognise them (by simple text substitution, they will not recognise cmake options)::

  vala_precompile_add_definitions("-D GTK2")

Now we have all the data needed to run the precompiler.



Precompiler configuration
=========================

Cmake is cross-platform, and abstracts a handful of possibilities about how targets may be built. The Vala CMake macros react to the configuration (look in the cache to see how).

If CMake code is configured for `Debug`, the Vala CMake macros react and call debug on the Vala code too. ::

  cmake -DCMAKE_BUILD_TYPE=Debug [path to source]

This call will (in a GNU environment) write the C files to the build folder ("--save-temps") and create a dbug executable which can use gdb, Nemiver, etc.

If using a debugger on the code, bear in mind the C files are packed in the cmake build folder, not side by side with the Vala code (in this module, anyway). This is no more awkward than other Vala debugging, just different (we have considered asking CMake code to inform Nemiver code, but see the README).  

A note on the GNU environment - '-O2' optimisation is frequent. CMake `Release` builds are '-O3', but, ::

  cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo

will set an '-O2' flag with C debug info.



Precompiling Vala sources
=========================

CMake is mainly intended for c or c++ based projects. Luckily every Vala
program is translated into plain c code using the vala compiler, followed by
normal compilation of the generated c program using gcc.

The macro ``vala_precompile`` create c files from .vala sources for further CMake processing. 

The first parameter of ``vala_precompile`` is a variable, which will be filled with a list of c files generated by the valac. This list can than be used in
macros like ``add_executable``, or others, to create compile rules with CMake.

The initial variable is followed by a list of .vala files to be compiled.
Please take care to add every vala file belonging to the currently compiled
project/target or library. Otherwise, valac will not be able to resolve all
dependencies.

The following sections may be specified to provide options to the valac:

DIRECTORY
    Specify the directory where the output source files will be stored. If 
    omitted, the source files will be stored in CMAKE_CURRENT_BINARY_DIR.


Following the examples of gathering sources above, an example of the vala_precompile macro, ::

  vala_precompile(VALA_C ${VALA_SRCS})

Most important is the variable VALA_C which will contain all the generated c
file names after the call. This information can be used to create an executable, ::

    add_executable(myexecutable ${VALA_C})


Valadoc
=======

Oh yeah(!) Valadoc needs a list of bindings, so this module depends on the FindValaBindings macro and every other module in this package.

The macro ``add_valadoc_target`` adds a custom target to the build code.

The following sections may be specified to provide options to valadoc,

SYMLINK_FROM_SOURCE
  Create a symlink from the source directory to the documentation index. Only
  works on Unix, on other platforms this option is silently ignored.

EXTRA_TARGETS
  Set up extra targets named <TARGET_NAME>-internal, <TARGET_NAME>-private
  and <TARGET_NAME>-all. All extra targets compile to OUTPUT_DIRECTORY.

OUTPUT_DIRECTORY
  Name an output directory. Relative to the source root. Defaults to 'doc',
  resulting in <source_root>/doc/doc

TARGET_NAME
  Name of the target to be formed. Defaults to 'doc'.

FLAGS
  Add flags to the valadoc call. Valadoc uses slightly different flags to
  valac, so they must be explicitly set. 

An example,::

  include(UseValadoc)
  add_valadoc_target(BINDINGS1
    SYMLINK_FROM_SOURCE
    FLAGS
      --enable-experimental
    )

run,::

  cmake --build . --target doc

or::

  make doc

for insight.

(The macro includes a call to a macro called ``FindValadoc``. This macro can be used alone, but maybe not to much purpose).


Help
====
The source contains a full example in the `docs/` folder.



Further reading
===============

CMake Vala by Jakob Westhoff
  https://github.com/jakobwesthoff/Vala_CMake

Jakob Westhoff's `Pdf Presenter Console` example,
  http://westhoffswelt.de/projects/pdf_presenter_console.html

CMake Vala by pjanouch,
  https://github.com/pjanouch/slovnik-gui



Acknowledgements
================

Thanks to Jakob Westhoff and Daniel Pfeifer, for the code.

.. _CMake: http://cmake.org
.. _Vala: http://live.gnome.org/Vala
.. _code preprocessor: https://live.gnome.org/Vala/Manual/Preprocessor
.. _Genie: http://live.gnome.org/Genie

.. _CMake Vala:   https://github.com/jakobwesthoff/Vala_CMake
.. _slovnik-gui: https://github.com/pjanouch/slovnik-gui
.. _autovala: https://github.com/rastersoft/autovala

