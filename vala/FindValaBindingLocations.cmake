# - find locations for Vala bindings
#
# Configure custom directories, and optionally search where bindings are
# commonly found.
#
# Currently tested only on bindings installed by apt-get
#
# Changing the options will have no effect on found bindings until the cache 
# is cleared.
#
# Usage:
#   vala_find_binding_locations(<GROUP_ID> [REQUIRED] [QUIET] [INCLUDE_SYSTEM_DIRECTORY] [INCLUDE_GENERIC_SYSTEM_DIRECTORY] [[CUSTOM_BINDING_DIRECTORIES] [filepath] [<filepath>]*])
#
#
# Takes some arguments resembling standard module:
#   [REQUIRED] [QUIET]
#
#
# Takes arguments:
#  GROUP_ID
#    Namespacing for each invokation of the macro. This means each group
#    of found binding sources can be cached and handled seperately (the action
#    is similar to the PREFIX arg in FindPkgConfig). The intention is to make
#    handling of alternative groups of bindings reasonably evident. If multiple
#    groups of bindings are namespaced, i.e this macro is called several
#    times, each invokation should have a unique GROUP_ID, otherwise they
#    will wipe each other out.
#
#  INCLUDE_GENERIC_SYSTEM_DIRECTORY
#    Will search for a generic binding directory installed on the system.
#
#  INCLUDE_SYSTEM_DIRECTORY
#    Will search for a binding directory installed on the system. The path
#    is built from version information gathered by the module FindVala.
#
#  CUSTOM_BINDING_DIRECTORIES
#    Add custom binding directories. These are relative to the source
#    directory.
#
#
# Defines:
#  <GROUP_ID>_GENERIC_DIR 
#    (CACHED) Variable carrying a generic filepath. Stock vapis are stashed
#    under pathnames with versioned elements. But the Gee library, while
#    installed, sometimes gets split out. This path variable is intended
#    to point at such generic-but-installed vapi directories.
#
#  <GROUP_ID>_VERSIONED_DIR
#    (CACHED) Variable carrying a pathname with a versioned element. This
#    form is built into Valac, so unless package maintainers have been
#    re-coding, the stock Vala bindings will be under here. Cached so it
#    can be altered in edge cases.
#
#  <GROUP_ID>_CUSTOM_DIR_1
#  <GROUP_ID>_CUSTOM_DIR_2
#  <GROUP_ID>_CUSTOM_DIR_3
#  <GROUP_ID>_CUSTOM_DIR_4
#    (CACHED) Variables carrying filepaths. These can be set to custom binding
#    directories. The value is a stub and relative to the source directory.
#    Cached so they can be altered in edge cases.
#
# Like FindPkgConfig, the following variable is namespaced by the
# supplied GROUP_ID (called PREFIX in FindPkgConfig). 
#
#   <GROUP_ID>_LOCATIONS_FOUND
#     Set to 1 if the binding locations exist. If REQUIRED
#     is set, *all* requested locations must be found.
#
#
# Example:
#
#  vala_check_binding(BINDINGS1
#    INCLUDE_GENERIC_SYSTEM_DIRECTORY
#    INCLUDE_SYSTEM_DIRECTORY
#    CUSTOM_BINDING_DIRECTORIES
#      vapi
#    REQUIRED
#    )
#
# Note that INCLUDE_SYSTEM_DIRECTORY presumes
# these bindings can be found in directories such as,
#
#   /usr/share/vala-X.XX/vapi
#
# Under most packaging systems, these bindings will be the right set for a
# X.XX Valac compiler.


#=============================================================================
# Copyright 2013 Robert Crowther. All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#    1. Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
# 
#    2. Redistributions in binary form must reproduce the above copyright notice,
#       this list of conditions and the following disclaimer in the documentation
#       and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY JAKOB WESTHOFF ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
# EVENT SHALL JAKOB WESTHOFF OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
# The views and conclusions contained in the software and documentation are those
# of the authors and should not be interpreted as representing official policies,
# either expressed or implied, of Robert Crowther
#=============================================================================



# TOCONSIDER: find_package_handle_standard_args() is not used because this 
# module namespaces it's <GROUP_ID>_LOCATIONS_FOUND variable.
# TODO: Search on other architectures than apt-get
# TODO: No version checks? Really?
 
include(CMakeParseArguments)


###  Common ###
set(VALA_BINDINGS_LOCATIONS_VERSION 1)

# uncomment the following line to get debug output for this file
# set(_Vala_Binding_Locations_DEBUG True)



# Search for a generic vapidir
# On apt-gets, Gee is stored here, for example.
function(_vala_generic_vapidir _ok _group_id _required _silent)
  # One place to look, works for apt-get
  # TODO: Add more!
  # Don't use find_file(), the filepath search is specific.
  if (IS_DIRECTORY "/usr/share/vala/vapi")
    set(_found_path "/usr/share/vala/vapi")
  endif()

  if(_found_path)
    set(${_group_id}_GENERIC_DIR
      "/usr/share/vala/vapi"
      CACHE
      FILEPATH
      "Generic path to .vapi files"
      )
    if(NOT _silent)
      message(STATUS "Found Vala binding path (generic): ${${_group_id}_GENERIC_DIR}")
    endif()
  else()
    if(_required)
      message(SEND_ERROR "Vala binding directory (generic) requested, but not found")
      set(${_ok} false PARENT_SCOPE)
    endif()
  endif()
endfunction()



# Search for directory path(s) with elements that contain the Vala binding
# version.
#
# Issues warnings if a versioned path does not exist.
# This method tested for apt-get omly.
#
# NB:
# Valac has binding sets locked to the release. The stock binding set ships
# with the compiler.
# The base routes are set through the build system 
# primary: PACKAGE_SUFFIX
# backup: PACKAGE_DATADIR (compiled in).
#
# e.g.
#  /usr/share/vala-0.16/vapi
#  /usr/share/vala-0.18/vapi
#
# Since code constructs these paths, vala build guarentees the prefixed paths
# will exist. Though what the prefix will be is not guarenteed.

# TOCONSIDER: It's a pity we can't find which paths are compiled in, but we can't?
# TODO: GLOB for versions and check?

function(_vala_versioned_vapidir _ok _group_id _required _silent)

  if (NOT VALA_VERSION_MAJOR AND NOT VALA_VERSION_MINOR)
    if (_required)
      message(SEND_ERROR "Unable to find version information to construct required Vala binding path (versioned). The INCLUDE_SYSTEM_DIRECTORY option needs the variables VALA_VERSION_MAJOR and VALA_VERSION_MINOR to be set, which can be done using the FindVala module?")
    endif()
  else()

    # Make a path element in the form "vala-0.18", on the basis that this is
    # what maintainers will do.
    set(_versioned_path_element
      "${VALA_VERSION_MAJOR}.${VALA_VERSION_MINOR}"
      )

    # A place to look, may be specific to apt-get
    # Don't use find_file(), the filepath search is specific.
    # TODO: Add more!
    if (IS_DIRECTORY "/usr/share/vala-${_versioned_path_element}/vapi")
      set(_found_path "/usr/share/vala-${_versioned_path_element}/vapi")
    endif()

    if(_found_path)
      set(${_group_id}_VERSIONED_DIR
        ${_found_path}
        CACHE
        FILEPATH
        "Vala .vapi path with versioned element"
        )
      if(NOT _silent)
        message(STATUS "Found Vala binding path (versioned): ${${_group_id}_VERSIONED_DIR}")
      endif()
    else()
      if(_required)
        message(SEND_ERROR "Vala binding directory of version '${_versioned_path_element}' requested, but not found")
        set(${_ok} false PARENT_SCOPE)
      endif()
    endif()
  endif()

endfunction()




# Check custom vapidirs
# Rebuilds cache if asked (in case the binding version, and so the path,
# changes)
function(_vala_custom_vapidirs _ok _group_id _required _silent)
  set(_custom_vapi_count 1)

  foreach(_custom_vapistub ${ARGN})
    unset(_found_path)

    set(_custom_vapipath ${CMAKE_SOURCE_DIR}/${_custom_vapistub})

    # Don't use find_file(), the filepath search is specific.
    if (IS_DIRECTORY ${_custom_vapipath})
      set(${_group_id}_CUSTOM_DIR_${_custom_vapi_count}
        ${_custom_vapipath}
        CACHE
        FILEPATH
        "Custom path to .vapi files"
        )
      if(NOT _silent)
        message(STATUS "Found Vala binding path (custom): ${_custom_vapipath}")
      endif()
      math(EXPR _custom_vapi_count "${_custom_vapi_count} + 1")
    else()
      if(_required)
        message(SEND_ERROR "Vala binding directory (custom) not found: ${_custom_vapipath}")
      set(${_ok} false PARENT_SCOPE)
      endif()
    endif()
  endforeach()

endfunction()



#
# Main function
#
macro(vala_find_binding_locations _group_id)
  cmake_parse_arguments(ARGS
    "REQUIRED;QUIET;INCLUDE_SYSTEM_DIRECTORY;INCLUDE_GENERIC_SYSTEM_DIRECTORY"
    ""
    "CUSTOM_BINDING_DIRECTORIES"
    ${ARGN}
    )

  if(NOT DEFINED "${_group_id}_LOCATIONS_FOUND")

    set(vala_bindings_location_required_ok true)

    # Set the directories (if not done)
    if(ARGS_INCLUDE_GENERIC_SYSTEM_DIRECTORY)
      _vala_generic_vapidir(
        vala_bindings_location_required_ok
        ${_group_id}
        ${ARGS_REQUIRED}
        ${ARGS_QUIET}
        )
    endif()

    if(ARGS_INCLUDE_SYSTEM_DIRECTORY)
      _vala_versioned_vapidir(
        vala_bindings_location_required_ok
        ${_group_id}
        ${ARGS_REQUIRED}
        ${ARGS_QUIET}
        )
    endif()

    _vala_custom_vapidirs(
      vala_bindings_location_required_ok
      ${_group_id}
      ${ARGS_REQUIRED}
      ${ARGS_QUIET}
      ${ARGS_CUSTOM_BINDING_DIRECTORIES}
      )

    if(vala_bindings_location_required_ok)
      set(${_group_id}_LOCATIONS_FOUND true)
    endif()
  endif()

  if (_Vala_Binding_Locations_DEBUG)
    message(STATUS "--------FindValaBindingLocations.cmake debug------------")
    message(STATUS "vala_bindings_location_required_ok: ${vala_bindings_location_required_ok}")
    message(STATUS "${_group_id}_GENERIC_DIR: ${${_group_id}_GENERIC_DIR}")
    message(STATUS "${_group_id}_VERSIONED_DIR: ${${_group_id}_VERSIONED_DIR}")
    message(STATUS "${_group_id}_CUSTOM_DIR_1: ${${_group_id}_CUSTOM_DIR_1}")
    message(STATUS "${_group_id}_CUSTOM_DIR_2: ${${_group_id}_CUSTOM_DIR_2}")
    message(STATUS "${_group_id}_CUSTOM_DIR_3: ${${_group_id}_CUSTOM_DIR_3}")
    message(STATUS "${_group_id}_CUSTOM_DIR_4: ${${_group_id}_CUSTOM_DIR_4}")
    message(STATUS "${_group_id}_LOCATIONS_FOUND: ${${_group_id}_LOCATIONS_FOUND}")
    message(STATUS "--------------------")
  endif()
endmacro()


mark_as_advanced(
  VALA_BINDINGS_GENERIC_DIR
  VALA_BINDINGS_VERSIONED_DIR
  VALA_BINDINGS_CUSTOM_DIR_1
  VALA_BINDINGS_CUSTOM_DIR_2
  VALA_BINDINGS_CUSTOM_DIR_3
  VALA_BINDINGS_CUSTOM_DIR_4
  )