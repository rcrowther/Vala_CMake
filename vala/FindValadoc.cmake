# - Find module for the Vala documentation tool (valacdoc) 
# This module determines if Valadoc is installed on the current
# system, and where the executable is located. Please see
# https://live.gnome.org/Valadoc
# 
# Takes standard module arguments: [version] [REQUIRED] [QUIET] [EXACT]
#
# This code sets the following variables:
#  VALADOC_FOUND            - was the Vala compiler found
#  VALADOC_EXECUTABLE        - path to the valac executable (if found)
#  VALADOC_VERSION_STRING     - Version number of the available valac


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
# TODO: Untested on non-Unix architectures?

find_program(VALADOC_EXECUTABLE
   NAMES valadoc
   PATHS "/usr/bin/valadoc"
   DOC "Tool for generating documentation from Vala code (https://live.gnome.org/Valadoc)"
   )

if(VALADOC_EXECUTABLE)
  execute_process(COMMAND ${VALADOC_EXECUTABLE} "--version" 
    OUTPUT_VARIABLE VALADOC_VERSION_STRING
    OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()


# Handle the QUIETLY and REQUIRED arguments, which may be given to the find call.
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Valadoc
  REQUIRED_VARS VALADOC_EXECUTABLE
  VERSION_VAR VALADOC_VERSION_STRING
  )

mark_as_advanced(
  VALADOC_EXECUTABLE
  )
