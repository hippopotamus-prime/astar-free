#ifndef STATE_
#define STATE_

#include <memory>
#include <vector>

class Puzzle;

class State
{
    friend size_t hash_value(const State& state);

    public:
        State(const Puzzle& puzzle,
            unsigned char px, unsigned char py,
            unsigned char bx, unsigned char by,
            unsigned short pf,
            const State* parent_ptr,
            unsigned char m);
        bool operator<(const State& rhs) const;
        bool operator==(const State& rhs) const;

        void print(std::ostream& out) const;
        bool isFinished() const;
        unsigned char distanceToFinish() const;
        unsigned char distanceFromStart() const;
        std::vector<std::unique_ptr<State>> expand() const;
        const State* getParent() const;
        bool hasParent() const;       

    private:
        std::unique_ptr<State> newChild() const;
        std::unique_ptr<State> movePlayer(int dx, int dy) const;
        std::unique_ptr<State> moveBlock(int dx, int dy) const;

        const Puzzle& puzzle;
        const State* parent;
        unsigned short pickup_flags;
        unsigned char player_x;
        unsigned char player_y;
        unsigned char block_x;
        unsigned char block_y;
        unsigned char moves;
};

#endif
