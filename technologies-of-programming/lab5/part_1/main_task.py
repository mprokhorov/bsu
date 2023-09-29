import random
from art import *


def guess_the_number(min_num_, max_num_, max_attempts):
    secret_number = random.randint(min_num_, max_num_)
    attempts = 0
    while attempts < max_attempts:
        try:
            guess = int(input(f"Guess the number between {min_num_} and {max_num_}: "))
        except ValueError:
            print("Please enter a valid integer.")
            continue
        if guess == secret_number:
            print(f"Congratulations, you guessed the number in {attempts+1} attempts!")
            return
        elif guess < secret_number:
            print("The secret number is greater.")
        else:
            print("The secret number is smaller.")
        attempts += 1
    print(text2art("GAME OVER", font='block', chr_ignore=True))


try:
    min_num = guess = int(input("Enter minimal number: "))
except ValueError:
    print("Your input is not integer. Minimal number was set to 1.")
    min_num = 1

try:
    max_num = guess = int(input("Enter maximal number: "))
except ValueError:
    print(f"Your input is not integer. Maximal number was set to {min_num + 99}.")
    max_num = min_num + 99

try:
    assert max_num >= min_num
except AssertionError:
    print(f"Maximum numbers can't exceed minimal number. They were set to 1 and 100.")
    min_num = 1
    max_num = 100

# Пример использования функции guess_the_number()
guess_the_number(1, 100, 10)
