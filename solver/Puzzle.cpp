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
#include <unordered_map>
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

using KeyedNode = pair<PathNode::SortKey, const PathNode*>;

struct KeyedNodeGreater
{
    bool operator() (const KeyedNode& a, const KeyedNode& b) const
    {
        return a.first > b.first;
    }
};

using KnownSet = unordered_map<State, PathNode, StateHash>;
using OpenSet = vector<KeyedNode>;

void PushOpenState(const Puzzle& puzzle,
    OpenSet& open_states, const PathNode* node_ptr)
{
    auto key = node_ptr->getSortKey(puzzle);
    open_states.emplace_back(key, node_ptr);
    push_heap(open_states.begin(), open_states.end(), KeyedNodeGreater());
}

const PathNode* PopOpenState(OpenSet& open_states)
{
    auto node_ptr = open_states.begin()->second;
    pop_heap(open_states.begin(), open_states.end(), KeyedNodeGreater());
    open_states.pop_back();
    return node_ptr;
}

bool IsValidSpacing(unsigned int spacing)
{
    switch (spacing)
    {
        case 0b000000001:
        case 0b000000101:
        case 0b000010001:
        case 0b000010101:
        case 0b100000001:
        case 0b100010001:
            return true;

        default:
            return false;
    }
}

}

bool Puzzle::init(istream& input)
{
    unsigned int item_count = 0;
    _pickup_start_flags = 0;
    bool have_player = false;
    bool have_block = false;

    memset(_map, 0, sizeof(_map));
    memset(_column_masks, 0, sizeof(_column_masks));
    memset(_row_masks, 0, sizeof(_row_masks));

    unsigned int line_count = 0;
    unsigned int row_count = 0;
    while (!input.eof())
    {
        string line;
        getline(input, line);
        ++line_count;
        string_view line_view = line;

        // Ignore leading whitespace.
        auto content_start = line_view.find_first_not_of(" \t\r");

        // Skip lines that are nothing but whitespace.
        if (content_start == string::npos)
            continue;

        // Ignore comments.
        string_view content_view;
        auto comment_start = line_view.find_first_of(";", content_start);
        if (comment_start == string::npos)
        {
            content_view = line_view.substr(content_start);
        }
        else
        {
            content_view = line_view.substr(content_start,
                comment_start - content_start);
        }

        // Ignore trailing whitespace.
        auto content_last = content_view.find_last_not_of(" \t\r");
        if (content_last != string::npos)
        {
            content_view = content_view.substr(0, content_last + 1);
        }

        // Skip lines that are purely comments.
        if (content_view.empty())
            continue;

        // Confirm each row has the right length.
        if (content_view.size() != 16)
        {
            cerr << "Line " << line_count
                << ": expected 16 characters per row, got "
                << content_view.size() << "\n";
            return false;
        }

        // Parse the row.
        unsigned int item_spacing = 0;
        for (unsigned int i = 0; i < content_view.size(); ++i)
        {
            switch (content_view[i])
            {
                // Wall
                case 'W':
                case '#':
                    _map[row_count][i] = -1;
                    break;

                // Collectible
                case 'R':
                case 'o':
                    _map[row_count][i] = 1 << item_count;
                    _pickup_start_flags |= 1 << item_count;
                    _column_masks[item_count] = 1 << i;
                    _row_masks[item_count++] = 1 << row_count;
                    item_spacing |= 1;
                    if (!IsValidSpacing(item_spacing))
                    {
                        cerr << "Line " << line_count
                            << ": invalid item spacing\n";
                        return false;
                    }
                    break;

                // Player
                case 'P':
                    if (have_player)
                    {
                        cerr << "Line " << line_count
                            << ": duplicate player position\n";
                        return false;
                    }
                    _player_start_x = i;
                    _player_start_y = row_count;
                    have_player = true;
                    break;

                // Block
                case 'B':
                    if (have_block)
                    {
                        cerr << "Line " << line_count
                            << ": duplicate block position\n";
                        return false;
                    }
                    _block_start_x = i;
                    _block_start_y = row_count;
                    have_block = true;
                    break;

                // Empty Space
                case 'S':
                case '.':
                    break;

                default:
                    cerr << "Line " << line_count
                        << ": unexpected character: '"
                        << content_view[i] << "'\n";
                    return false;
            }

            item_spacing <<= 1;
        }

        ++row_count;
    }

    // Check common error conditions.
    if (row_count != 10)
    {
        cerr << "Expected 10 rows, got " << row_count << "\n";
        return false;
    }
    if (!have_player)
    {
        cerr << "No player position in map\n";
        return false;
    }
    if (!have_block)
    {
        cerr << "No block position in map\n";
        return false;
    }

    return true;
}


State Puzzle::makeStartState() const
{
    return State(
        _player_start_x, _player_start_y,
        _block_start_x, _block_start_y,
        _pickup_start_flags);
}


unsigned int Puzzle::solve(ostream& out) const
{
    // Track all known states in a single hash set for fast lookup, with the
    // subset that are open sorted separately. There is an implied subset of
    // closed states consisting of all known states that are not open.
    KnownSet known_set;
    OpenSet open_set;

    auto start_state = makeStartState();
    auto [start_state_it, dummy] = known_set.try_emplace(
        start_state, PathNode(start_state));

    const PathNode* current_node = &start_state_it->second;
    open_set.emplace_back(current_node->getSortKey(*this), current_node);

    while (!current_node->getState().isFinished() && !open_set.empty())
    {
        current_node = PopOpenState(open_set);
        auto current_state = current_node->getState();
        auto successor_states = current_state.expand(*this);

        for (auto state: successor_states)
        {
            if (state == current_state)
                continue;

            auto [it, inserted] = known_set.try_emplace(
                state, PathNode(current_node, state));

            if (inserted)
            {
                // We have a never-before-seen state, so add it.
                auto new_node_ptr = &it->second;
                PushOpenState(*this, open_set, new_node_ptr);
            }
            else
            {
                // This state was already known, but we might have found a
                // shorter path to it. (If not we can discard the new state.)
                auto blocking_node_ptr = &it->second;
                auto move_count = current_node->distanceFromStart() + 1;
                if (move_count < blocking_node_ptr->distanceFromStart())
                {
                    // Update the state to reflect the shorter path - this will
                    // leave an obsolete key in the open set, but expanding it
                    // will have no effect.
                    blocking_node_ptr->setParent(current_node);
                    PushOpenState(*this, open_set, blocking_node_ptr);
                }
            }
        }
    }

    if (open_set.empty())
    {
        out << "Puzzle is unsolveable!";
        return 1;
    }
    else
    {
        stack<const PathNode*> staq;

        staq.push(current_node);
        while (current_node->hasParent())
        {
            current_node = current_node->getParent();
            staq.push(current_node);
        }

        printAsm(staq.size()-1, out);

        out << "    ;Solution\n"
            << "    ;========\n";

        while (!staq.empty())
        {
            out << "    ;";
            staq.top()->getState().print(out);
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
