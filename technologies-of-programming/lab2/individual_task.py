def print_pretty_table(data, cell_sep=' | ', header_separator=True):
    rows = len(data)
    cols = len(data[0])
    col_width = []

    for col in range(cols):
        columns = [data[row][col] for row in range(rows)]
        col_width.append(len(max(columns, key=len)))

    separator = '-+-'. join('-' * n for n in col_width)

    for i, row in enumerate(range(rows)):
        if i == 1 and header_separator:
            print(separator)
        result = []
        for col in range(cols):
            item = data[row][col].rjust(col_width[col])
            result.append(item)

        print(cell_sep.join(result))


print("Enter your name:")
name = input()
print("Enter your address:")
address = input()
print("Enter your phone:")
phone = input()
print("Enter vour mail:")
mail = input()
print("Enter your favorite color:")
color = input()
table_data = ["NAME", "ADDRESS", "TELEPHONE", 'E-MAIL', "FAV_COLOR"]
table_data_person = [name, address, phone, mail, color]
print_pretty_table([table_data, table_data_person])
