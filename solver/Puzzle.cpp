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
#include <set>
#include <unordered_set>
#include "Puzzle.h"

using namespace std;

int Puzzle::map[10][16];
unsigned short Puzzle::rmasks[16];
unsigned short Puzzle::cmasks[16];

unsigned short Puzzle::pickup_start_flags;
unsigned char Puzzle::player_start_x;
unsigned char Puzzle::player_start_y;
unsigned char Puzzle::block_start_x;
unsigned char Puzzle::block_start_y;

const string NUSIZ_OFF          = "5";
const string NUSIZ_ONE          = "0";
const string NUSIZ_TWO_CLOSE    = "1";
const string NUSIZ_TWO_MED      = "2";
const string NUSIZ_TWO_FAR      = "4";
const string NUSIZ_THREE_CLOSE  = "3";
const string NUSIZ_THREE_MED    = "6";

void Puzzle::init(istream& input)
{
    unsigned int pickups = 0;
    pickup_start_flags = 0;

    unsigned int i, j;
    unsigned int char_count = 0;

    while(char_count < 160)
    {
        char c;

        input >> c;

        i = char_count % 16;
        j = char_count / 16;

        switch(c)
        {
            case 'W':
                map[j][i] = -1;
                ++char_count;
                break;
            case 'R':
            case 'o':
                map[j][i] = 1 << pickups;
                pickup_start_flags |= 1 << pickups;
                rmasks[pickups] = 1 << i;
                cmasks[pickups++] = 1 << j;
                ++char_count;
                break;
            case 'P':
                player_start_x = i;
                player_start_y = j;
                ++char_count;
                break;
            case 'B':
                block_start_x = i;
                block_start_y = j;
                ++char_count;
                break;
            case 'S':
            case '.':
                ++char_count;
                break;
        }    
    }
}

void Puzzle::init(Tile input[10][16])
{
    unsigned int pickups = 0;
    pickup_start_flags = 0;

    for(unsigned int i = 0; i < 16; ++i)
    {
        for(unsigned int j = 0; j < 10; ++j)
        {
            switch(input[j][i])
            {
                case W:
                    map[j][i] = -1;
                    break;
                case R:
                    map[j][i] = 1 << pickups;
                    pickup_start_flags |= 1 << pickups;
                    rmasks[pickups] = 1 << i;
                    cmasks[pickups++] = 1 << j;
                    break;
                case P:
                    player_start_x = i;
                    player_start_y = j;
                    break;
                case B:
                    block_start_x = i;
                    block_start_y = j;
                    break;
                case S:
                    break;
            }
        }
    }
}


Puzzle::State* Puzzle::getStartState()
{
    State* start = new State(player_start_x, player_start_y,
                       block_start_x, block_start_y,
                       pickup_start_flags, NULL, 0);

    return start;
}


unsigned int Puzzle::solve(ostream& out)
{
    unordered_set<StatePtr> closed;
    set<StatePtr> open;
    State* current = getStartState();
    unsigned char max_moves = 0;

    open.insert(current);

    do
    {
        current = (*open.begin()).toPointer();
        open.erase(open.begin());
        closed.insert(current);

        if(current->distanceFromStart() > max_moves)
        {
            max_moves = current->distanceFromStart();
            //cout << (int)max_moves << endl;
        }

        list<State*> more = current->expand();
        
        for(list<State*>::iterator it = more.begin();
        it != more.end(); ++it)
        {
            if((closed.find(*it) == closed.end())
            && (open.find(*it) == open.end()))
            {
                open.insert(*it);
            }
            else
            {
                delete *it;
            }
        }
    }
    while(!current->isFinished() && !open.empty());

    if(open.empty())
    {
        out << "Puzzle is unsolveable!";
    }
    else
    {
        stack<State*> staq;

        staq.push(current);
        while(current->hasParent())
        {
            current = current->getParent();
            staq.push(current);
        }

        printAsm(staq.size()-1, out);

        out << "    ;Solution\n"
            << "    ;========\n";

        while(!staq.empty())
        {
            out << "    ;";
            staq.top()->print(out);
            out << "\n";
            staq.pop();
        }
    }


    //Clean up......
    for (auto& state_ptr: open)
    {
        delete state_ptr.toPointer();
    }

    for (auto& state_ptr: closed)
    {
        delete state_ptr.toPointer();
    } 

    return 0;
}



void Puzzle::printAsm(unsigned int moves_to_finish, ostream& out)
{
    int i, j;

    out << "    ;Map file for AStar\n"
        << "    ;==================\n\n";

    for(j = 8; j >= 1; --j)
    {
        out << "    .byte %";

        for(i = 0; i < 8; ++i)
        {
            if(map[j][i] == -1)
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
            if(map[j][i] == -1)
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
            if(map[j][i] > 0)
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
        << (int) player_start_x
        << ","
        << (int) (9 - player_start_y)
        << "\n";

    out << "    COORD "
        << (int) block_start_x
        << ","
        << (int) ( 9 - block_start_y)
        << "\n\n";

    out << "    .byte $"
        << moves_to_finish / 10
        << moves_to_finish % 10
        << "\n\n";
}
