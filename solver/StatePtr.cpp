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

#include <iostream>     //not sure why these are needed here,
#include <list>         //they're included in Puzzle.h
#include "Puzzle.h"


size_t hash_value(const Puzzle::StatePtr& state)
{
    return hash_value(*(state.m_ptr));
}


Puzzle::StatePtr::StatePtr(Puzzle::State* ptr) :
m_ptr(ptr)
{
    //no code
}


bool Puzzle::StatePtr::operator==(const StatePtr& rhs) const
{
    return *m_ptr == *(rhs.m_ptr);
}


bool Puzzle::StatePtr::operator<(const StatePtr& rhs) const
{   
    return *m_ptr < *(rhs.m_ptr);
}


Puzzle::State* Puzzle::StatePtr::toPointer() const
{   
    return m_ptr;
}
