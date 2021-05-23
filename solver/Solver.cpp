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

#include <iostream>
#include <fstream>
#include <string.h>
#include "Puzzle.h"

using namespace std;

int main(int argc, char *argv[])
{
    ifstream input;
    ofstream output;
    
    istream* in = &cin;
    ostream* out = &cout;

    if (argc != 3)
    {
        cout << "Usage is \"asgen [input file] [output file]\"\n"
             << "Use \"-\" for console input / output."
             << endl;
        return 1;
    }

    if (strcmp(argv[2], "-") != 0)
    {
        output.open(argv[2]);

        if (output.fail())
        {
            cerr << "Could not open the file \""
                 << argv[2] << "\" "
                 << "for output.\n";
            return 1;
        }

        out = &output;
    }

    if (strcmp(argv[1], "-") != 0)
    {
        input.open(argv[1]);

        if (input.fail())
        {
            cerr << "Could not open the file \""
                 << argv[1] << "\" "
                 << "for input.\n";
            return 1;
        }

        in = &input;
    }

    Puzzle puzzle;
    if (puzzle.init(*in))
    {
        return puzzle.solve(*out);
    }
    else
    {
        return 1;
    }
}
