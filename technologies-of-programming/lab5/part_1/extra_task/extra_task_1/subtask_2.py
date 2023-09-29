import random

ans = 'y'
while ans == 'y':
    surprises = ["  Шоколадка ", "  Печенька  ", "  Игрушка  ", "  Карточка  ", "  Загадка   "]

    print(f"""
                 (
                  )
             __..---..__
         ,-='  /  |  \  `=-.
        :--..{random.choice(surprises)}..--;
         \.,_____________,./  
    """)
    ans = input("Continue? (y/n): ")