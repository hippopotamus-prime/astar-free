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
