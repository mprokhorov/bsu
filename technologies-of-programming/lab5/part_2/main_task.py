def question1(n):
    sum_of_digits = 0
    count_of_digits = 0
    while n > 0:
        digit = n % 10
        sum_of_digits += digit
        count_of_digits += 1
        n = n // 10
    return sum_of_digits, count_of_digits


def question2(num, n):
    result = 1
    for i in range(n):
        result *= num
    return result


def question3(n):
    digits = set()
    while n > 0:
        digit = n % 10
        digits.add(digit)
        n = n // 10
    return len(digits)


def question4(n):
    max_digit = 0
    while n > 0:
        digit = n % 10
        if digit > max_digit:
            max_digit = digit
        n = n // 10
    return max_digit


def question5(n):
    num_str = str(n)
    return num_str == num_str[::-1]


def question6(n):
    if n < 2:
        return False
    for i in range(2, int(n ** 0.5) + 1):
        if n % i == 0:
            return False
    return True


def question7(n):
    prime_divisors = set()
    i = 2
    while i <= n:
        if n % i == 0:
            prime_divisors.add(i)
            n = n // i
        else:
            i += 1
    return prime_divisors


def question8(a, b):
    def gcd(x, y):
        while y != 0:
            x, y = y, x % y
        return x

    def lcm(x, y):
        return x * y // gcd(x, y)

    return gcd(a, b), lcm(a, b)


def question9(day, month, year):
    days_in_month = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0):
        days_in_month[2] = 29
    if day < days_in_month[month]:
        day += 1
    else:
        day = 1
        month += 1
        if month > 12:
            month = 1
            year += 1
    return day, month, year


def question10(n):
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        prev_prev = 0
        prev = 1
        for i in range(2, n + 1):
            current = prev_prev + prev
            prev_prev = prev
            prev = current
        return current


while True:
    try:
        # Предложение выбрать номер функции
        choice = int(input("Выберите номер функции (1-10): "))
        # Проверка, что выбор в диапазоне от 1 до 10
        if choice < 1 or choice > 10:
            print("Некорректный выбор, попробуйте снова.")
            continue
        # Выбор функции в зависимости от выбранного номера
        if choice == 1:
            n = int(input("Введите натуральное число: "))
            result = question1(n)
            print("Сумма цифр:", result[0])
            print("Количество цифр:", result[1])
        elif choice == 2:
            n = int(input("Введите число: "))
            power = int(input("Введите натуральную степень: "))
            result = question2(n, power)
            print("Результат:", result)
        elif choice == 3:
            n = int(input("Введите натуральное число: "))
            result = question3(n)
            print("Количество различных цифр:", result)
        elif choice == 4:
            n = int(input("Введите натуральное число: "))
            result = question4(n)
            print("Наибольшая цифра:", result)
        elif choice == 5:
            n = int(input("Введите натуральное число: "))
            result = question5(n)
            if result:
                print("Число является палиндромом")
            else:
                print("Число не является палиндромом")
        elif choice == 6:
            n = int(input("Введите натуральное число: "))
            result = question6(n)
            if result:
                print("Число является простым")
            else:
                print("Число не является простым")
        elif choice == 7:
            n = int(input("Введите натуральное число: "))
            result = question7(n)
            print("Простые делители:", result)
        elif choice == 8:
            n1 = int(input("Введите первое натуральное число: "))
            n2 = int(input("Введите второе натуральное число: "))
            gcd, lcm = question8(n1, n2)
            print("НОД:", gcd)
            print("НОК:", lcm)
        elif choice == 9:
            year = int(input("Введите год: "))
            month = int(input("Введите месяц: "))
            day = int(input("Введите день: "))
            result = question9(day, month, year)
            print("Следующая дата:", result)
        elif choice == 10:
            n = int(input("Введите порядковый номер элемента: "))
            result = question10(n)
            print("Значение элемента:", result)
        # Выход из цикла
        break
    except ValueError:
        print("Некорректный ввод, попробуйте снова.")
