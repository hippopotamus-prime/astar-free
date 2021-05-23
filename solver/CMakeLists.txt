###########################################################################
# AStar Map Generator
# Copyright 2005 Aaron Curtis
# 
# This file is part of AStar.
# 
# AStar is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# AStar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with AStar; if not, see <https://www.gnu.org/licenses/>.
###########################################################################

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    message(STATUS "Defaulting to Release build")
    set(CMAKE_BUILD_TYPE "Release"
        CACHE STRING "Choose the type of build"
        FORCE
    )
endif()

add_executable(asgen
    Puzzle.cpp
    Solver.cpp
    State.cpp
)

target_compile_options(asgen PUBLIC
    $<$<CONFIG:Debug>:-Og>
    $<$<CONFIG:Release>:-march=native>
    -Wall
    -Wextra
    -Wno-unused-parameter
    -Wredundant-decls
    -Wcast-align
    -Wmissing-declarations
    -Wmissing-include-dirs
    -Winvalid-pch
    -Wformat=2
)

include(CheckIPOSupported)
check_ipo_supported(RESULT HAVE_IPO)
if(HAVE_IPO AND CMAKE_BUILD_TYPE STREQUAL "Release")
    set_property(TARGET asgen PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
endif()

install(TARGETS asgen DESTINATION bin)
