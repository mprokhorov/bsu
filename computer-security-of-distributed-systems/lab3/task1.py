from sympy import Symbol, Eq, solve


def find_parameters_for_elliptic_group(M):
    a = Symbol('a')
    b = Symbol('b')

    # Уравнение эллиптической кривой: y^2 = x^3 + ax + b
    equation = Eq((4 * a ** 3 + 27 * b ** 2) % M, 0)

    # Решение уравнения для a и b
    solutions = solve(equation, (a, b))

    return solutions


# Пример использования:
M_value = 17
parameters = find_parameters_for_elliptic_group(M_value)
print(f"Parameters for EM(a, b) with M={M_value}: {parameters}")
