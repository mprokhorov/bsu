import random

num_flips = 1000
heads_count = 0
tails_count = 0

for i in range(num_flips):
    coin = random.randint(0, 1)
    if coin == 0:
        heads_count += 1
    else:
        tails_count += 1

print("Heads:", heads_count)
print("Tails:", tails_count)
