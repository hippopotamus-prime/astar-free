/****************************************************************************
** AStar Map Generator
** Copyright 2005 Aaron Curtis
** 
** This file is part of AStar.
** 
** AStar is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 3 of the License, or
** (at your option) any later version.
** 
** AStar is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
** 
** You should have received a copy of the GNU General Public License
** along with AStar; if not, see <https://www.gnu.org/licenses/>.
****************************************************************************/

#ifndef PUZZLE_
#define PUZZLE_

#include <iostream>
#include <memory>

class State;

constexpr unsigned int MAP_HEIGHT = 10;
constexpr unsigned int MAP_WIDTH = 16;
constexpr unsigned int MAX_PICKUP_COUNT = (3 * (MAP_HEIGHT - 2));

class Puzzle
{
    public:
        bool init(std::istream& input);
        unsigned int solve(std::ostream& out = std::cout) const;
        void printAsm(unsigned int moves_to_finish,
            std::ostream& out = std::cout) const;

        int getTile(unsigned int x, unsigned int y) const
            {return _map[y][x];}
        unsigned short getRowMask(unsigned int index) const
            {return _row_masks[index];}
        unsigned short getColumnMask(unsigned int index) const
            {return _column_masks[index];}

    private:
        State makeStartState() const;

        int _map[MAP_HEIGHT][MAP_WIDTH];
        unsigned short _row_masks[MAX_PICKUP_COUNT];
        unsigned short _column_masks[MAX_PICKUP_COUNT];

        unsigned short _pickup_start_flags;
        unsigned char _player_start_x;
        unsigned char _player_start_y;
        unsigned char _block_start_x;
        unsigned char _block_start_y;
};

#endif
