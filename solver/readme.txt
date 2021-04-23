   _____    _________ __                    _____                 
  /  _  \  /   _____//  |______ _______    /     \ _____  ______  
 /  /_\  \ \_____  \\   __\__  \\_  __ \  /  \ /  \\__  \ \____ \ 
/    |    \/        \|  |  / __ \|  | \/ /    Y    \/ __ \|  |_> >
\____|__  /_______  /|__| (____  /__|    \____|__  (____  /   __/ 
        \/        \/           \/                \/     \/|__|    
  ________                                   __                
 /  _____/  ____   ____   ________________ _/  |_  ___________ 
/   \  ____/ __ \ /    \_/ __ \_  __ \__  \\   __\/  _ \_  __ \
\    \_\  \  ___/|   |  \  ___/|  | \// __ \|  | (  <_> )  | \/
 \______  /\___  >___|  /\___  >__|  (____  /__|  \____/|__|   
        \/     \/     \/     \/           \/                   

Basically how this works is you provide a text file with the desired
map layout, and the program will try to find a solution to it.  If
one exists, it will then output some assembly code that can be included
in the game, along with the solution.

Usage is "asgen <input file> <output file>".  You can specify "-"
instead for console input / output.

The input file should look like sample_input.txt.  Only the first 160
characters will be read.

W    wall
.    space
o    collectable
P    player start position
B    block start position

The top and bottom lines must be entirely walls (the game will ignore
them, but the solution finder won't).

Collectables are subject to the Atari's hardware contraints.  Only
these spacings are valid (. can be any other symbol):

o
o.o
o...o
o.......o
o.o.o
o...o...o


Source is GPL'd and includes a project file for Dev-C++.  It might be
a bit weird as I was experimenting with some things...