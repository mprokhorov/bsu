def question1(n):
    divisors_sum = 0
    for i in range(1, n):
        if n % i == 0:
            divisors_sum += i
    return divisors_sum == n


def question2(n, digit):
    str_n = str(n)
    result_str = str_n[0]
    for i in range(1, len(str_n)):
        result_str += str(digit) + str_n[i]
    return int(result_str)


def question3(n):
    str_n = str(n)
    max_digit = max(str_n)
    result_str = ""
    for digit in str_n:
        if digit == max_digit:
            result_str += digit * 2
        else:
            result_str += digit
    return int(result_str)


def main():
    while True:
        print("Выберите задание (от 1 до 3):")
        print("1. Проверить, является ли число совершенным.")
        print("2. Вставить заданное число между соседними цифрами числа.")
        print("3. Продублировать каждое вхождение наибольшей цифры числа.")
        choice = input()
        if choice == "1":
            try:
                n = int(input("Введите число: "))
                if n <= 0:
                    raise ValueError
                is_perfect = question1(n)
                if is_perfect:
                    print("Число является совершенным.")
                else:
                    print("Число не является совершенным.")
            except ValueError:
                print("Введите положительное целое число.")
        elif choice == "2":
            try:
                n = int(input("Введите число: "))
                if n < 10:
                    raise ValueError
                digit = int(input("Введите цифру для вставки: "))
                inserted_number = question2(n, digit)
                print("Результат:", inserted_number)
            except ValueError:
                print("Введите целое число, состоящее как минимум из двух цифр.")
        elif choice == "3":
            try:
                n = int(input("Введите число: "))
                if n <= 0:
                    raise ValueError
                result_number = question3(n)
                print("Результат:", result_number)
            except ValueError:
                print("Введите положительное целое число.")
        else:
            print("Введите число от 1 до 3.")

if __name__ == "__main__":
    main()
