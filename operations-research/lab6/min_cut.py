class Graph:

    def __init__(self, graph):
        self.graph = graph
        self.org_graph = [i[:] for i in graph]
        self.ROW = len(graph)
        self.COL = len(graph[0])

    def BFS(self, s, t, parent):
        visited = [False] * self.ROW
        queue = [s]
        visited[s] = True
        while queue:
            u = queue.pop(0)
            for ind, val in enumerate(self.graph[u]):
                if not visited[ind] and val > 0:
                    queue.append(ind)
                    visited[ind] = True
                    parent[ind] = u
        return visited[t]

    def dfs(self, graph, s, visited):
        visited[s] = True
        for i in range(len(graph)):
            if graph[s][i] > 0 and not visited[i]:
                self.dfs(graph, i, visited)

    def minCut(self, source, sink):
        parent = [-1] * self.ROW
        max_flow = 0
        while self.BFS(source, sink, parent):
            path_flow = float("Inf")
            s = sink
            while s != source:
                path_flow = min(path_flow, self.graph[parent[s]][s])
                s = parent[s]
            max_flow += path_flow
            v = sink
            while v != source:
                u = parent[v]
                self.graph[u][v] -= path_flow
                self.graph[v][u] += path_flow
                v = parent[v]
        print("Maximal flow is", max_flow)
        print("Miminal cut:")
        visited = len(self.graph) * [False]
        self.dfs(self.graph, s, visited)
        for i in range(self.ROW):
            for j in range(self.COL):
                if self.graph[i][j] == 0 and \
                        self.org_graph[i][j] > 0 and visited[i]:
                    print(str(i) + " - " + str(j))


graph_matrix = [[0, 2, 3, 1, 0],
                [0, 0, 3, 1, 3],
                [0, 0, 0, 1, 0],  # fix
                [0, 0, 0, 0, 2],
                [0, 0, 0, 0, 0]]
g = Graph(graph_matrix)
g.minCut(0, 4)
print(g.graph)

graph_matrix = [[0, 16, 0, 11, 0, 9, 0, 0],
                [0, 0, 2, 20, 8, 0, 0, 0],
                [0, 0, 0, 0, 2, 0, 0, 10],
                [0, 0, 6, 0, 1, 9, 0, 0],
                [0, 0, 0, 0, 0, 1, 0, 8],
                [0, 0, 0, 0, 0, 0, 15, 0],
                [0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 20, 0, 0]]
g = Graph(graph_matrix)
g.minCut(0, 7)
print(g.graph)

graph_matrix = [[0, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0],
                [0, 0, 0, 0, 1, 0, 6, 1, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 4, 0, 5, 0, 0, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 5, 0, 1, 1, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 2, 3, 3, 0],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4],
                [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
g = Graph(graph_matrix)
g.minCut(0, 11)
print(g.graph)
