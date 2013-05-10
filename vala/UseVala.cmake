# - Compile vala files to their c equivalents for further processing
#
# The "vala_precompile" function takes care of calling the valac executable on
# the given sources to produce c files which can then be processed further
# using default cmake functions.
#
# The first parameter provided is a variable, which will be filled with a list
# of c files outputted by the vala compiler. This list can than be used in
# conjunction with functions like "add_executable" or others to create the
# necessary compile rules with CMake.
#
# Valac must be provided with every file belonging to a target in the
# project. Otherwise it can not resolve dependancies. This means it must
# usually be run once only for each target.
#
# The need to run valac once and once only means that, if source data is
# gathered from several areas (subdirectries, say) the data must be in full
# path form. Otherwise, the singular invokation of valac can not trace the
# files, as it has no knowledge of the directories used. This information
# must be in the path. Please construct full path data before passing to this
# function. 
#
# The current approach of this precompiler is to gather the valac-generated
# c files into subdirectories of the build reflecting the source. If any
# subdirectory sources are gathered, the macro add_subdirectory() will
# generate the necessary directories in the build, so is a concise and safe
# invokation (valac can segfualt if output directories are not present).
#
# Usage:
#   vala_precompile output(<output varible> [REQUIRED] [QUIET] <binding name> [<binding name>]*)
#
#
# Takes arguments:
#
#  A Group_Id. Group_Id's provide namespacing for binding sources. They are
#  created by FindValaBindingLocation. See the documentaion for
#  FindValaBindingLocation.
#
#  
#   A list of .vala files to be compiled. Must be in full path form, not
#   filenames.
#
# DIRECTORY
#   Optionally specify an output directory for headers, vapis and c files. If
#   this parameter is specified, it will become a subfolder of the current
#   source directory. If unspecified, material output from valac is sent to
#   the build folder.
#
# CUSTOM_VAPIS
#   A list of custom vapi files to be included for compilation. This can be
#   useful to include freshly created vala libraries without having to install
#   them in the system.
#
# GENERATE_VAPI
#   Pass all the needed flags to the compiler to create an internal vapi for
#   the compiled library. The provided name will be used for this and a
#   <provided_name>.vapi file will be created.
#
# GENERATE_HEADER
#   Let the compiler generate a header file for the compiled code. There will
#   be a header file as well as an internal header file being generated called
#   <provided_name>.h and <provided_name>_internal.h
#
#
# Example:
#
#   vala_precompile(VALA_C
#       source1.vala
#       source2.vala
#       source3.vala
#     DIRECTORY
#       gen
#     CUSTOM_VAPIS
#       some_vapi.vapi
#     GENERATE_VAPI
#       myvapi
#     GENERATE_HEADER
#       myheader
#     )
#
# Note the use of the macro
#
#  vala_precompile_add_definitions()
#
# to add detail to the valac call. This macro is in FindVala, so it can be
# called throughout a CMakeLists.txt file, but it is here the data is used.
#
# Most important is the variable VALA_C which will contain all the generated c
# file names after the call. These will be full-path files.


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



# TODO: Confirm GENERATE_HEADER;GENERATE_VAPI work
# TODO: Function signature.
# TODO: Could use valadocs --quieter?
include(CMakeParseArguments)
cmake_policy(VERSION 2.8)

###  Common ###
set(VALA_USE_VERSION 1)

# uncomment the following line to get debug output for this file
 set(_Vala_Use_DEBUG True)



#---------------------
# Setup Configurations
#---------------------
# CMake does this using internal methods, but we're in the DSL


# TODO:Gumph. Should only happen on Make type builders, etc.
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
  list(APPEND _VALA_PRECOMPILER_FLAGS ${CMAKE_VALA_FLAGS_DEBUG})
elseif(CMAKE_BUILD_TYPE STREQUAL "Release")
  list(APPEND _VALA_PRECOMPILER_FLAGS ${CMAKE_VALA_RELEASE})
elseif(CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
  list(APPEND _VALA_PRECOMPILER_FLAGS ${CMAKE_VALA_FLAGS_RELWITHDEBINFO})
elseif(CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
  list(APPEND _VALA_PRECOMPILER_FLAGS ${CMAKE_VALA_FLAGS_MINSIZEREL})
endif()


# Hack: Replace spaces in flag presets so they resemble lists
# (...or when expanded the add_custom_command() will baulk because it can not
# identify individual options)
# Protect against the _VALA_PRECOMPILER_FLAGS = null, as the string method will
# baulk too.
if(_VALA_PRECOMPILER_FLAGS)
  string(REPLACE " " ";" _VALA_PRECOMPILER_FLAGS ${_VALA_PRECOMPILER_FLAGS})
endif()



# TODO: Beats the debug option, but needs input setting as definitions.
#function(vala_precompile_build_command)
  # message(STATUS  "Valac execute: ${VALA_EXECUTABLE} -C ${header_arguments} ${vapi_arguments} -b ${CMAKE_CURRENT_SOURCE_DIR} -d ${OUTPUT_DIRECTORY} ${_VALA_PRECOMPILER_FLAGS} <some sources...>  ${custom_vapi_arguments}")
  #message(STATUS  "Valac execute: ${VALA_EXECUTABLE} -C ${header_arguments} ${vapi_arguments} -b ${CMAKE_CURRENT_SOURCE_DIR} <some sources...>")
#endfunction()


#----------------
# Vala Precompile
#----------------
function(vala_precompile output)
  cmake_parse_arguments(ARGS
    ""
    "DIRECTORY;GENERATE_HEADER;GENERATE_VAPI"
    "SOURCES"
    ${ARGN}
    )

  if(ARGS_DIRECTORY)
    set(OUTPUT_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${ARGS_DIRECTORY})
  else()
    set(OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  endif()
  include_directories(${OUTPUT_DIRECTORY})

  set(in_files "")
  set(out_files "")
  foreach(src ${ARGS_SOURCES} ${ARGS_UNPARSED_ARGUMENTS})
    list(APPEND in_files "${src}")
    string(REPLACE ${CMAKE_CURRENT_SOURCE_DIR}/  "" src ${src})
    string(REPLACE ".vala" ".c" src ${src})
    string(REPLACE ".gs" ".c" src ${src})
    list(APPEND out_files "${OUTPUT_DIRECTORY}/${src}")
  endforeach()


  set(vapi_arguments "")
  if(ARGS_GENERATE_VAPI)
    list(APPEND out_files "${OUTPUT_DIRECTORY}/${ARGS_GENERATE_VAPI}.vapi")
    set(vapi_arguments "--internal-vapi=${ARGS_GENERATE_VAPI}.vapi")
    
    # Header and internal header is needed to generate internal vapi
    if (NOT ARGS_GENERATE_HEADER)
      set(ARGS_GENERATE_HEADER ${ARGS_GENERATE_VAPI})
    endif()
  endif()

  set(header_arguments "")
  if(ARGS_GENERATE_HEADER)
    list(APPEND out_files "${OUTPUT_DIRECTORY}/${ARGS_GENERATE_HEADER}.h")
    list(APPEND out_files "${OUTPUT_DIRECTORY}/${ARGS_GENERATE_HEADER}_internal.h")
    list(APPEND header_arguments "--header=${OUTPUT_DIRECTORY}/${ARGS_GENERATE_HEADER}.h")
    list(APPEND header_arguments "--internal-header=${OUTPUT_DIRECTORY}/${ARGS_GENERATE_HEADER}_internal.h")
  endif()


  if(_Vala_Use_DEBUG)
    message(STATUS "--------UseVala.cmake debug------------")
    message(STATUS "Valac execute: ${VALA_EXECUTABLE} -C ${_VALA_PRECOMPILER_FLAGS} ${header_arguments} ${vapi_arguments} -b ${CMAKE_CURRENT_SOURCE_DIR} -d ${OUTPUT_DIRECTORY}  <some sources...>")
    message(STATUS "--------------------")
  endif()


  # Note: the valac parameters -b and -d have a simple but effective action.
  # -b (basedirectory) is removed from source filepaths, then -d
  # (target directory) is appended to the remaining stub.
#TODO: Remove custom vapis
  add_custom_command(OUTPUT ${out_files} 
    COMMAND 
      ${VALA_EXECUTABLE}
    ARGS 
      "-C"
      ${_VALA_PRECOMPILER_FLAGS}
      ${header_arguments} 
      ${vapi_arguments}
      "-b" ${CMAKE_CURRENT_SOURCE_DIR} 
      "-d" ${OUTPUT_DIRECTORY}
      ${in_files}
    DEPENDS 
      ${in_files} 
      #${ARGS_CUSTOM_VAPIS}
    )
  set(${output} ${out_files} PARENT_SCOPE)

endfunction()

