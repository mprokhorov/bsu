nV = 5
INF = 999


def floyd(G):
    dist = list(map(lambda p: list(map(lambda q: q, p)), G))

    # Adding vertices individually
    for r in range(nV):
        for p in range(nV):
            for q in range(nV):
                dist[p][q] = min(dist[p][q], dist[p][r] + dist[r][q])
    sol(dist)


def sol(dist):
    for p in range(nV):
        for q in range(nV):
            if dist[p][q] == INF:
                print("INF", end=" ")
            else:
                print(dist[p][q], end="  ")
        print(" ")


G = [[0, -15, 15, INF, INF],
     [20, 0, 7, 1, INF],
     [8, INF, 0, -10, -3],
     [INF, 2, INF, 0, 6],
     [INF, INF, 14, 4, 0]]
floyd(G)
