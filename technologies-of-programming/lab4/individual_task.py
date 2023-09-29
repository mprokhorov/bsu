from math import sin, cos, fabs, exp, sqrt


def G(x, a, f):
    if a > x:
        return sin(4 * sin(f(x)) + 3 * a)
    elif a < x:
        return cos(fabs(f(x) + a))
    else:
        sqrt(a ** 2 + f(x) ** 2)


def main():
    print('This program will calculate G(x) based on value of variable x, parameter a and chosen function f(x).')
    x = float(input('x = '))
    a = float(input('a = '))
    func_name = input('Enter exp to set f(x) = e^x or sqr to set f(x) = x^2^: ')
    if func_name == 'exp':
        f = lambda arg: exp(arg)
    elif func_name == 'sqr':
        f = lambda arg: arg ** 2
    else:
        print('Incorrect input.')
        return
    print(f'x = {x}')
    print(f'a = {a}')
    print(f'f(x) = {f(x)}')
    print(f'G(x) = {G(x, a, f)}')


if __name__ == '__main__':
    main()
