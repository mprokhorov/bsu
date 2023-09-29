Chameleon1 = input('Enter name: ')
Chameleon2 = int(input('Enter postal code: '))
print(f'Chameleon1 has type {type(Chameleon1)} and is equal to {Chameleon1}')
print(f'Chameleon2 has type {type(Chameleon2)} and is equal to {Chameleon2}')

Chameleon2 = str(Chameleon2)
day = int(input('Enter day of birth: '))
Chameleon2 *= day

print(Chameleon2)
Chameleon3 = Chameleon1 + Chameleon2
print(f'Chameleon3 has type {type(Chameleon3)} and is equal to {Chameleon3}')

Chameleon3 = list(Chameleon3)
print(f'Chameleon3 has type {type(Chameleon3)} and is equal to {Chameleon3}')

print(f'Chameleon3[0] is equal to {Chameleon3[0]}')
print(f'Chameleon3[-1] is equal to {Chameleon3[-1]}')
age = int(input('Enter your age: '))
Chameleon3[-1] = age

length = int(input('Enter length of your list: '))
add = []
for i in range(length):
    add.append(input(f'list[{i}] = '))
Chameleon3 += add
print(Chameleon3)
Chameleon3 *= 2
print(Chameleon3)

Chameleon3 = tuple(Chameleon3)
print(f'Chameleon3 has type {type(Chameleon3)} and is equal to {Chameleon3}')

try:
    Chameleon3[0] = ''
except TypeError:
    print("A TypeError exception occurred")

Chameleon3 += tuple(add)
print(Chameleon3)
Chameleon3 *= 2
print(Chameleon3)

Chameleon3 = set(Chameleon3)
print(f'Chameleon3 has type {type(Chameleon3)} and is equal to {Chameleon3}')

My_Dictionary = {'привет': 'hello',
                 'мир': 'world',
                 'я': 'I',
                 'являюсь': 'am',
                 'пришелец': 'alien',
                 }
print(My_Dictionary['привет'])
