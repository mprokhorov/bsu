M = 59


def is_prime(n):
    for i in range(2, int(n / 2)):
        if (n % i) == 0:
            return False
    return True


EM_groups = []

for a in range(M):
    for b in range(M):
        if (4 * a ** 3 + 27 * b ** 2) % M == 0:
            continue

        EM_order = 1

        for x in range(M):
            for y in range(M):
                if (y ** 2 - x ** 3 - a * x - b) % M == 0:
                    EM_order += 1

        EM_groups.append((a, b, EM_order))

EM_orders = set()

for EM_order in EM_groups:
    EM_orders.add(EM_order[2])

print('\n'.join(map(str, [EM_group for EM_group in EM_groups if EM_group[2] == 73])))
