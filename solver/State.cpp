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

#include <list>
#include <iostream>
#include "State.h"
#include "Puzzle.h"

using namespace std;

size_t StateHash::operator() (State state) const
{
    std::uint64_t value = state._pickup_flags;
    value <<= 8;
    value += state._player_x;
    value <<= 8;
    value += state._player_y;
    value <<= 8;
    value += state._block_x;
    value <<= 8;
    value += state._block_y;

    std::hash<uint64_t> hasher;
    return hasher(value);
}


State::State(unsigned char player_x, unsigned char player_y,
        unsigned char block_x, unsigned char block_y,
        unsigned short pickup_flags):
    _pickup_flags(pickup_flags),
    _player_x(player_x),
    _player_y(player_y),
    _block_x(block_x),
    _block_y(block_y)
{
}


void State::print(ostream& out) const
{
    out << "player (" << (int) _player_x
        << "," << (int) _player_y << ")\t"
        << "block (" << (int) _block_x
        << "," << (int) _block_y << ")";
}


bool State::operator==(const State& rhs) const
{
    return (_player_x == rhs._player_x)
        && (_player_y == rhs._player_y)
        && (_block_x == rhs._block_x)
        && (_block_y == rhs._block_y)
        && (_pickup_flags == rhs._pickup_flags);
}


array<State, 8> State::expand(const Puzzle& puzzle) const
{
    return array<State, 8>
    {
        moveBlock(puzzle, 0, -1),
        moveBlock(puzzle, -1, 0),
        moveBlock(puzzle, 0, 1),
        moveBlock(puzzle, 1, 0),
        movePlayer(puzzle, 0, -1),
        movePlayer(puzzle, -1, 0),
        movePlayer(puzzle, 0, 1),
        movePlayer(puzzle, 1, 0)
    };
}


State State::movePlayer(const Puzzle& puzzle, int dx, int dy) const
{
    auto new_player_x = _player_x;
    auto new_player_y = _player_y;
    auto new_pickup_flags = _pickup_flags;

    while (true)
    {
        auto candidate_player_x = new_player_x + dx;
        auto candidate_player_y = new_player_y + dy;

        if ((candidate_player_x == _block_x)
        &&  (candidate_player_y == _block_y))
            break;

        auto tile = puzzle.getTile(candidate_player_x, candidate_player_y);
        if (tile == -1)
            break;

        new_pickup_flags &= ~tile;
        new_player_x = candidate_player_x;
        new_player_y = candidate_player_y;
    }

    return State(
        new_player_x, new_player_y,
        _block_x, _block_y,
        new_pickup_flags);
}


State State::moveBlock(const Puzzle& puzzle, int dx, int dy) const
{
    auto new_block_x = _block_x;
    auto new_block_y = _block_y;

    while (true)
    {
        auto candidate_block_x = new_block_x + dx;
        auto candidate_block_y = new_block_y + dy;

        if ((candidate_block_x == _player_x)
        &&  (candidate_block_y == _player_y))
            break;

        auto tile = puzzle.getTile(candidate_block_x, candidate_block_y);
        if (tile == -1)
            break;
        if (_pickup_flags & tile)
            break;

        new_block_x = candidate_block_x;
        new_block_y = candidate_block_y;
    }

    return State(
        _player_x, _player_y,
        new_block_x, new_block_y,
        _pickup_flags);
}


PathNode::PathNode(State state):
    _parent(nullptr),
    _moves(0),
    _state(state)
{
}


PathNode::PathNode(const PathNode* parent, State state):
    _parent(parent),
    _moves(parent->_moves + 1),
    _state(state)
{
}


void PathNode::setParent(const PathNode* parent)
{
    _parent = parent;
    if (parent)
    {
        _moves = parent->_moves + 1;
    }
    else
    {
        _moves = 0;
    }
}


unsigned short PathNode::distanceToFinish(const Puzzle& puzzle) const
{
    // This is the A* heuristic function - it estimates the minimum number
    // of moves to finish the puzzle as either the number of unique rows or
    // columns with pickups present, whichever is smaller. (Given a clear
    // path, you can clear an entire row in one move.)

    unsigned short row_flags = 0;
    unsigned short column_flags = 0;
    unsigned short pickup_flags = _state.getPickupFlags();
    unsigned int i = 0;

    while (pickup_flags != 0)
    {
        if (pickup_flags & 1)
        {
            row_flags |= puzzle.getRowMask(i);
            column_flags |= puzzle.getColumnMask(i);
        }

        ++i;
        pickup_flags >>= 1;
    }

    // TO DO: Use std::popcount when C++20 is available.
#ifdef __GNUC__
    auto row_count = __builtin_popcount(row_flags);
    auto column_count = __builtin_popcount(column_flags);
#else
    unsigned int row_count = 0;
    unsigned int column_count = 0;
    while (row_flags != 0)
    {
        row_count += (row_flags & 1);
        row_flags >>= 1;
    }
    while (column_flags != 0)
    {
        column_count += (column_flags & 1);
        column_flags >>= 1;
    }
#endif

    return std::min(row_count, column_count);
}


PathNode::SortKey PathNode::getSortKey(const Puzzle& puzzle) const
{
    // Pre-compute a value to support fast comparisons with operator<. This
    // makes std::map much faster, but requires that states are immutable.

    // Note that this function will never return 0 since the player and block
    // cannot occupy (0, 0) at the same time.

    SortKey key = _moves + distanceToFinish(puzzle);
    key <<= 16;
    key += _state.getPickupFlags();
    key <<= 8;
    key += _state.getPlayerX();
    key <<= 8;
    key += _state.getPlayerY();
    key <<= 8;
    key += _state.getBlockX();
    key <<= 8;
    key += _state.getBlockY();
    return key;
}
