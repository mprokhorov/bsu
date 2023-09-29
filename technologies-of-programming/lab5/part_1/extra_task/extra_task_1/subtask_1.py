import random

ans = 'y'
while ans == 'y':
    first = random.randint(1, 6)
    second = random.randint(1, 6)
    print(f'First dice: {first}')
    print(f'Second dice: {second}')
    print(f'Sum of numbers: {first + second}')
    ans = input("Continue? (y/n): ")

