Full example
============

The files for this example can be found in the documentation folder. Rename the files, removing the descriptive suffix.

The below is a full example 'CMakeLists.txt' file using the Vala CMake macros. 



Add CMakeLists.txt files to subdirectories
==========================================

Copy this code into every subdirectory containing Vala code,

::

  # This code returns the filepaths of source files from the local
  # directory ending in .vala. It is a drop in to a subfolder, and can be
  # executed using the add_directory()  or include() macros.

  file(GLOB paths *.vala)

  set(VALA_SUB_SRCS ${paths} PARENT_SCOPE)



Add a top-level CMakeLists.txt file
===================================

Copy this code into the top directory. To make it run, the APPEND SUBFOLDER_SRCS and APPEND VALA_BINDINGS_LIST lists will need changing. Other packages can be added or removed  as necessary (this set of packages covers an extensive, threaded, Gtk project).

::

  #-----
  # Init
  #-----
  cmake_minimum_required(VERSION 2.6)

  # Add the Vala package
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/vala)


  # Macros for Vala precompiling
  include(FindValaBinding)
  include(FindValaBindingLocations)
  include(UseVala)



  #--------------
  # C Compiler
  #--------------
  project(freight_gtk C)


  #--------------
  # Vala Compiler
  #--------------
  find_package(Vala 0.16 REQUIRED)


  #--------------
  # PkgConfig
  #--------------
  # This call doesn't include 'posix' or 'linux'. These are mappings made by Vala
  # bindings, not libraries with pkg-config compile data.
  find_package(PkgConfig)
  pkg_search_module(GTK REQUIRED  gtk+-2.0 gtk+-3.0)

  pkg_check_modules(GLIB REQUIRED glib-2.0)
  pkg_check_modules(GOBJECT REQUIRED gobject-2.0)
  pkg_check_modules(GIO REQUIRED gio-2.0)
  pkg_check_modules(GIO_UNIX REQUIRED gio-unix-2.0)
  pkg_check_modules(GTK REQUIRED gtk+-2.0)
  pkg_check_modules(GTHREAD REQUIRED gthread-2.0)
  pkg_check_modules(GEE REQUIRED gee-1.0)



  #---------------
  # Compiler Flags
  #---------------
  set(CFLAGS
    ${GLIB_CFLAGS} ${GLIB_CFLAGS_OTHER}
    ${GOBJECT_CFLAGS} ${GOBJECT_CFLAGS_OTHER}
    ${GIO_CFLAGS} ${GIO_CFLAGS_OTHER}
    ${GIO_UNIX_CFLAGS} ${GIO_UNIX_CFLAGS_OTHER}
    ${GTK_CFLAGS} ${GTK_CFLAGS_OTHER}
    ${GTHREAD_CFLAGS} ${GTHREAD_CFLAGS_OTHER}
    ${GEE_CFLAGS} ${GEE_CFLAGS_OTHER}
  )
  add_definitions(${CFLAGS})

  set(LIBS
          ${GLIB_LIBRARIES}
          ${GOBJECT_LIBRARIES}
          ${GIO_LIBRARIES}
          ${GIO_UNIX_LIBRARIES}
          ${GTK_LIBRARIES}
          ${GTHREAD_LIBRARIES}
          ${GEE_LIBRARIES}
  )
  link_libraries(${LIBS})

  set(LIB_PATHS
          ${GLIB_LIBRARIES_DIRS}
          ${GOBJECT_LIBRARY_DIRS}
          ${GIO_LIBRARY_DIRS}
          ${GIO_UNIX_LIBRARY_DIRS}
          ${GTK_LIBRARY_DIRS}
          ${GTHREAD_LIBRARY_DIRS}
          ${GEE_LIBRARY_DIRS}
  )
  link_directories(${LIB_PATHS})



  #--------------------------
  # Vala bindings
  #--------------------------
  # Include 'posix' and 'linux', mappings made by Vala
  # bindings. But gthread-2.0 is part of the xxx binding.
  list(APPEND VALA_BINDINGS_LIST
     posix
     linux
     glib-2.0
     gobject-2.0
     gio-2.0
     gio-unix-2.0
     gtk+-2.0
     gee-1.0
     )

  vala_find_binding_locations(BINDINGS1
    INCLUDE_GENERIC_SYSTEM_DIRECTORY
    INCLUDE_SYSTEM_DIRECTORY
    CUSTOM_BINDING_DIRECTORIES
      vapi
    REQUIRED
    )


  vala_check_binding(BINDINGS1
    REQUIRED
    ${VALA_BINDINGS_LIST}
    )


  #------------------------
  # Gather source locations
  #------------------------

  list(APPEND SUBFOLDER_SRCS
    Common
    GuiWidgets
    PageWidgets
    FormItems
    PipeIO
    Pages
    src
    )


  foreach(subfolder ${SUBFOLDER_SRCS})
    add_subdirectory(${subfolder})
    list(APPEND VALA_SRCS ${VALA_SUB_SRCS})
  endforeach(subfolder ${SUBFOLDER_SRCS})



  #-----------------
  # Vala precompile
  #-----------------
  # Some interresting Valac flags.
  vala_precompile_add_definitions(
    "--disable-assert"
    "--enable-experimental"
    )

  vala_precompile_add_definitions(${BINDINGS1_VALA_BINDINGS_CFLAGS})

  vala_precompile(VALA_C
    ${VALA_SRCS}
    )



  #-----------------
  # Compiling
  #-----------------
  add_executable(out ${VALA_C})

  # This helps, as cmake has been confused by the mention of Vala
  set_target_properties(freight_gtk PROPERTIES LINKER_LANGUAGE C)



  #-----------------
  # Documentation
  #-----------------
  include(UseValadoc)

  add_valadoc_target(BINDINGS1
    FLAGS
      -D ${GTK_VERSION_SYMBOL}
      --enable-experimental
    )



  #-----------------
  # Install
  #-----------------
  install(TARGETS 
    freight_gtk
    RUNTIME
    CONFIGURATIONS
      Release
    DESTINATION
      bin
  )




Out-of-source setup
===================
Create a subdirectory in the project for a build,::

  mkdir build

and navigate into it,::

  cd build



Compiling an executable
=======================

Try a cmake,::

  cmake ../

If that succceded, try compile an execuatable,::

  cmake -DCMAKE_BUILD_TYPE=Release ../

or, on a Make platform,::

  make



Debug
=====

Must be in cmake,::

  cmake -DCMAKE_BUILD_TYPE=Debug ../

then run a debugger,::

  nemiver ./out



Valadoc
=======

This is defined as a target in all configurations, so,::

  cmake --build  --target=doc .

or, on a Make platform,::

  make doc
