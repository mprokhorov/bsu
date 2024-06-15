import math


def F(x):
    if x < 0 and a != 0:
        return -(k * x ** (k - 1) + math.sin((k + 1) * a * b)) ** 2 + (k + 3) * c
    elif x > 0 and a == 0:
        if b == -x:
            return None
        else:
            return (-a + k * b * x) / (x + b) + 2 * math.sqrt(c)
    else:
        if k == 0 or b == 0 or c == 0:
            return None
        else:
            return 1 / (k * c * b) + (k + 1) ** 2 * a * b


k = 11

a = float(input("Введите значение параметра a: "))
b = float(input("Введите значение параметра b: "))
c = float(input("Введите значение параметра c: "))

x_1 = float(input("Введите начальное значение аргумента: "))
x_2 = float(input("Введите конечное значение аргумента: "))
dx = float(input("Введите шаг изменения аргумента: "))

print("x_1\t\t\t\tx_2\t\t\t\tdx\t\t\t\ta\t\t\t\tb\t\t\t\tc\t\t\t\tF(x)")

while x_1 <= x_2:
    print("{:.2f}\t\t\t{:.2f}\t\t\t{:.2f}\t\t\t{}\t\t\t{}\t\t\t{}\t\t\t{:.2f}".format(x_1, x_2, dx, a, b, c, F(x_1)))
    x_1 += dx
