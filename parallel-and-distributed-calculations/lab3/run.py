import subprocess
import json


def run_program(N, Q_1_values):
    result = {}
    for Q_1 in Q_1_values:
        command = f"mpiexec.exe -n {Q_1} C:\\Users\\Mikhail\\source\\repos\\stuff\\x64\\Debug\\stuff.exe"
        process = subprocess.Popen(command, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        output, _ = process.communicate(input=f"{N}\n")
        result[Q_1] = float(output.strip())
        print(f'N = {N}, Q_1 = {Q_1}')
    return result


def main():
    logs = {}

    for N in [100, 200, 300, 400, 500]:
        Q_1_values = [1, 2, 5, 10, 20, 50, 100, 200, N]
        logs[N] = run_program(N, Q_1_values)

    for N in [1000, 2000]:
        Q_1_values = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, N]
        logs[N] = run_program(N, Q_1_values)

    for N in [1023, 1024, 1025]:
        Q_1_values = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, N]
        logs[N] = run_program(N, Q_1_values)

    with open('log.json', 'w') as json_file:
        json.dump(logs, json_file, indent=2)


if __name__ == "__main__":
    main()
