from math import inf


def djkstra(D, start_v, end_v):
    def arg_min(T, S):
        amin = -1
        m = inf  # максимальное значение
        for i, t in enumerate(T):
            if t < m and i not in S:
                m = t
                amin = i

        return amin

    N = len(D)  # число вершин в графе
    T = [inf] * N  # последняя строка таблицы

    v = start_v - 1  # стартовая вершина (нумерация с нуля)
    S = {v}  # просмотренные вершины
    T[v] = 0  # нулевой вес для стартовой вершины
    M = [0] * N  # оптимальные связи между вершинами

    while v != -1:  # цикл, пока не просмотрим все вершины
        for j, dw in enumerate(D[v]):  # перебираем все связанные вершины с вершиной v
            if j not in S:  # если вершина еще не просмотрена
                w = T[v] + dw
                if w < T[j]:
                    T[j] = w
                    M[j] = v  # связываем вершину j с вершиной v

        v = arg_min(T, S)  # выбираем следующий узел с наименьшим весом
        if v >= 0:  # выбрана очередная вершина
            S.add(v)  # добавляем новую вершину в рассмотрение

    # print(T, M, sep="\n")

    # формирование оптимального маршрута:
    start = start_v - 1
    end = end_v - 1
    P = [end]
    while end != start:
        end = M[P[-1]]
        P.append(end)

    return [i + 1 for i in P[::-1]]


D1 = ((inf, inf, inf, 2, inf, inf, inf, inf, inf, inf),
      (6, inf, 2, inf, inf, 8, inf, 7, inf, inf),
      (inf, inf, inf, inf, inf, inf, inf, 2, inf, 2),
      (inf, 3, inf, inf, 3, inf, 2, inf, inf, inf),
      (inf, inf, inf, inf, inf, 6, inf, inf, inf, inf),
      (inf, inf, inf, inf, inf, inf, 2, inf, inf, inf),
      (inf, inf, inf, inf, inf, inf, inf, inf, 1, inf),
      (inf, inf, inf, inf, inf, inf, 1, inf, inf, 2),
      (inf, inf, inf, inf, inf, inf, inf, inf, inf, 5),
      (inf, inf, inf, inf, inf, inf, inf, inf, inf, inf))
print(djkstra(D1, 1, 7))
