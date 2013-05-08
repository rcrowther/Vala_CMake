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
#   add_valadoc_target(<GROUP_ID> [OUTPUT_DIRECTORY] [TARGET_NAME] [FLAGS])
#
#
# Takes arguments:
# OUTPUT_DIRECTORY
#   Name an output directiory. Relative to the source root. Defaults to 'doc',
#   resulting in <source_root>/doc/doc
#
# TARGET_NAME
#   Name of the target to be formed. Defaults to 'doc'.
#
# FLAGS
#   Add flags to the valadoc call. Valadoc uses slghtly different flags to
#   valac, so they must be explicity set. 
#
#
#
# Example:
#
#  add_valadoc_target(BINDINGS1)
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
# THIS SOFTWARE IS PROVIDED BY ROBERT CROWTHER ``AS IS'' AND ANY EXPRESS OR
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



include(CMakeParseArguments)


###  Common ###
set(VALADOC_VERSION 1)

# uncomment the following line to get debug output for this file
# set(_Valadoc_DEBUG True)

# Find valadoc
find_package(Valadoc REQUIRED)

function(add_valadoc_target _group_id)
  cmake_parse_arguments(ARGS
    ""
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

  add_custom_target(${_target_name}
    COMMAND
      ${VALADOC_EXECUTABLE} --force ${ARGS_FLAGS} -b ${CMAKE_CURRENT_SOURCE_DIR} --directory ${CMAKE_CURRENT_SOURCE_DIR}/${_output_directory}  --vapidir=${VALA_BINDINGS_VERSIONED_DIR} ${VALA_BINDINGS_GENERIC_DIR} ${${_group_id}_VALA_BINDINGS_CFLAGS}  ${VALA_SRCS}
    COMMENT
      "building documentation..."
    VERBATIM
    )

  if(_Valadoc_DEBUG)
    message(STATUS "--------UseValadoc.cmake debug------------")
    message(STATUS "COMMAND: ${VALADOC_EXECUTABLE} --force -D ${GTK_VERSION_SYMBOL} --enable-experimental -b ${CMAKE_CURRENT_SOURCE_DIR} --directory ${CMAKE_CURRENT_SOURCE_DIR}/doc" --vapidir=${VALA_BINDINGS_VERSIONED_DIR} ${VALA_BINDINGS_GENERIC_DIR}${BINDINGS1_VALA_BINDINGS_CFLAGS})
    message(STATUS "--------------------")
  endif()

endfunction()

