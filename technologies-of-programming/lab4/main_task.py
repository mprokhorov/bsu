print('This program will calculate roots of quadatric equation ax^2 + bx + c = 0.')
a = float(input('Enter a: '))
b = float(input('Enter b: '))
c = float(input('Enter c: '))

D = b ** 2 - 4 * a * c

if a == 0:
    print('This equation is not quadatric.')

if D > 0:
    print(f"x1 = {(-b - D ** 0.5) / (2 * a)}, x2 = {(-b + D ** 0.5) / (2 * a)}")
elif D == 0:
    print(f"x = {(-b) / (2 * a)}")
else:
    print(f"This equation has no real roots.")
