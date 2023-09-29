#include <fstream>
#include <vector>
#include <unordered_set>
#include <unordered_map>
#include <queue>

using namespace std;

int n, m;

class table {
public:
    vector<int> tiles;
    int h = 0;
    int free;
    table(vector<int> tiles_in) {
        tiles = tiles_in;
        for (int i = 0; i < n * m; i++) {
            if (tiles[i]) {
                h += abs(i / m - (tiles[i] - 1) / m) + abs(i % m - (tiles[i] - 1) % m);
            }
            else {
                free = i;
            }
        }
    }
    bool hasMove(int direction) {
        switch (direction) {
        case 0: return free % m != m - 1;
        case 1: return free / m != n - 1;
        case 2: return free % m != 0;
        case 3: return free / m != 0;
        }
    }
    int movedTile(int direction) {
        switch (direction) {
        case 0: return free + 1;
        case 1: return free + m;
        case 2: return free - 1;
        case 3: return free - m;
        }
    }
    table move(int direction) {
        vector<int> tiles_moved(tiles);
        swap(tiles_moved[free], tiles_moved[movedTile(direction)]);
        table returnTable(tiles_moved);
        return returnTable;
    }

    bool operator==(const table& other) const {
        return tiles == other.tiles;
    }
};

struct tableHash {
    std::size_t operator()(table const& tableHashed) const {
        std::size_t seed = n * m;
        for (int i = 0; i < n * m; i++)
            seed ^= tableHashed.tiles[i] + 0x9e3779b9 + (seed << 6) + (seed >> 2);
        return seed;
    }
};

struct tableGreater {
    bool operator()(pair<int, table> const& lhs, pair<int, table> const& rhs) {
        return lhs.first > rhs.first;
    }
};

int main() {
    ifstream fin("input.txt");
    ofstream fout("output.txt");
    fin >> n >> m;
    vector<int> tiles_in(n * m);
    for (int i = 0; i < n * m; i++) {
        fin >> tiles_in[i];
    }
    table start(tiles_in);
    for (int i = 0; i < n * m; i++) {
        tiles_in[i] = i + 1;
    }
    tiles_in[n * m - 1] = 0;
    table goal(tiles_in);
    priority_queue<pair<int, table>, vector<pair<int, table>>, tableGreater> open;
    unordered_set<table, tableHash> closed;
    unordered_map<table, int, tableHash> g;
    unordered_map<table, int, tableHash> movedTile;
    unordered_map<table, int, tableHash> moveDirection;
    int steps = 0;
    open.push({ start.h, start });
    while (!open.empty()) {
        table current = open.top().second;
        open.pop();
        if (current == goal) {
            goal = current;
            steps = g[current];
            break;
        }
        closed.insert(current);
        for (int i = 0; i < 4; i++) {
            if (current.hasMove(i)) {
                table moved = current.move(i);
                int new_g = g[current] + 1;
                if (!closed.count(moved)) {
                    open.push({ new_g + moved.h, moved });
                    g[moved] = new_g;
                    movedTile[moved] = moved.tiles[current.free];
                    moveDirection[moved] = i;
                }
                if (g.count(moved)) {
                    if (new_g < g[moved]) {
                        movedTile[moved] = moved.tiles[current.free];
                        moveDirection[moved] = i;
                        g[moved] = new_g;
                    }
                }
            }
        }
    }
    vector<int> moves(steps);
    for (int i = 0; i < steps; i++) {
        moves[steps - i - 1] = movedTile[goal];
        goal = goal.move((moveDirection[goal] + 2) % 4);
    }
    fout << steps << endl;
    for (int i = 0; i < steps; i++) {
        fout << moves[i] << endl;
    }
    return 0;
}