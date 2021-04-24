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

#ifndef PUZZLE_
#define PUZZLE_

#include <iostream>
#include <list>
#include <unordered_set>

enum Tile
{
    S, W, R, P, B
};

class Puzzle
{
    public:
        class State
        {
            friend size_t hash_value(const State& state);

            public:
                State(unsigned char px, unsigned char py,
                    unsigned char bx, unsigned char by,
                    unsigned short pf, State* ptr,
                    unsigned char m);
                bool operator<(const State& rhs) const;
                bool operator==(const State& rhs) const;

                void print(std::ostream& out) const;
                bool isFinished() const;
                unsigned char distanceToFinish() const;
                unsigned char distanceFromStart() const;
                std::list<State*> expand();
                State* getParent() const;
                bool hasParent() const;       

            private:
                State* newChild();
                State* movePlayer(int dx, int dy);
                State* moveBlock(int dx, int dy);
        
                State* parent;
                unsigned short pickup_flags; 
                unsigned char player_x;
                unsigned char player_y;
                unsigned char block_x;
                unsigned char block_y;
                unsigned char moves;
        };

        class StatePtr
        {
            friend size_t hash_value(const StatePtr& state);

            public:
                StatePtr(State* ptr);
                bool operator<(const StatePtr& rhs) const;
                bool operator==(const StatePtr& rhs) const;
                State* toPointer() const;

            private:
                State* m_ptr;
        };

        static void init(Tile map[10][16]);
        static void init(std::istream& input);
        static unsigned int solve(std::ostream& out = std::cout);    
        static void printAsm(unsigned int moves_to_finish,
            std::ostream& out = std::cout);

    private:
        static State* getStartState();

        static int map[10][16];
        static unsigned short rmasks[16];
        static unsigned short cmasks[16];

        static unsigned short pickup_start_flags;
        static unsigned char player_start_x;
        static unsigned char player_start_y;
        static unsigned char block_start_x;
        static unsigned char block_start_y;
  
};


namespace std
{
    template<> struct hash<Puzzle::StatePtr>
    {
        size_t operator()(const Puzzle::StatePtr& state) const
        {
            return hash_value(state);
        }
    };
}





#endif
