```
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
```

## Usage
Basically how this works is you provide a text file with the desired
map layout, and the program will try to find a solution to it. If
one exists, it will then output some assembly code that can be included
in the game, along with the solution.

Usage is:
```
asgen INPUTFILE OUTPUTFILE
```

You can specify either a file name or "-" for console input / output.

See the *maps* directory for example input files. The meaning of each
character in the input is described below. Only the first 160
characters (not counting line endings) from the input file will be read.

Character | Meaning
--------- | -------
W|Wall
.|Empty space
o|Collectable item
P|Player start position
B|Block start position

The top and bottom lines must be entirely walls (the game will ignore
them, but the solution finder won't).

Collectables are subject to the Atari's hardware contraints. Only
the spacings below are valid.  (The `.` can be any other symbol.)
```
o
o.o
o...o
o.......o
o.o.o
o...o...o
```
