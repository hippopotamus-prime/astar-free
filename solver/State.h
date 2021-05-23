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

#ifndef STATE_
#define STATE_

#include <memory>
#include <vector>
#include <array>

class Puzzle;

class State
{
    public:
        State(unsigned char player_x, unsigned char player_y,
            unsigned char block_x, unsigned char block_y,
            unsigned short pickup_flags);

        bool operator==(const State& rhs) const;

        void print(std::ostream& out) const;

        unsigned short getPickupFlags() const
            {return _pickup_flags;}
        unsigned char getPlayerX() const
            {return _player_x;}
        unsigned char getPlayerY() const
            {return _player_y;}
        unsigned char getBlockX() const
            {return _block_x;}
        unsigned char getBlockY() const
            {return _block_y;}
        bool isFinished() const
            {return _pickup_flags == 0;}

        std::array<State, 8> expand(const Puzzle& puzzle) const;

    private:
        friend class StateHash;

        State movePlayer(const Puzzle& puzzle, int dx, int dy) const;
        State moveBlock(const Puzzle& puzzle, int dx, int dy) const;

        std::uint32_t _pickup_flags;
        unsigned char _player_x;
        unsigned char _player_y;
        unsigned char _block_x;
        unsigned char _block_y;
};

struct StateHash
{
    size_t operator() (State state) const;
};

class PathNode
{
    public:
        // Initial state constructor - no parent state.
        explicit PathNode(State initial_state);

        // Constructor for child states.
        PathNode(const PathNode* parent, State state);

        State getState() const
            {return _state;}

        unsigned short distanceToFinish(const Puzzle& puzzle) const;
        unsigned short distanceFromStart() const
            {return _moves;}

        const PathNode* getParent() const
            {return _parent;}
        bool hasParent() const
            {return _parent != nullptr;}
        void setParent(const PathNode* parent);

        using SortKey = std::uint64_t;
        SortKey getSortKey(const Puzzle& puzzle) const;

    private:
        const PathNode* _parent;
        unsigned short _moves;
        State _state;
};

#endif
