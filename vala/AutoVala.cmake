# - Compile vala files to their c equivalents for further processing
#
# The vala compiler, 'valac', has an ability to hunt for libraries and
# headers, requiring only a list of pkg-config specifications.
#
# This module contains some code to replicate some of that
# ability. Not all of the guesswork is included, as the modules will
# always be constructed to capable of mimicking cmake stock setups.
#
#
# The vala_autopackage() command checks package names, then assembles
# lists of package details. It removes most of the bulk of checking
# packages, gathering flags, and library testing from the main
# CMakeLists.txt file. It sets some common variables via,
#
#  add_definitions(${_cflags})
#  link_directories(${_library_dirs})
#
# Library details are passed out in a variable, as CMake has
# deprecated the general functions for setting these.
#
# Usage:
#   vala_autopackage([REQUIRED] [QUIET] [<package name>]*)
#
#
# Defines:
# AUTOVALA_LIBRARIES
#     A list of libraries for a target_link_libraries() call.
#
#


#=============================================================================
# Copyright 2013 Robert Crowther
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
# either expressed or implied, of Jakob Westhoff
#=============================================================================


# TODO: should be namespaced, or is that too much?
# TODO: Should go on and do binding?
include(CMakeParseArguments)
cmake_policy(VERSION 2.8)
find_package(PkgConfig)

###  Common ###
set(VALA_USE_VERSION 1)

# uncomment the following line to get debug output for this file
# set(_AutoVala_DEBUG True)



#----------------
# Vala Autopackage
#----------------


function(vala_autopackage)
  cmake_parse_arguments(ARGS
    "REQUIRED;SILENT"
#    "DEFINITIONS"
    ""
    ""
    ${ARGN}
    )


  if(_AutoVala_DEBUG)
    message(STATUS "--------AutoVala.cmake debug------------")
    message(STATUS "AutoVala will attempt to\n - find pkg-config\n - find libraries\n - check versioning\n - generate CFLAGS and -l flags\n for:")
    message(STATUS ${ARGS_UNPARSED_ARGUMENTS})
    message(STATUS "--------------------")
  endif()

  if(ARGS_REQUIRED)
    set(required "REQUIRED")
  else()
    set(required "")
  endif()

  if(ARGS_QUIET)
    set (quiet "QUIET")
  else()
    set (quiet "")
  endif()


  foreach (_pkg ${ARGS_UNPARSED_ARGUMENTS})
    # message(STATUS " try ${required} ${quiet} ${_pkg}")

    # For construction of internal variables,
    # get the initial string and uppercase
    string(REGEX MATCH "[^-]+" _pkg_name ${_pkg})
    string(TOUPPER ${_pkg_name}  _pkg_name)

    # Check modules
    pkg_check_modules(${_pkg_name} ${required} ${quiet} ${_pkg})

    # Test if there was a pkg-config. The coder may have made it
    # optional, in which case non-existence passes above line, but
    # this function should not continue with that package.
    if(${_pkg_name}_FOUND)
      # Append to the lists for processing
      list(APPEND _cflags ${${_pkg_name}_CFLAGS} ${${_pkg_name}_CFLAGS_OTHER})
      list(APPEND _libraries ${${_pkg_name}_LIBRARIES})
      list(APPEND _library_dirs ${${_pkg_name}_LIBRARY_DIRS})
    endif()
  endforeach()

  # Add data found.
  # This can be done for CFLAGS and LIBRARY_DIRS but not for
  # libraries, which should now use,
  #
  # target_link_libraries()
  #
  add_definitions(${_cflags})
  link_directories(${_library_dirs})
  set(AUTOVALA_LIBRARIES ${_libraries} CACHE INTERNAL "")


  if(_AutoVala_DEBUG)
    message(STATUS " _cflags: ${_cflags}")
    message(STATUS " AUTOVALA_LIBRARIES: ${AUTOVALA_LIBRARIES}")
    message(STATUS " _library_dirs: ${_library_dirs}")
  endif()

endfunction()

