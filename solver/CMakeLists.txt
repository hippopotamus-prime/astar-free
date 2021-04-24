cmake_minimum_required(VERSION 3.1.0)
project(asgen)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

add_executable(asgen
    Puzzle.cpp
    Solver.cpp
    State.cpp
    StatePtr.cpp
)

target_compile_options(asgen PUBLIC
    -O3
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
