cmake_minimum_required(VERSION 3.12)
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
file(MAKE_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/maps")

function(add_map_rule INPUT OUTPUT)
    add_custom_command(
        OUTPUT "${OUTPUT}"
        COMMAND asgen "${INPUT}" "${OUTPUT}"
        MAIN_DEPENDENCY "${INPUT}"
        SOURCES "${INPUT}"
        COMMENT "Processing map file ${INPUT}"
        DEPENDS asgen
    )
endfunction()

function(add_maps)
    # Add a rule to process each map file with the solver
    foreach(NAME ${ARGV})
        set(MAP_TXT "${CMAKE_CURRENT_SOURCE_DIR}/maps/${NAME}.txt")
        set(MAP_ASM "${CMAKE_CURRENT_BINARY_DIR}/maps/${NAME}.asm")
        set(PROCESSED_MAP_FILES "${PROCESSED_MAP_FILES}" "${MAP_ASM}")
        add_map_rule("${MAP_TXT}" "${MAP_ASM}")
    endforeach()

    # Add one more rule to generate an include file with the processed maps
    set(ALL_MAPS_INC "${CMAKE_CURRENT_BINARY_DIR}/map_includes.inc")
    set(SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/MapIncludes.cmake")
    separate_arguments(MAP_NAMES_ARG NATIVE_COMMAND "${ARGV}")
    add_custom_command(
        OUTPUT "${ALL_MAPS_INC}"
        COMMAND ${CMAKE_COMMAND}
            -DMAP_NAMES="${MAP_NAMES_ARG}"
            -DOUTPUT="${ALL_MAPS_INC}"
            -P "${SCRIPT}"
        DEPENDS
            "${SCRIPT}"
            ${PROCESSED_MAP_FILES}
        COMMENT "Generating map include file"
    )
    add_custom_target(map_includes DEPENDS ${ALL_MAPS_INC})
endfunction()

# List all map files in maps/ - these will be processed by the solver.
# A 4k Atari ROM can hold a maximum of 25 maps.
add_maps(
    mapX1
    mapX2
    mapX3
    mapX4
    mapX5
    mapX6
    mapX7
    mapX8
    mapXS
)

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
            # The redundant dependencies below are due to quirks in CMake.
            # Listing the .inc file forces the binary targets to be updated
            # any time a map source file changes, while the the map_includes
            # target forces the .inc file to be built /before/ any binary
            # targets. Neither is sufficient alone.
            "${CMAKE_CURRENT_BINARY_DIR}/map_includes.inc"
            map_includes
    )

    set(TARGET "binary_${VARIANT}")
    add_custom_target("${TARGET}" DEPENDS "${BIN_FILE}")
    add_dependencies(all_binaries "${TARGET}")
endfunction()

# List all binary variants - these will be subtargets built by "make all".
add_binary(PAL50)
add_binary(PAL60)
add_binary(NTSC)
