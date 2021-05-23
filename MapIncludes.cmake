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
