#ifndef __STATE__
#define __STATE__

class State
{
    public:
        bool isFinished();
        unsigned char distanceToFinish();
        list<State*> expand();

    private:
        State* newChild();

        State* parent;
        unsigned short pickup_flags; 
        unsigned char player_x;
        unsigned char player_y;
        unsigned char block_x;
        unsigned char block_y;
        unsigned char moves;
}

#endif
