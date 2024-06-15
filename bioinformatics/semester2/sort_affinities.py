path = r'ligand_{i}\ligand_{i}_log.txt'

affinities = {}

for i in range(27):
    file = open(path.format(i=i), 'r')
    lines = file.readlines()
    affinities[i] = (lines[24].strip().split()[1])
    print(f'best affinity (kcal/mol) for ligand_{i}: {affinities[i]}')

for affinity in sorted(affinities.items(), key=lambda a: a[1])[::-1][:5]:
    print(affinity)
