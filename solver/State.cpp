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

using namespace std;

#include <list>
#include <iostream>
#include "Puzzle.h"



size_t hash_value(const Puzzle::State& state)
{
    size_t result = (unsigned int)(state.pickup_flags);
    result += (unsigned int)(state.player_x) * 37;
    result += (unsigned int)(state.player_y) * 37*37;
    result += (unsigned int)(state.block_x) * 37*37*37;
    result += (unsigned int)(state.block_y) * 37*37*37*37;

    return result;
}



Puzzle::State::State(unsigned char px, unsigned char py,
unsigned char bx, unsigned char by, unsigned short pf,
State* ptr, unsigned char m):
parent(ptr),
pickup_flags(pf),
player_x(px),
player_y(py),
block_x(bx),
block_y(by),
moves(m)
{
    //no code
}


void Puzzle::State::print(ostream& out) const
{
    out << "player (" << (int)player_x
        << "," << (int)player_y << ")\t"
        << "block (" << (int)block_x
        << "," << (int)block_y << ")";
}


bool Puzzle::State::operator==(const State& rhs) const
{
    return (this->player_x == rhs.player_x)
        && (this->player_y == rhs.player_y)
        && (this->block_x == rhs.block_x)
        && (this->block_y == rhs.block_y)
        && (this->pickup_flags == rhs.pickup_flags);
}


bool Puzzle::State::operator<(const State& rhs) const
{
    bool result;

    if(this->moves + this->distanceToFinish() !=
    rhs.moves + rhs.distanceToFinish())
    {
        result = (this->moves + this->distanceToFinish() <
            rhs.moves + rhs.distanceToFinish());
    }
    else if(this->pickup_flags != rhs.pickup_flags)
    {
        result = (this->pickup_flags < rhs.pickup_flags);
    }
    else if(this->player_x != rhs.player_x)
    {
        result = (this->player_x < rhs.player_x);
    }
    else if(this->player_y != rhs.player_y)
    {
        result = (this->player_y < rhs.player_y);
    }
    else if(this->block_x != rhs.block_x)
    {
        result = (this->block_x < rhs.block_x);
    }
    else if(this->block_y != rhs.block_y)
    {
        result = (this->block_y < rhs.block_y);
    }
    else //they're the same
    {
        result = false;
    }

    return result;
}


bool Puzzle::State::hasParent() const
{
    return parent != NULL;
}


Puzzle::State* Puzzle::State::getParent() const
{
    return parent;
}


unsigned char Puzzle::State::distanceFromStart() const
{
    return moves;
}


unsigned char Puzzle::State::distanceToFinish() const
{
    unsigned short rows = 0;
    unsigned short columns = 0;
    unsigned short pickups = pickup_flags;
    unsigned int i = 0;

    while(pickups != 0)
    {
        if(pickups & 1)
        {
            rows |= rmasks[i];
            columns |= cmasks[i];
        }        

        ++i;
        pickups >>= 1;
    }

    unsigned int row_count = 0;
    unsigned int column_count = 0;

    while(rows != 0)
    {
        ++row_count;
        rows >>= 1;
    }

    while(column_count != 0)
    {
        ++column_count;
        columns >>= 1;
    }

    if(row_count < column_count)
    {
        return 2*row_count - 1;
    }
    else
    {
        return 2*column_count - 1;
    }
}


bool Puzzle::State::isFinished() const
{
    return (pickup_flags == 0);
}


vector<unique_ptr<Puzzle::State>> Puzzle::State::expand()
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


std::unique_ptr<Puzzle::State> Puzzle::State::movePlayer(int dx, int dy)
{
    auto newState = newChild();

    int tile = map[newState->player_y + dy][newState->player_x + dx];

    while((tile != -1)
    && !((newState->player_x + dx == newState->block_x)
        && (newState->player_y + dy == newState->block_y)))
    {
        newState->pickup_flags &= ~tile;   

        newState->player_x += dx;
        newState->player_y += dy;

        tile = map[newState->player_y + dy][newState->player_x + dx];
    }

    return newState;
}


std::unique_ptr<Puzzle::State> Puzzle::State::moveBlock(int dx, int dy)
{
    auto newState = newChild();

    int tile = map[newState->block_y + dy][newState->block_x + dx];

    while((tile != -1)
    && !((newState->block_x + dx == newState->player_x)
        && (newState->block_y + dy == newState->player_y)))
    {
        if((tile) && (newState->pickup_flags & tile))
        {
            break;
        }

        newState->block_y += dy;
        newState->block_x += dx;

        tile = map[newState->block_y + dy][newState->block_x + dx];
    }

    return newState;
}


std::unique_ptr<Puzzle::State> Puzzle::State::newChild()
{
    return std::make_unique<State>(player_x, player_y,
        block_x, block_y, pickup_flags, this, moves+1);
}
