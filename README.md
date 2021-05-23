# AStar
> Possibly the most challenging puzzle game ever created for the Atari 2600

![Title Screen](https://i.imgur.com/XlMIl1x.png)
![Level 1](https://i.imgur.com/YmA8UBU.png)
![Level 6](https://i.imgur.com/U2s57Z2.png)
![Level 25](https://i.imgur.com/giwChUF.png)

## About
**AStar** is a puzzle game for the Atari 2600 featuring colorful graphics
and a unique play mechanic. You control a character ("Bob") who must navigate
a series of levels to collect items. *Bob has no relation to any character in
any other game.*

* **The goal**: Collect all the items on each level. Cherries, pretzels,
ice cream cones, roses, and more! To win the game you must complete each level
in the minimum number of moves.
* **The catch**: You can only move in straight lines and you can't stop unless
you run into a wall. Though to help, you can also control a block ("Alan") to
influence your movement.

The game will count your moves on each level and change the color of the
counter if you go too high. But feel free to keep playing or skip to a
different level. Have fun!

The name AStar comes from an old calculator game
[DStar](https://www.ticalc.org/archives/files/fileinfo/19/1989.html),
which inspired the puzzle mechanic. Coincidentally, the game is also a good
use case for the [A*](https://en.wikipedia.org/wiki/A*_search_algorithm)
pathfinding algorithm.

## Cartridges
Want a copy on a real physical cartridge? Get it from
[Atari Age](https://atariage.com/store/index.php?l=product_detail&p=821)!

The cartridge includes **24 unique levels** that are not present in the
GitHub version of the game. The 8 levels in the GitHub version were created
specifically for the open source release and likewise do not appear in the
cartridge version.

## Controls
Input|Action
-----|------
Joystick|Move the player or block
Fire Button|Switch control between the player and block
Left Toggle Switch|Undo the last move
Right Toggle Switch|Turn the fade effect between levels on or off
Reset|Restart the current level
Select|Skip to the next level
Reset + Select|Return to the title screen

## AtariVox Support
The game has some limited support for the
[AtariVox](https://atariage.com/store/index.php?l=product_detail&p=1045).
There's no speech, but the game uses the module's memory card to remember which
levels have been completed in the minimum number of moves. Each completed level
is shown with a dot at the bottom of the screen.

## Map Solver
The project includes a tool to find an optimal solution for each level using
the A* algorithm. Levels are written as plain text maps and the tool generates
assembly source with solutions as comments. See solver/README.md for details.

## Building
Use CMake to build the game.

The map solver requires a C++17 compiler and the assembly source for the game
was written for [DASM](https://github.com/dasm-assembler/dasm). If DASM isn't
installed in a standard path, use DASM_ROOT to tell CMake which directory to
find it in.

```
mkdir build
cd build
cmake -DDASM_ROOT=/some/directory ..
make -j $(nproc)
```
