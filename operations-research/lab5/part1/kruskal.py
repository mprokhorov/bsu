def kruscal(R):
    Rs = sorted(R, key=lambda x: x[0])
    U = set()  # список соединенных вершин
    D = {}  # словарь списка изолированных групп вершин
    T = []  # список ребер остова

    for r in Rs:
        if r[1] not in U or r[2] not in U:  # проверка для исключения циклов в остове
            if r[1] not in U and r[2] not in U:  # если обе вершины не соединены, то
                D[r[1]] = [r[1], r[2]]  # формируем в словаре ключ с номерами вершин
                D[r[2]] = D[r[1]]  # и связываем их с одним и тем же списком вершин
            else:  # иначе
                if not D.get(r[1]):  # если в словаре нет первой вершины, то
                    D[r[2]].append(r[1])  # добавляем в список первую вершину
                    D[r[1]] = D[r[2]]  # и добавляем ключ с номером первой вершины
                else:
                    D[r[1]].append(r[2])  # иначе, все то же самое делаем со второй вершиной
                    D[r[2]] = D[r[1]]

            T.append(r)  # добавляем ребро в остов
            U.add(r[1])  # добавляем вершины в множество U
            U.add(r[2])

    for r in Rs:  # проходим по ребрам второй раз и объединяем разрозненные группы вершин
        if r[2] not in D[r[1]]:  # если вершины принадлежат разным группам, то объединяем
            T.append(r)  # добавляем ребро в остов
            gr1 = D[r[1]]
            D[r[1]] += D[r[2]]  # объединем списки двух групп вершин
            D[r[2]] += gr1

    return T


def print_solution(file_name):
    # список ребер графа (длина, вершина 1, вершина 2)
    R = []
    with open(file_name) as f:
        for line in f:
            spl = line.split()
            R.append((int(spl[0]), int(spl[1]), int(spl[2])))
    T = kruscal(R)
    print(f"Minimal spanning tree for {file_name.split('.')[0]}: {T}")
    for i, edge in enumerate(R):
        R[i] = (-edge[0], edge[1], edge[2])
    T = kruscal(R)
    for i, edge in enumerate(T):
        T[i] = (-edge[0], edge[1], edge[2])
    print(f"Maximal spanning tree for {file_name.split('.')[0]}: {T}")


print_solution("1a.txt")
print_solution("1b.txt")
print_solution("1c.txt")
print_solution("1d.txt")
