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

#include <iostream>
#include <string>
#include <stack>
#include <unordered_set>
#include <cstring>
#include <algorithm>
#include "Puzzle.h"
#include "State.h"

using namespace std;

const string NUSIZ_OFF          = "5";
const string NUSIZ_ONE          = "0";
const string NUSIZ_TWO_CLOSE    = "1";
const string NUSIZ_TWO_MED      = "2";
const string NUSIZ_TWO_FAR      = "4";
const string NUSIZ_THREE_CLOSE  = "3";
const string NUSIZ_THREE_MED    = "6";

namespace
{

struct StatePtrEqual
{
    bool operator() (const unique_ptr<State>& p1,
        const unique_ptr<State>& p2) const
    {
        return *p1 == *p2;
    }
};

struct StatePtrHash
{
    size_t operator() (const unique_ptr<State>& ptr) const
    {
        return hash_value(*ptr);
    }
};

using StatePair = pair<State::SortKey, const State*>;

struct StatePairGreater
{
    bool operator() (const StatePair& a, const StatePair& b) const
    {
        return a.first > b.first;
    }
};

using KnownSet = unordered_set<unique_ptr<State>, StatePtrHash, StatePtrEqual>;
using OpenSet = vector<StatePair>;

void PushOpenState(OpenSet& open_states, const State* state_ptr)
{
    auto key = state_ptr->getSortKey();
    open_states.emplace_back(key, state_ptr);
    push_heap(open_states.begin(), open_states.end(), StatePairGreater());
}

const State* PopOpenState(OpenSet& open_states)
{
    auto state_ptr = open_states.begin()->second;
    pop_heap(open_states.begin(), open_states.end(), StatePairGreater());
    open_states.pop_back();
    return state_ptr;
}

}

void Puzzle::init(istream& input)
{
    unsigned int pickups = 0;
    _pickup_start_flags = 0;

    unsigned int i, j;
    unsigned int char_count = 0;

    memset(_map, 0, sizeof(_map));
    memset(_column_masks, 0, sizeof(_column_masks));
    memset(_row_masks, 0, sizeof(_row_masks));

    while(char_count < 160)
    {
        char c;

        input >> c;

        i = char_count % 16;
        j = char_count / 16;

        switch(c)
        {
            // Wall
            case 'W':
                _map[j][i] = -1;
                ++char_count;
                break;

            // Collectible
            case 'R':
            case 'o':
                _map[j][i] = 1 << pickups;
                _pickup_start_flags |= 1 << pickups;
                _column_masks[pickups] = 1 << i;
                _row_masks[pickups++] = 1 << j;
                ++char_count;
                break;

            // Player
            case 'P':
                _player_start_x = i;
                _player_start_y = j;
                ++char_count;
                break;

            // Block
            case 'B':
                _block_start_x = i;
                _block_start_y = j;
                ++char_count;
                break;

            // Empty Space
            case 'S':
            case '.':
                ++char_count;
                break;
        }    
    }
}


std::unique_ptr<State> Puzzle::makeStartState() const
{
    return std::make_unique<State>(*this,
        _player_start_x, _player_start_y,
        _block_start_x, _block_start_y,
        _pickup_start_flags);
}


unsigned int Puzzle::solve(ostream& out) const
{
    // Track all known states in a single hash set for fast lookup, with the
    // subset that are open sorted separately. There is an implied subset of
    // closed states consisting of all known states that are not open.
    KnownSet known_states;
    OpenSet open_states;

    auto [start_state_it, dummy] = known_states.insert(makeStartState());
    const State* start_state = start_state_it->get();
    open_states.emplace_back(start_state->getSortKey(), start_state);

    const State* current_state;
    do
    {
        current_state = PopOpenState(open_states);
        auto successor_states = current_state->expand();

        for (auto& state_ptr: successor_states)
        {
            auto [it, inserted] = known_states.insert(std::move(state_ptr));
            if (inserted)
            {
                // We have a never-before-seen state, so add it.
                auto new_state_ptr = it->get();
                PushOpenState(open_states, new_state_ptr);
            }
            else
            {
                // This state was already known, but we might have found a
                // shorter path to it. (If not we can discard the new state.)
                auto blocking_state_ptr = it->get();
                if (state_ptr->distanceFromStart() <
                    blocking_state_ptr->distanceFromStart())
                {
                    // Update the state to reflect the shorter path - this will
                    // leave an obsolete key in the open set, but expanding it
                    // will have no effect.
                    blocking_state_ptr->setParent(state_ptr->getParent());
                    PushOpenState(open_states, blocking_state_ptr);
                }
            }
        }
    }
    while (!current_state->isFinished() && !open_states.empty());

    if (open_states.empty())
    {
        out << "Puzzle is unsolveable!";
        return 1;
    }
    else
    {
        stack<const State*> staq;

        staq.push(current_state);
        while (current_state->hasParent())
        {
            current_state = current_state->getParent();
            staq.push(current_state);
        }

        printAsm(staq.size()-1, out);

        out << "    ;Solution\n"
            << "    ;========\n";

        while (!staq.empty())
        {
            out << "    ;";
            staq.top()->print(out);
            out << "\n";
            staq.pop();
        }
        return 0;
    }
}


void Puzzle::printAsm(unsigned int moves_to_finish, ostream& out) const
{
    int i, j;

    out << "    ;Map file for AStar\n"
        << "    ;==================\n\n";

    for(j = 8; j >= 1; --j)
    {
        out << "    .byte %";

        for(i = 0; i < 8; ++i)
        {
            if(_map[j][i] == -1)
            {
                out << "1";
            }
            else
            {
                out << "0";
            }
        }

        out << ",%";

        for(i = 8; i < 16; ++i)
        {
            if(_map[j][i] == -1)
            {
                out << "1";
            }
            else
            {
                out << "0";
            }
        }

        out << "\n";
    }

    out << "\n";

    int pickups_per_line;
    int pickup_x[3] = {0, 0, 0};
    bool error;

    for(j = 8; j >= 1; --j)
    {
        pickup_x[0] = 0;
        pickups_per_line = 0;
        error = false;

        for(i = 0; i < 16; ++i)
        {
            if(_map[j][i] > 0)
            {
                if(pickups_per_line < 3)
                {
                    pickup_x[pickups_per_line++] = i;
                }
                else
                {
                    out << "Error: too many pickups!  Max is 3.";
                    error = true;
                    break;
                }
            }
        }

        if(!error)
        {
            out << "    PICKUP "
                << pickup_x[0] << ",";

            if(pickups_per_line == 1)
            {
                out << NUSIZ_ONE;
            }
            else if(pickups_per_line == 2)
            {
                if(pickup_x[1] - pickup_x[0] == 2)
                {
                    out << NUSIZ_TWO_CLOSE;
                }
                else if(pickup_x[1] - pickup_x[0] == 4)
                {
                    out << NUSIZ_TWO_MED;
                }
                else if(pickup_x[1] - pickup_x[0] == 8)
                {
                    out << NUSIZ_TWO_FAR;
                }
                else
                {
                    out << "Error: pickups improperly spaced! "
                        << "Must be 2, 4, or 8 wide.";
                }
            }
            else if(pickups_per_line == 3)
            {
                if(pickup_x[2] - pickup_x[1] ==
                pickup_x[1] - pickup_x[0])
                {
                    if(pickup_x[1] - pickup_x[0] == 2)
                    {
                        out << NUSIZ_THREE_CLOSE;
                    }
                    else if(pickup_x[1] - pickup_x[0] == 4)
                    {
                        out << NUSIZ_THREE_MED;
                    }
                    else
                    {
                        out << "Error: pickups improperly spaced! "
                            << "Must be 2 or 4 wide.";
                    }
                }
                else
                {
                    out << "Error: pickups spaced unevenly!";
                }
            }
            else
            {
                out << NUSIZ_OFF;
            }
        }

        out << "\n";
    }


    out << "\n"
        << "    COORD "
        << (int) _player_start_x
        << ","
        << (int) (9 - _player_start_y)
        << "\n";

    out << "    COORD "
        << (int) _block_start_x
        << ","
        << (int) ( 9 - _block_start_y)
        << "\n\n";

    out << "    .byte $"
        << moves_to_finish / 10
        << moves_to_finish % 10
        << "\n\n";
}
