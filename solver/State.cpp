/****************************************************************************
** AStar Map Generator
** Copyright 2005 Aaron Curtis
** 
** This file is part of the AStar Map Generator.
** 
** ASGen is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
** 
** ASGen is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
** 
** You should have received a copy of the GNU General Public License
** along with ASGen; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
****************************************************************************/

#include <list>
#include <iostream>
#include "State.h"
#include "Puzzle.h"

using namespace std;

size_t hash_value(const State& state)
{
    size_t result = (unsigned int)(state._pickup_flags);
    result += (unsigned int)(state._player_x) * 37;
    result += (unsigned int)(state._player_y) * 37*37;
    result += (unsigned int)(state._block_x) * 37*37*37;
    result += (unsigned int)(state._block_y) * 37*37*37*37;

    return result;
}


State::State(const Puzzle& puzzle,
        unsigned char player_x, unsigned char player_y,
        unsigned char block_x, unsigned char block_y,
        unsigned short pickup_flags):
    _puzzle(puzzle),
    _parent(nullptr),
    _pickup_flags(pickup_flags),
    _player_x(player_x),
    _player_y(player_y),
    _block_x(block_x),
    _block_y(block_y),
    _moves(0)
{
}


State::State(const State* parent_ptr,
        unsigned char player_x, unsigned char player_y,
        unsigned char block_x, unsigned char block_y,
        unsigned short pickup_flags):
    _puzzle(parent_ptr->_puzzle),
    _parent(parent_ptr),
    _pickup_flags(pickup_flags),
    _player_x(player_x),
    _player_y(player_y),
    _block_x(block_x),
    _block_y(block_y),
    _moves(parent_ptr->_moves + 1)
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


bool State::hasParent() const
{
    return _parent != nullptr;
}


const State* State::getParent() const
{
    return _parent;
}


unsigned char State::distanceFromStart() const
{
    return _moves;
}


unsigned char State::distanceToFinish() const
{
    // This is the A* heuristic function - it estimates the minimum number
    // of moves to finish the puzzle as either the number of unique rows or
    // columns with pickups present, whichever is smaller. (Given a clear
    // path, you can clear an entire row in one move.)

    unsigned short row_flags = 0;
    unsigned short column_flags = 0;
    unsigned short pickup_flags = _pickup_flags;
    unsigned int i = 0;

    while (pickup_flags != 0)
    {
        if (pickup_flags & 1)
        {
            row_flags |= _puzzle.getRowMask(i);
            column_flags |= _puzzle.getColumnMask(i);
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


bool State::isFinished() const
{
    return (_pickup_flags == 0);
}


vector<unique_ptr<State>> State::expand() const
{
    vector<unique_ptr<State>> new_states;

    new_states.push_back(moveBlock(0, -1));
    new_states.push_back(moveBlock(-1, 0));
    new_states.push_back(moveBlock(0, 1));
    new_states.push_back(moveBlock(1, 0));

    new_states.push_back(movePlayer(0, -1));
    new_states.push_back(movePlayer(-1, 0));
    new_states.push_back(movePlayer(0, 1));
    new_states.push_back(movePlayer(1, 0));

    return new_states;
}


std::unique_ptr<State> State::movePlayer(int dx, int dy) const
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

        auto tile = _puzzle.getTile(candidate_player_x, candidate_player_y);
        if (tile == -1)
            break;

        new_pickup_flags &= ~tile;
        new_player_x = candidate_player_x;
        new_player_y = candidate_player_y;
    }

    return std::make_unique<State>(this,
        new_player_x, new_player_y,
        _block_x, _block_y,
        new_pickup_flags);
}


std::unique_ptr<State> State::moveBlock(int dx, int dy) const
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

        auto tile = _puzzle.getTile(candidate_block_x, candidate_block_y);
        if (tile == -1)
            break;
        if (_pickup_flags & tile)
            break;

        new_block_x = candidate_block_x;
        new_block_y = candidate_block_y;
    }

    return std::make_unique<State>(this,
        _player_x, _player_y,
        new_block_x, new_block_y,
        _pickup_flags);
}


State::SortKey State::getSortKey() const
{
    // Pre-compute a value to support fast comparisons with operator<. This
    // makes std::map much faster, but requires that states are immutable.

    // Note that this function will never return 0 since the player and block
    // cannot occupy (0, 0) at the same time.

    SortKey key = _moves + distanceToFinish();
    key <<= 16;
    key += _pickup_flags;
    key <<= 8;
    key += _player_x;
    key <<= 8;
    key += _player_y;
    key <<= 8;
    key += _block_x;
    key <<= 8;
    key += _block_y;
    return key;
}
