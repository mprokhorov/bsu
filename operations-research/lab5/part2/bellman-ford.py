class Graph:

    def __init__(self, vertices):
        self.V = vertices  # No. of vertices
        self.graph = []

    # function to add an edge to graph
    def addEdge(self, u, v, w):
        self.graph.append([u - 1, v - 1, w])

    # utility function used to print the solution
    def printArr(self, dist, src):
        print(f"Vertex\tDistance from {src}")
        for i in range(self.V):
            print("{0}\t\t{1}".format(i + 1, dist[i]))

    # The main function that finds shortest distances from src to
    # all other vertices using Bellman-Ford algorithm. The function
    # also detects negative weight cycle
    def BellmanFord(self, vertice):

        # Step 1: Initialize distances from src to all other vertices
        # as INFINITE
        src = vertice - 1
        dist = [float("Inf")] * self.V
        dist[src] = 0

        # Step 2: Relax all edges |V| - 1 times. A simple shortest
        # path from src to any other vertex can have at-most |V| - 1
        # edges
        for _ in range(self.V - 1):
            # Update dist value and parent index of the adjacent vertices of
            # the picked vertex. Consider only those vertices which are still in
            # queue
            for u, v, w in self.graph:
                if dist[u] != float("Inf") and dist[u] + w < dist[v]:
                    dist[v] = dist[u] + w

        # Step 3: check for negative-weight cycles. The above step
        # guarantees shortest distances if graph doesn't contain
        # negative weight cycle. If we get a shorter path, then there
        # is a cycle.

        for u, v, w in self.graph:
            if dist[u] != float("Inf") and dist[u] + w < dist[v]:
                print("Graph contains negative weight cycle")
                return

        # print all distance
        self.printArr(dist, vertice)


g = Graph(9)
g.addEdge(2, 1, -2)
g.addEdge(2, 3, 3)
g.addEdge(3, 4, 4)
g.addEdge(1, 6, 1)
g.addEdge(2, 5, -1)
g.addEdge(5, 7, 1)
g.addEdge(3, 8, 2)
g.addEdge(4, 9, 2)
g.addEdge(1, 5, 3)      # ok
g.addEdge(6, 5, -1)
g.addEdge(5, 8, 3)      # ok
g.addEdge(5, 3, -2)
g.addEdge(8, 4, -4)     # ok
g.addEdge(6, 7, 0)      # ok
g.addEdge(7, 8, -2)
g.addEdge(8, 9, 1)

# Print the solution
g.BellmanFord(1)
g.BellmanFord(2)
