M = 59

elliptic_groups = []

for a in range(M):
    for b in range(M):
        if (4 * a ** 3 + 27 * b ** 2) % M == 0:
            continue

        elliptic_group_order = 1

        for x in range(M):
            for y in range(M):
                if (y ** 2 - x ** 3 - a * x - b) % M == 0:
                    elliptic_group_order += 1

        elliptic_groups.append((a, b, elliptic_group_order))

elliptic_group_orders = set()

for elliptic_group_order in elliptic_groups:
    elliptic_group_orders.add(elliptic_group_order[2])

elliptic_groups.sort(key=lambda eg: (eg[2], eg[0], eg[1]))
print('\n'.join(map(str, elliptic_groups)))
