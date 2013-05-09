# - find Vala bindings and construct CFLAGS
#
# The module will guarentee named bindings exist under found directories.
#
# Vala bindings are not a direct map to bound code. They use their own
# namespacing. When installed as a package, many bindings may be
# included for uninstalled libraries. Cross-checking would rely on
# intimate knowledge of the bindings, which seems.. tedious. So this
# module makes no attempt to check if the bindings refer to installed
# code. Before running this module, Cmake code can/should, by the
# usual methods, check the underlying libraries exist.
#
# Like FindPkgConfig, this module caches found information. If paths, options  
# (including FindValaLocations options), or system configurations are changed,
# the build cache must be cleared for the changes to have an effect.
#
# This module relies on a previous call to FindValaBindingLocations.
#
# Usage:
#   vala_check_binding(<GROUP_ID> [REQUIRED] [QUIET] <binding name> [<binding name>]*)
#
#
# Takes some arguments resembling standard module:
#   [REQUIRED] [QUIET]
#
# Takes arguments:
#  GROUP_ID
#    Namespacing for each invokation of the macro. Use a name previously
#    defined in a FindValaBindingsLocations call (from that call, this macro
#    knows where to look).
#
#
# Defines:
# Like FindPkgConfig, the following two variables are namespaced by the
# supplied GROUP_ID (called PREFIX in FindPkgConfig). 
# 
#   <IGROUP_ID>_VALA_BINDINGS_FOUND
#     (INTERNAL CACHED) Set to 1 if the bindings exist. If REQUIRED is set,
#     *all* listed bindings must be found.
#
#   <GROUP_ID>_VALA_BINDINGS_CFLAGS
#     (INTERNAL CACHED) flags for a Valac compiler i.e
#     --pkg=XXX ---pkg=XXX etc.
#
#
# Example:
#
#  vala_check_binding(BINDINGS1 REQUIRED posix gio-2.0 gtk+-2.0 gee-1.0)
#


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
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#=============================================================================



# TOCONSIDER: find_package_handle_standard_args() is not used because this 
# module does not always search for, or require, versioning.
# TODO: Search on other architectures than apt-get
# TODO: No version checks?
 
include(CMakeParseArguments)


###  Common ###
set(VALA_BINDINGS_VERSION 1)

# uncomment the following line to get debug output for this file
# set(_Vala_Binding_DEBUG True)

# Unset and set given variables pretyped as CACHED and INTERNAL
macro(_valabindings_unset var)
  set(${var} "" CACHE INTERNAL "")
endmacro()

macro(_valabindings_set var value)
  set(${var} ${value} CACHE INTERNAL "")
endmacro()


# Splits given arguments into options and a package list
macro(_valabindings_parse_options _result _required _silent)
  set(${_required} 0)
  set(${_silent} 0)

  foreach(_pkg ${ARGN})
    if (_pkg STREQUAL "REQUIRED")
      set(${_required} 1)
    endif ()
    if (_pkg STREQUAL "QUIET")
      set(${_silent} 1)
    endif ()
  endforeach()

  set(${_result} ${ARGN})
  list(REMOVE_ITEM ${_result} "REQUIRED")
  list(REMOVE_ITEM ${_result} "QUIET")
endmacro()


function(_vala_check_bindings_internal)

  cmake_parse_arguments(ARGS
    ""
    "REQUIRED;QUIET;GROUP_ID;"
    "BINDINGS"
    ${ARGN}
    )

  _valabindings_unset("${ARGS_GROUP_ID}_VALA_BINDING_FOUND")
  _valabindings_unset("${${ARGS_GROUP_ID}_VALA_BINDINGS_CFLAGS}")

  list(APPEND vala_binding_directories
    ${${ARGS_GROUP_ID}_GENERIC_DIR}
    ${${ARGS_GROUP_ID}_VERSIONED_DIR}
    ${${ARGS_GROUP_ID}_CUSTOM_DIR_1}
    ${${ARGS_GROUP_ID}_CUSTOM_DIR_2}
    ${${ARGS_GROUP_ID}_CUSTOM_DIR_3}
    ${${ARGS_GROUP_ID}_CUSTOM_DIR_4}
    )


  list(LENGTH vala_binding_directories _vala_directories_count)

  if(_vala_directories_count EQUAL 0)
    if (DEFINED ARGS_REQUIRED)
      message(SEND_ERROR "No Vala binding directories found")
    endif ()
  else()

    list(LENGTH ARGS_BINDINGS _vala_bindings_count)

    # Status message of intentions
    if (NOT ARGS_QUIET)
      if (_vala_bindings_count EQUAL 1)
        message(STATUS "checking for binding '${ARGS_BINDINGS}'")
      else()
        message(STATUS "checking for bindings '${ARGS_BINDINGS}'")
      endif()
    endif()

    set(_vala_check_found_bindings)
    set(_vala_check_bindings_no_fails true)

    # iterate through the binding list
    foreach (_vala_binding ${ARGS_BINDINGS})
      set(_binding_exists false)

      # execute the query
      foreach (_vala_binding_dir ${vala_binding_directories})
        if(EXISTS "${_vala_binding_dir}/${_vala_binding}.vapi")
          set(_binding_exists true)
          list(APPEND _vala_check_found_bindings ${_vala_binding})
        endif()
      endforeach()

      # Check for failures
      if (NOT _binding_exists)
        if(NOT ARGS_QUIET)
          message(STATUS "  binding '${_vala_binding}' not found")
        endif()

        set(_vala_check_bindings_no_fails false)
      endif()
    endforeach()


    if(NOT _vala_check_bindings_no_fails)
      # fail when requested
      if (${ARGS_REQUIRED})
        message(SEND_ERROR "Binding requirements failed. See the message output from the build")
      endif()
    else()

      # On success, set variables
      _valabindings_set(${ARGS_GROUP_ID}_VALA_BINDINGS_FOUND 1)
 
      foreach (_binding ${_vala_check_found_bindings})
        list(APPEND _vala_bindings_cflags "--pkg=${_binding}")
        if(NOT ARGS_QUIET)
          message(STATUS "  found ${_binding}")
        endif()
      endforeach()

      _valabindings_set(${ARGS_GROUP_ID}_VALA_BINDINGS_CFLAGS
        "${_vala_bindings_cflags}"
        )
    endif()

  endif()
endfunction()



#
# Main function
#
function(vala_check_binding _group_id)
  cmake_parse_arguments(ARGS
    "REQUIRED;QUIET"
    ""
    ""
    ${ARGN}
    )

  if(NOT ${_group_id}_VALA_BINDINGS_FOUND)
  if(NOT ${_group_id}_LOCATIONS_FOUND)
    if (${_required})
      message(SEND_ERROR "No Vala binding directories supplied. These should have been provided by the FindValaBindingLocations module?")
    endif ()
  else()

    #set(required_ok TRUE)
    #message(STATUS "ARGS_UNPARSED_ARGUMENTS: ${ARGS_UNPARSED_ARGUMENTS}")
    _vala_check_bindings_internal(
      REQUIRED ${ARGS_REQUIRED}
      QUIET ${ARGS_QUIET}
      GROUP_ID ${_group_id}
      BINDINGS ${ARGS_UNPARSED_ARGUMENTS}
      )
  endif()
  endif()

  if (_Vala_Binding_DEBUG)
    message(STATUS "--------FindValaBinding.cmake debug------------")
    message(STATUS "${_group_id}_VALA_BINDINGS_FOUND: ${${_group_id}_VALA_BINDINGS_FOUND}")
    message(STATUS "${_group_id}_VALA_BINDINGS_CFLAGS: ${${_group_id}_VALA_BINDINGS_CFLAGS}")
    message(STATUS "--------------------")
  endif()

endfunction()

