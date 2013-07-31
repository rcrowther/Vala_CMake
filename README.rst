==========
Vala CMake
==========
:Authors: 
    Jakob Westhoff, Daniel Pfeifer, Robert Crowther
:Version:
    Draft


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

Below is a quickstart. For a fuller description of the macros, see the packaged MANUAL.
 

============
 Quickstart
============
There is some setting to do. 


Beforehand
==========
The system needs ``cmake`` installed. Recent packages will do fine, there is nothing progressive here.


Download
========
Download from Github, or clone using git, ::

  git clone https://github.com/rcrowther/Vala_CMake.git

This will give a folder of cmake data.


The folder can be cloned directly into the project folder of code to be compiled, so, ::

  .../src_root/CMake_Vala/

If the folder is cloned into place, then most updates can be make using, ::

  git pull  

Otherwise, if any updates are required, old code will need to be deleted and replaced with new code (though this is an easy job).



Macro install (if not cloned in place)
======================================
The coder may have reasons for not cloning in place. One reason, for example, may be some objection to the rather exaggerated Github folder name 'Vala_CMake' appearing in the source directory. In which case, in the source directory, create a directory named, for example, /cmake, ::

  .../src_root/cmake/

Then move the folder named 'vala' from the download into that, ::

  .../src_root/cmake/vala

If the macros are placed in this way, the line in the main CMakeLists.txt file, ::

  list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/Vala_CMake/vala)

must be altered, to, for example, ::

  list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)


Source folder creation
======================
Create new folders in the source (or intended source), ::

  /cmake
  /build
  /vapi

The /vapi folder may not be needed for your project, but the provided example CMakeLists.txt file references it (if that annoys you, remove the references).

/build is not necessary, but...


Out of source builds
====================
CMake has the ability to create out-of-source builds. That is, the generated compiled files, and some cmake and system build files (such as makefiles) are placed in a separate folder. This is unlike the results of most compilers, which would put the .o files, and any whatever else, next to the original files. This might seem intuitive, but putting files in a separate folder,

- Means source file folders are kept clean, and the coder doesn't need to rake through a lot of extra files to find source code to edit.
- Removing a build to create a new one is as easy as deleting the folder.

There are few disadvantages to out-of-source builds, and they are recommended.

The /build folder is where we will keep all this data.


The two example files
=====================
In /CMake_Vala, in the /docs folder, are two example cmake macro files. To prevent confusion, if they were accidentally included in a build, they have meaningless suffixes (they would be unlikely to do any damage though, if that happened). The files will need to be put in the places they are needed, and the suffixes removed.


Activate subdirectories
-----------------------
Rename, :: 

  CMakeLists.txt.subdirectory

as, ::

  CMakeLists.txt

and put a copy in every subdirectory with source files for the Vala build (not directories which do not contain code to be Vala compiled, such as /icons /doc etc.) e.g.::

  src_root_directory/src/CMakeLists.txt
  src_root_directory/mySuperWidgets/CMakeLists.txt
  src_root_directory/mySuperWidgets/CMakeLists.txt
  ...



Copy in the main file
---------------------
Rename, ::

  CMakeLists.txt.mainfile

as, ::

  CMakeLists.txt

and place in the top level of source,



Rewrite the main file
=====================
The file is heavily annotated about what needs to be done. But, quickly,

- Rename the project to a name of your choosing.
  Use a search and replace on 'projectName'

- Replace the binding lists with your choice.
  The current settings are for a threaded Gtk project

- List the subdirectories you wish CMake to look at.



Compile!
========

Inplace build
-------------
"I'd like the compile files next to source files" ::

  cd .../src_root

  cmake

  make


Out-of-source build
-------------------
"I'd like the compile files tidied away into a folder" ::

  cd .../src_root_directory/build

  cmake ..

  make

i.e. run 'cmake' from where the compiling should be, give a filepath which points at where the main CMakeLists.txt file can be found.



Valadoc
=======
Oh, yes. After building, ::

  cmake --build . --target doc

or, on 'make' sytems, this will work too, ::

  make doc



When coding
===========
If subdirectory structure is changed
  the new subdirectories will need the subdirectory code adding. After
  any change, the main CMakeLists.txt file will need to be edited
  (this can not be made automatic, CMake needs to have code in the
  subdirectories).

If file structure is changed in enabled subdirectories (deletions, renaming, addition)
  run 'cmake' again, then 'make'.

If code is changed
  run 'make'.


Change compile strategy
=======================
To use the builtin CMake compile strategies, remake the build files, ::

  cmake -DCMAKE_BUILD_TYPE=Release
  cmake -DCMAKE_BUILD_TYPE=Debug

To change settings in the CMake interface (filepaths, debug switches, other options) ::

  cmake -i

for ncurses, or, if the system has the QT interface loaded, ::

  click on the file CMakeCache.txt



Help
====
Source contains CMakeLists.txt examples in the `docs/` folder.

If you need to tune the main file for different compilers, bindings, rejecting certain files, and so forth, there is a fairly extensive MANUAL in the docs folder. MANUAL seems a rather grand title, but Vala_CMake has many options.



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

