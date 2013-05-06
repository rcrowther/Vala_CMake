==========
Vala CMake
==========
:Authors: 
    Jakob Westhoff, Daniel Pfeifer, Robert Crowther
:Version:
    Draft


About
=====

This code was originally a fork of Jakob Westhoff's CMake Vala code, as updated by Daniel Pfeifer. It is now a stand-alone project. See also the fork-within-a-project by pjanouch.

Please note that these modules have only been tested on apt-get packaged operating systems.



Overview
========

Vala CMake is a collection of macros for the CMake_ build system handling the
creation and management of projects developed using the Vala_ programming
language or it's "Genie" flavor (untested).



Installation
============

To use the Vala macros in your own project you need to copy the macro files to
an arbitrary folder in your projects directory and reference them in your
``CMakeLists.txt`` file.

Assuming the macros are stored under ``cmake/vala`` in your projects folder you
need to add the following information to your base ``CMakeLists.txt``::

    list(APPEND CMAKE_MODULE_PATH 
        ${CMAKE_SOURCE_DIR}/cmake/vala
    )

After the new module path as been added you can simply include the provided
modules or use the provided find routines.


Finding Vala
============

The find module for vala works like any other Find module in CMake.
You can use it by simply calling the usual ``find_package`` function. Default
parameters like ``REQUIRED`` and ``QUIETLY`` are supported, as are version arguments and ``EXACT``.

::

    find_package(Vala 0.16 REQUIRED)

After a successful call to the find_package function the following variables 
will be set:

VALA_FOUND
    Whether the vala compiler has been found or not

VALA_EXECUTABLE
    Full path to the valac executable. if it has been found

VALA_VERSION_STRING
    Version number as a string of the available valac

...and some mainly internal variables.


Precompiling Vala sources
=========================

CMake is mainly supposed to handle c or c++ based projects. Luckily every vala
program is translated into plain c code using the vala compiler, followed by
normal compilation of the generated c program using gcc.

The macro ``vala_precompile`` uses that fact to create c files from your .vala
sources for further CMake processing. 

The first parameter provided is a variable, which will be filled with a list of
c files outputted by the vala compiler. This list can than be used in
conjunction with functions like ``add_executable`` or others to create the
necessary compile rules with CMake.

The initial variable is followed by a list of .vala files to be compiled.
Please take care to add every vala file belonging to the currently compiled
project or library as Vala will otherwise not be able to resolve all
dependencies.

The following sections may be specified afterwards to provide certain options
to the vala compiler:

PACKAGES  
    A list of vala packages/libraries to be used during the compile cycle. The
    package names are exactly the same, as they would be passed to the valac
    "--pkg=" option.

OPTIONS
    A list of optional options to be passed to the valac executable. This can be
    used to pass "--thread" for example to enable multi-threading support.

DIRECTORY
    Specify the directory where the output source files will be stored. If 
    ommitted, the source files will be stored in CMAKE_CURRENT_BINARY_DIR.

CUSTOM_VAPIS
    A list of custom vapi files to be included for compilation. This can be
    useful to include freshly created vala libraries without having to install
    them in the system.

GENERATE_VAPI
    Pass all the needed flags to the compiler to create an internal vapi for
    the compiled library. The provided name will be used for this and a
    <provided_name>.vapi file will be created.

GENERATE_HEADER
    Let the compiler generate a header file for the compiled code. There will
    be a header file as well as an internal header file being generated called
    <provided_name>.h and <provided_name>_internal.h

The following call is a simple example to the vala_precompile macro showing an
example to every of the optional sections::

    vala_precompile(VALA_C
        source1.vala
        source2.vala
        source3.vala
    PACKAGES
        gtk+-2.0
        gio-1.0
        posix
    OPTIONS
        --thread
    CUSTOM_VAPIS
        some_vapi.vapi
    GENERATE_VAPI
        myvapi
    GENERATE_HEADER
        myheader
    )

Most important is the variable VALA_C which will contain all the generated c
file names after the call. The easiest way to use this information is to tell
CMake to create an executable out of it.

::

    add_executable(myexecutable ${VALA_C})


Further reading
===============

CMake Vala by Jakob Westhoff
  https://github.com/jakobwesthoff/Vala_CMake

Jakob Westhoff's `Pdf Presenter Console` example,
  http://westhoffswelt.de/projects/pdf_presenter_console.html

CMake Vala by pjanouch,
  https://github.com/pjanouch/slovnik-gui




Acknowledgments
===============

Thanks to Jakob Westhoff and Daniel Pfeifer, for the code.

.. _CMake: http://cmake.org
.. _Vala: http://live.gnome.org/Vala
.. _Genie: http://live.gnome.org/Genie

