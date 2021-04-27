#ifndef STATE_
#define STATE_

#include <memory>
#include <vector>

class Puzzle;

class State
{
    friend size_t hash_value(const State& state);

    public:
        // Initial state constructor - no parent state.
        State(const Puzzle& puzzle,
            unsigned char player_x, unsigned char player_y,
            unsigned char block_x, unsigned char block_y,
            unsigned short pickup_flags);

        // Constructor for child states.
        State(const State* parent_ptr,
            unsigned char player_x, unsigned char player_y,
            unsigned char block_x, unsigned char block_y,
            unsigned short pickup_flags);

        bool operator<(const State& rhs) const
            {return _value_for_comparison < rhs._value_for_comparison;}
        bool operator==(const State& rhs) const;

        void print(std::ostream& out) const;
        bool isFinished() const;
        unsigned char distanceToFinish() const;
        unsigned char distanceFromStart() const;
        std::vector<std::unique_ptr<State>> expand() const;
        const State* getParent() const;
        bool hasParent() const;       

    private:
        std::unique_ptr<State> movePlayer(int dx, int dy) const;
        std::unique_ptr<State> moveBlock(int dx, int dy) const;
        void updateValueForComparison();

        const Puzzle& _puzzle;
        const State* _parent;
        unsigned long long _value_for_comparison;
        unsigned short _pickup_flags;
        unsigned char _player_x;
        unsigned char _player_y;
        unsigned char _block_x;
        unsigned char _block_y;
        unsigned char _moves;
};

#endif
