time = 3600
total_count = 120

f = {}
q = {}

f['ROBOT'] = {'ENTRIES': 120, 'AVE. TIME': 2.934}
# f['CHANNEL1']
f['CHANNEL2'] = {'ENTRIES': 92, 'AVE. TIME': 27.629}
f['CHANNEL3'] = {'ENTRIES': 28, 'AVE. TIME': 25.524}

q['ROBOTQUEUE'] = {'MAX': 1, 'ENTRY': 120, 'AVE.CONT.': 0.000, 'AVE.TIME': 0.011, 'AVE.(-0)': 1.379}
q['CHQ1'] = {'MAX': 0, 'ENTRY': 0, 'AVE.CONT.': 0.000, 'AVE.TIME': 0.000, 'AVE.(-0)': 0.000}
q['CHQ2'] = {'MAX': 1, 'ENTRY': 92, 'AVE.CONT.': 0.346, 'AVE.TIME': 13.528, 'AVE.(-0)': 28.943}
q['CHQ3'] = {'MAX': 1, 'ENTRY': 28, 'AVE.CONT.': 0.037, 'AVE.TIME': 4.753, 'AVE.(-0)': 19.013}

for name in f.keys():
    print(name)
    print(f'Время работы: {f[name]["ENTRIES"] * f[name]["AVE. TIME"]}, время простоя: {time - f[name]["ENTRIES"] * f[name]["AVE. TIME"]}')
    print(f'Среднее время обслуживания: {f[name]["AVE. TIME"]}')
    print(f'Доля времени простоя относительно времени работы системы: {(time - f[name]["ENTRIES"] * f[name]["AVE. TIME"]) / time}')
    print()

for name in q.keys():
    print(name)
    print(f'Среднее время ожидания в очереди: {q[name]["AVE.TIME"]}')
    print(f'Средний размер очереди: {q[name]["AVE.CONT."]}, максимальный размер очереди: {q[name]["MAX"]}')
    print(f'Среднее время пустой очереди: {q[name]["AVE.(-0)"]}')
    print()

print(f'Общее число сгенерированных и обработанных запросов: {total_count}')
