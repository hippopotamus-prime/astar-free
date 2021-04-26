cmake_minimum_required(VERSION 3.1.0)
project(asgen)

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

install(TARGETS asgen DESTINATION bin)
