from sympy import Symbol, Eq, solve

def generate_elliptic_group_elements(a, b, M):
    elements = []

    for x in range(M):
        # Вычисление y по уравнению эллиптической кривой: y^2 = x^3 + ax + b
        y_squared = (x**3 + a*x + b) % M
        y = None

        # Поиск корней квадратного уравнения
        for candidate_y in range(M):
            if (candidate_y**2) % M == y_squared:
                y = candidate_y
                break

        # Если найден корень, добавить точку в группу
        if y is not None:
            elements.append((x, y))

    return elements

# Пример использования с параметрами из предыдущего скрипта
if parameters:
    a_value, b_value = parameters[0]
    elements = generate_elliptic_group_elements(a_value, b_value, M_value)
    print(f"Elements of EM({a_value}, {b_value}) with M={M_value}: {elements}")
