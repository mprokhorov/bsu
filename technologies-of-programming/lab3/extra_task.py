available_notes = [50000, 20000, 10000, 5000, 2000, 1000, 500, 200, 100, 50, 20, 10, 5, 2, 1]


def optimal_change(amount):
    change = []
    for note in available_notes:
        while amount >= note:
            change.append(note)
            amount -= note
    return change


def print_change(change):
    print("Выданная сумма:")
    notes = [note / 100 for note in change]
    notes_count = {note: notes.count(note) for note in notes}
    for note, count in notes_count.items():
        print("{} евро: {} шт".format(note, count))


amount = float(input("Введите сумму для выдачи (в евро): "))
amount_cents = int(amount * 100)

change = optimal_change(amount_cents)

print_change(change)
