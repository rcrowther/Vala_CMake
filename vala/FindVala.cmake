# - find module for the Vala compiler (valac)
#
# Determine if a Vala compiler is installed on the current system, and where
# the executable is located.
# 
# All current and anticipated Valac versions are supported. Unix only 
# (currently). Special support is included for apt-get installations - this
# module can find some alternate valac versions.
#
# This module supports versioning. It tests the found executable, and also
# searched for executables with versioned names.
#
# This module also adds some compiler flag variables.
#
# Usage:
#  find_package(Vala [version] [EXACT] [REQUIRED] [QUIET])
#
#
# Defines:
#  VALA_FOUND               - was the Vala compiler found
#  VALA_EXECUTABLE          - path to the valac executable (if found)
#  VALA_VERSION_STRING      - version number of the available valac
#  VALA_VERSION_MAJOR       - valac major version found e.g. 0
#  VALA_VERSION_MINOR       - valac minor version found e.g. 18
#  VALA_VERSION_PATCH       - valac patch version found e.g. 0
#
# Also defines some compiler flag vartiables. These are for a vala precompile
# and mimic CMAKE_C_FLAGS_DEBUG etc. The most interesting is for a new
# configuration, VALAPRECOMPILE.
#
#
# Examples:
# Cmake assumes backwards compatibility on versions. So,
#
#  find_package(Vala 0.06)
#
# will pass a valac version 0.18. The version statement is a minimum.
#
# The arg REQUIRED does not influence versions, but demands a valac is
# present,
#
#  find_package(Vala 0.06 REQUIRED)
#
# will pass a valac version 0.18 (but fatally fail the build if no valac
# exists)
#
# In Vala coding, it is common to have several versions of compilers. Within
# Debian-based apt-get packaging this module will search for alternate
# versions, if necessary. The search can be enforced using the EXACT argument,
#
#  find_package(Vala 0.18 EXACT REQUIRED)
#
# EXACT definitions may need to include patch numbers, as returned by,
# 
#  > valac[-X.XX] --version
#
# ...EXACT is serious about version matching.
#


#=============================================================================
# Copyright 2009-2010 Jakob Westhoff. All rights reserved.
# Copyright 2010-2011 Daniel Pfeifer
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


# TODO: See FindPerl for Cygwin install
# TODO: See FindRuby for native Win type installs.
# TODO: Um, vala_FIND_QUIETLY vala_REQUIRED is builtin?
# TODO: Handle debug, add EXTENDED_SEARCH

### Common stuff ####
set(VALA_VERSION 1)

# Set the policy for if...then. Wez uses a lot of if..thens.
cmake_policy(VERSION 2.8)

# uncomment the following line to get debug output for this file
# set(_Vala_DEBUG True)


# Set some flags
# CMake usually does this during compiler detection. Our extensions are here
# for now. Should they get extensive, due to compilers or platform, this will
# need to be reconsidered.
# The FAQ is about overriding, I dont think we should FORCE R.C.
# http://www.cmake.org/Wiki/CMake_FAQ
#TODO: Do we need -g on RELWITHDEBINFO and MINSIZEREL?
set(CMAKE_VALA_FLAGS ""
  CACHE STRING "Flags used by valac during all build types."
  )
set(CMAKE_VALA_FLAGS_DEBUG "-g --save-temps"
  CACHE STRING "Flags used by valac during debug builds."
  )
set(CMAKE_VALA_RELEASE ""
  CACHE STRING "Flags used by valac during release builds."
  )
set(CMAKE_VALA_FLAGS_RELWITHDEBINFO ""
  CACHE STRING "Flags used by valac during Release with Debug Info builds."
  )
set(CMAKE_VALA_FLAGS_MINSIZEREL ""
  CACHE STRING "Flags used by valac during release minsize builds."
  )

# The configuration "precompile" should never reach a compiler
set(CMAKE_VALA_FLAGS_VALAPRECOMPILE "--save-temps"
  CACHE STRING "Flags used by valac during Vala Precompilation only builds." 
  )


mark_as_advanced(
CMAKE_VALA_FLAGS
CMAKE_VALA_FLAGS_DEBUG
CMAKE_VALA_RELEASE
CMAKE_VALA_FLAGS_RELWITHDEBINFO
CMAKE_VALA_FLAGS_MINSIZEREL
CMAKE_VALA_FLAGS_VALAPRECOMPILE
  )

# Search for a generic valac executable in the usual system paths.
find_program(VALA_EXECUTABLE valac)


# Determine the valac version
if(VALA_EXECUTABLE)
  execute_process(COMMAND ${VALA_EXECUTABLE} "--version" 
    OUTPUT_VARIABLE _vala_version_str_internal
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  string(REPLACE "Vala " "" VALA_VERSION_STRING "${_vala_version_str_internal}")
endif()


# If the generic version doesn't match versioning, look for a versioned
# executable. This must have version info, hence the big condition.
if(
  NOT VALA_EXECUTABLE
  OR (${VALA_VERSION_STRING} LESS ${Vala_FIND_VERSION})
  OR (Vala_FIND_VERSION_EXACT AND NOT (${VALA_VERSION_STRING} EQUAL ${Vala_FIND_VERSION}))
  AND (Vala_FIND_VERSION AND Vala_FIND_VERSION_MAJOR AND Vala_FIND_VERSION_MINOR)
  )


  # If extending the search, the generic executable failed (even if on
  # versioning only), so ensure these are unset.
  unset(VALA_EXECUTABLE CACHE)
  unset(VALA_VERSION_STRING)



  # If the user has specified a path, add extra executable names
  # TODO: extend for other architecture/OS cases.

  # This works for apt-get
  set(_vala_versioned_executable_name "valac-${Vala_FIND_VERSION_MAJOR}.${Vala_FIND_VERSION_MINOR}")



  if(DEFINED _Vala_DEBUG)
    message(STATUS "Generic executable find failed, seeking alternative executable: ${_vala_versioned_executable_name}")
  endif()

  find_program(VALA_EXECUTABLE ${_vala_versioned_executable_name})

  # If this suceeded, get the version string by execution
  # Slow, repetitive, but robust and consistent.
  if(VALA_EXECUTABLE)
    execute_process(COMMAND ${VALA_EXECUTABLE} "--version" 
      OUTPUT_VARIABLE _vala_version_str_internal
      OUTPUT_STRIP_TRAILING_WHITESPACE
      )
    string(REPLACE "Vala " "" VALA_VERSION_STRING "${_vala_version_str_internal}")
  endif()
endif()



# If a version string exists (executable found), get the versioning variables.
if (DEFINED VALA_VERSION_STRING)
  set(_vala_find_version_str ${VALA_VERSION_STRING})
  string(REGEX REPLACE "^([0-9]+)\\.[0-9]+\\.[0-9]+" "\\1" VALA_VERSION_MAJOR "${_vala_find_version_str}")
  string(REGEX REPLACE "^[0-9]+\\.([0-9]+)\\.[0-9]+" "\\1" VALA_VERSION_MINOR "${_vala_find_version_str}")
  string(REGEX REPLACE "^[0-9]+\\.[0-9]+\\.([0-9]+)" "\\1" VALA_VERSION_PATCH "${_vala_find_version_str}")
endif()



# Handle the QUIETLY and REQUIRED arguments, which may be given to the find call.
include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(Vala
  REQUIRED_VARS VALA_EXECUTABLE
  VERSION_VAR VALA_VERSION_STRING
  )

mark_as_advanced(VALA_EXECUTABLE)

if(DEFINED _Vala_DEBUG)
  message(STATUS "--------FindVala.cmake debug------------")
  message(STATUS "Vala_FIND_VERSION_EXACT: ${Vala_FIND_VERSION_EXACT}")
  message(STATUS "VALA_FOUND: ${VALA_FOUND}")
  message(STATUS "VALA_EXECUTABLE: ${VALA_EXECUTABLE}")
  message(STATUS "VALA_VERSION_STRING: ${VALA_VERSION_STRING}")
  message(STATUS "VALA_VERSION_MAJOR: ${VALA_VERSION_MAJOR}")
  message(STATUS "VALA_VERSION_MINOR: ${VALA_VERSION_MINOR}")
  message(STATUS "VALA_VERSION_PATCH: ${VALA_VERSION_PATCH}")
  message(STATUS "--------------------")
endif()

