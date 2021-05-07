cmake_minimum_required(VERSION 3.9.4)
project(astar)

# Look for dasm in standard paths or DASM_ROOT if set.
find_program(DASM
    NAMES dasm
    HINTS "${DASM_ROOT}"
    HINTS ENV DASM_ROOT
    DOC "The DASM assembler"
)
if(DASM STREQUAL "DASM-NOTFOUND")
    message(FATAL_ERROR "DASM not found; try setting DASM_ROOT")
else()
    message(STATUS "Found DASM at ${DASM}")
endif()

# Look for the VCS headers included with dasm.
get_filename_component(DASM_DIR "${DASM}" DIRECTORY)
find_path(VCS_HEADER_DIR
    NAMES vcs.h
    HINTS "${VCS_ROOT}"
    HINTS ENV VCS_ROOT
    HINTS "${DASM_DIR}"
    PATH_SUFFIXES "machines/atari2600"
    DOC "Directory containing Atari 2600 header files"
)
if(VCS_HEADER_DIR STREQUAL "VCS_HEADER_DIR-NOTFOUND")
    message(FATAL_ERROR "VCS headers not found; try setting VCS_ROOT")
else()
    message(STATUS "Found VCS headers at ${VCS_HEADER_DIR}")
endif()

# Prepare the map solver.
add_subdirectory(solver)
add_custom_target(all_maps)
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/maps")

function(add_map NAME)
    set(INPUT "${CMAKE_CURRENT_SOURCE_DIR}/maps/${NAME}.txt")
    set(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/maps/${NAME}.asm")
    add_custom_command(
        OUTPUT "${OUTPUT}"
        COMMAND asgen "${INPUT}" "${OUTPUT}"
        MAIN_DEPENDENCY "${INPUT}"
        SOURCES "${INPUT}"
        COMMENT "Processing map file ${INPUT}"
        DEPENDS asgen
    )
    set(TARGET "map_${NAME}")
    add_custom_target("${TARGET}" DEPENDS "${OUTPUT}")
    add_dependencies(all_maps "${TARGET}")
endfunction()

# List all map files - these will be subtargets of all_maps.
add_map(map01)
add_map(map02)
add_map(map03)
add_map(map04)
add_map(map05)
add_map(map06)
add_map(map07)
add_map(map08)
add_map(map09)
add_map(map10)
add_map(map11)
add_map(map12)
add_map(map13)
add_map(map14)
add_map(map15)
add_map(map16)
add_map(map17)
add_map(map18)
add_map(map19)
add_map(map20)
add_map(map21)
add_map(map22)
add_map(mapE1)
add_map(mapE2)
add_map(mapS1)

# Prepare rules to build the binaries.
add_custom_target(all_binaries ALL)

function(add_binary VARIANT)
    string(TOLOWER "${VARIANT}" FILE_SUFFIX)
    set(BIN_FILE "astar-${FILE_SUFFIX}.bin")
    set(LIST_FILE "astar-${FILE_SUFFIX}.lst")
    set(INCLUDES
        "-I${VCS_HEADER_DIR}"
        "-I${CMAKE_CURRENT_SOURCE_DIR}"
        "-I${CMAKE_CURRENT_BINARY_DIR}"
        "-I${CMAKE_CURRENT_SOURCE_DIR}/variants/${VARIANT}"
    )

    add_custom_command(
        OUTPUT
            "${BIN_FILE}"
            "${LIST_FILE}"
        COMMAND
            "${DASM}" "${CMAKE_CURRENT_SOURCE_DIR}/astar.asm" -f3 ${INCLUDES} -o"${BIN_FILE}" -l"${LIST_FILE}"
        COMMENT
            "Building ${BIN_FILE}"
        DEPENDS
            "${CMAKE_CURRENT_SOURCE_DIR}/astar.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/kernel.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/memory.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/game.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/sound.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/subroutines.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/state.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/map_loader.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/gradients.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/status_display.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/splash_gfx.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/player_gfx.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/pickup_gfx.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/pickup_colu.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/digit_gfx.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/i2c.inc"
            "${CMAKE_CURRENT_SOURCE_DIR}/speakjet.inc"
            "${CMAKE_CURRENT_SOURCE_DIR}/maps/map_base.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/maps/title.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/maps/end.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/sound/codes.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/sound/groups.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/sound/patterns.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/sound/songs.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/sound/speech.asm"
            "${CMAKE_CURRENT_SOURCE_DIR}/variants/${VARIANT}/variant.h"
    )

    set(TARGET "binary_${VARIANT}")
    add_custom_target("${TARGET}" DEPENDS "${BIN_FILE}")
    add_dependencies("${TARGET}" all_maps)
    add_dependencies(all_binaries "${TARGET}")
endfunction()

# List all binary variants - these will be subtargets built by "make all".
add_binary(PAL50)
add_binary(PAL60)
add_binary(NTSC)
