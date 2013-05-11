# - find a valadoc executable and construct custom target for documentation
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
#   add_valadoc_target(<GROUP_ID> [SYMLINK_FROM_SOURCE] [OUTPUT_DIRECTORY] [TARGET_NAME] [FLAGS])
#
#
# Takes arguments:
# SYMLINK_FROM_SOURCE
#   Create a symlink from the source directory to the documentation index. Only
#   works on Unix, on other platforms this option is silently ignored.
#
# OUTPUT_DIRECTORY
#   Name an output directory. Relative to the source root. Defaults to 'doc',
#   resulting in <source_root>/doc/doc
#
# TARGET_NAME
#   Name of the target to be formed. Defaults to 'doc'.
#
# FLAGS
#   Add flags to the valadoc call. Valadoc uses slightly different flags to
#   valac, so they must be explicitly set. 
#
#
#
# Example:
#
#  add_valadoc_target(BINDINGS1
#    SYMLINK_FROM_SOURCE
#    FLAGS
#      --enable-experimental
#    )
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



include(CMakeParseArguments)


###  Common ###
set(USEVALADOC_VERSION 1)

# uncomment the following line to get debug output for this file
# set(_Valadoc_DEBUG True)

# Find valadoc
find_package(Valadoc REQUIRED)

function(add_valadoc_target _group_id)
  cmake_parse_arguments(ARGS
    "SYMLINK_FROM_SOURCE"
    "OUTPUT_DIRECTORY;TARGET_NAME"
    "FLAGS"
    ${ARGN}
    )

  if(ARGS_TARGET_NAME)
    set(_target_name ${ARGS_TARGET_NAME})
  else()
    set(_target_name "doc")
  endif()

  if(ARGS_OUTPUT_DIRECTORY)
    set(_output_directory ${ARGS_OUTPUT_DIRECTORY})
  else()
    set(_output_directory "doc")
  endif()


  # Collect the binding paths
  list(APPEND _binding_directories
    ${${_group_id}_GENERIC_DIR}
    ${${_group_id}_VERSIONED_DIR}
    ${${_group_id}_CUSTOM_DIR_1}
    ${${_group_id}_CUSTOM_DIR_2}
    ${${_group_id}_CUSTOM_DIR_3}
    ${${_group_id}_CUSTOM_DIR_4}
    )

  foreach(_dir ${_binding_directories})
    list(APPEND _vapi_arguments "--vapidir=${_dir}")
  endforeach()


  add_custom_target(${_target_name}
    COMMAND
      ${VALADOC_EXECUTABLE} --force ${ARGS_FLAGS} -b ${CMAKE_CURRENT_SOURCE_DIR} --directory ${CMAKE_CURRENT_SOURCE_DIR}/${_output_directory} ${_vapi_arguments} ${${_group_id}_VALA_BINDINGS_CFLAGS}  ${VALA_SRCS}
    COMMENT
      "building documentation..."
    VERBATIM
    )

  # If not UNIX, silently ignore. Too trivial, and makes the code
  # cross-platform.
  if(ARGS_SYMLINK_FROM_SOURCE AND UNIX)
    add_custom_command(TARGET ${_target_name}
      POST_BUILD
      COMMAND
        cmake -E create_symlink ${_output_directory}/doc/index.htm docs
      DEPENDS
        ${_target_name}
      WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
      COMMENT
        "creating symlink to documentation"
      VERBATIM
      )
  endif()

  if(_Valadoc_DEBUG)
    message(STATUS "--------UseValadoc.cmake debug------------")
    message(STATUS "ARGS_SYMLINK_FROM_SOURCE: ${ARGS_SYMLINK_FROM_SOURCE}")
    message(STATUS "COMMAND: ${VALADOC_EXECUTABLE} --force ${ARGS_FLAGS} -b ${CMAKE_CURRENT_SOURCE_DIR} --directory ${CMAKE_CURRENT_SOURCE_DIR}/${_output_directory} ${_vapi_arguments} ${${_group_id}_VALA_BINDINGS_CFLAGS} <some Vala sources...>")
    message(STATUS "--------------------")
  endif()

endfunction()

