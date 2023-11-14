M = 59
a = 3
b = 3

assert (4 * a ** 3 + 27 * b ** 2) % M != 0

EM = []

for x in range(M):
    for y in range(M):
        if (y ** 2 - x ** 3 - a * x - b) % M == 0:
            EM.append((x, y))

print(f'Elements of E{M}({a}, {b}): ' + ', '.join(map(str, EM)))
print(f'Order of E{M}({a}, {b}): {len(EM) + 1}')
