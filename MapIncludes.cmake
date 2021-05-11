# Script to write an include file for DASM given a list of map names.
# The last map is always treated as a secret.

list(LENGTH MAP_NAMES MAP_COUNT)
math(EXPR NORMAL_MAP_COUNT "${MAP_COUNT} - 1")
file(WRITE "${OUTPUT}" "LEVELS equ ${NORMAL_MAP_COUNT}\n")

list(SUBLIST MAP_NAMES 0 ${NORMAL_MAP_COUNT} NORMAL_MAP_NAMES)
list(GET MAP_NAMES ${NORMAL_MAP_COUNT} SECRET_MAP_NAME)

file(APPEND "${OUTPUT}" "    include \"maps/title.asm\"\n")
foreach(NAME ${NORMAL_MAP_NAMES})
    file(APPEND "${OUTPUT}" "    include \"maps/${NAME}.asm\"\n")
endforeach()
file(APPEND "${OUTPUT}" "    include \"maps/end.asm\"\n")
file(APPEND "${OUTPUT}" "    include \"maps/${SECRET_MAP_NAME}.asm\"\n")
