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
    size_t result = (unsigned int)(state.pickup_flags);
    result += (unsigned int)(state.player_x) * 37;
    result += (unsigned int)(state.player_y) * 37*37;
    result += (unsigned int)(state.block_x) * 37*37*37;
    result += (unsigned int)(state.block_y) * 37*37*37*37;

    return result;
}


State::State(const Puzzle& _puzzle,
        unsigned char px, unsigned char py,
        unsigned char bx, unsigned char by, unsigned short pf):
    puzzle(_puzzle),
    parent(nullptr),
    pickup_flags(pf),
    player_x(px),
    player_y(py),
    block_x(bx),
    block_y(by),
    moves(0)
{
    updateValueForComparison();
}


State::State(const State* parent_ptr,
        unsigned char px, unsigned char py,
        unsigned char bx, unsigned char by, unsigned short pf):
    puzzle(parent_ptr->puzzle),
    parent(parent_ptr),
    pickup_flags(pf),
    player_x(px),
    player_y(py),
    block_x(bx),
    block_y(by),
    moves(parent_ptr->moves + 1)
{
    updateValueForComparison();
}


void State::print(ostream& out) const
{
    out << "player (" << (int)player_x
        << "," << (int)player_y << ")\t"
        << "block (" << (int)block_x
        << "," << (int)block_y << ")";
}


bool State::operator==(const State& rhs) const
{
    return (this->player_x == rhs.player_x)
        && (this->player_y == rhs.player_y)
        && (this->block_x == rhs.block_x)
        && (this->block_y == rhs.block_y)
        && (this->pickup_flags == rhs.pickup_flags);
}


bool State::hasParent() const
{
    return parent != nullptr;
}


const State* State::getParent() const
{
    return parent;
}


unsigned char State::distanceFromStart() const
{
    return moves;
}


unsigned char State::distanceToFinish() const
{
    // This is the A* heuristic function - it estimates the minimum number
    // of moves to finish the puzzle as either the number of unique rows or
    // columns with pickups present, whichever is smaller. (Given a clear
    // path, you can clear an entire row in one move.)

    unsigned short row_flags = 0;
    unsigned short column_flags = 0;
    unsigned short pickups = pickup_flags;
    unsigned int i = 0;

    while (pickups != 0)
    {
        if (pickups & 1)
        {
            row_flags |= puzzle.getRowMask(i);
            column_flags |= puzzle.getColumnMask(i);
        }

        ++i;
        pickups >>= 1;
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
    return (pickup_flags == 0);
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
    auto new_player_x = player_x;
    auto new_player_y = player_y;
    auto new_pickup_flags = pickup_flags;

    while (true)
    {
        auto candidate_player_x = new_player_x + dx;
        auto candidate_player_y = new_player_y + dy;

        if ((candidate_player_x == block_x)
        &&  (candidate_player_y == block_y))
            break;

        auto tile = puzzle.getTile(candidate_player_x, candidate_player_y);
        if (tile == -1)
            break;

        new_pickup_flags &= ~tile;
        new_player_x = candidate_player_x;
        new_player_y = candidate_player_y;
    }

    return std::make_unique<State>(this,
        new_player_x, new_player_y,
        block_x, block_y,
        new_pickup_flags);
}


std::unique_ptr<State> State::moveBlock(int dx, int dy) const
{
    auto new_block_x = block_x;
    auto new_block_y = block_y;

    while (true)
    {
        auto candidate_block_x = new_block_x + dx;
        auto candidate_block_y = new_block_y + dy;

        if ((candidate_block_x == player_x)
        &&  (candidate_block_y == player_y))
            break;

        auto tile = puzzle.getTile(candidate_block_x, candidate_block_y);
        if (tile == -1)
            break;
        if (pickup_flags & tile)
            break;

        new_block_x = candidate_block_x;
        new_block_y = candidate_block_y;
    }

    return std::make_unique<State>(this,
        player_x, player_y,
        new_block_x, new_block_y,
        pickup_flags);
}


void State::updateValueForComparison()
{
    // Pre-compute a value to support fast comparisons with operator<. This
    // makes std::set much faster, but requires that states are immutable.

    value_for_comparison = moves + distanceToFinish();
    value_for_comparison <<= 16;
    value_for_comparison += pickup_flags;
    value_for_comparison <<= 8;
    value_for_comparison += player_x;
    value_for_comparison <<= 8;
    value_for_comparison += player_y;
    value_for_comparison <<= 8;
    value_for_comparison += block_x;
    value_for_comparison <<= 8;
    value_for_comparison += block_y;
}
