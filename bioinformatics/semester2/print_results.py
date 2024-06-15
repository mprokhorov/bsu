path = r'ligand_{i}_out\output.txt'

for i in [2, 8, 13, 14, 16]:
    file = open(path.format(i=i), 'r')
    lines = file.readlines()
    print(f'ligand_{i}:')
    print(lines[0].strip())
    print(lines[2].strip())
    print()
