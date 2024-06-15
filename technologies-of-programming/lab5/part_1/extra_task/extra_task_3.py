from art import text2art


def guess_the_number(min_num, max_num, max_attempts):
    print(f"Think of a number from {min_num} to {max_num} and I will try to guess it!")
    attempts = 0
    while attempts < max_attempts:
        guess = (min_num + max_num) // 2
        print(f"My guess is {guess}")
        feedback = input("Is it correct? Enter 'y' for yes, 'h' if it's too high, or 'l' if it's too low: ")
        if feedback == 'y':
            print(f"I guessed your number in {attempts} attempts!")
            break
        elif feedback == 'h':
            max_num = guess - 1
        elif feedback == 'l':
            min_num = guess + 1
        else:
            print("Check your input.")
            attempts -= 1
        attempts += 1
    print(text2art("YOU WON", font='block', chr_ignore=True))


while True:
    try:
        min_num_ = int(input("Enter minimal number: "))
        max_num_ = int(input("Enter maximal number: "))
        max_attempts_ = int(input("Enter maximum number of attempts: "))
        break
    except ValueError:
        print("Check your input.")


guess_the_number(min_num_, max_num_, max_attempts_)
