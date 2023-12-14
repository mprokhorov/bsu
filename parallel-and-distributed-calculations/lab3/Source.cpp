#include <Windows.h>
#include <assert.h>
#include <mpi.h>

#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

#define _CRT_SECURE_NO_WARNINGS

class FunctionTimer {
public:
    FunctionTimer();
    void startTimer();
    double totalTime();

private:
    LARGE_INTEGER startTime;
    LARGE_INTEGER currentTime;
    double tickPerMillisecond;
};

FunctionTimer::FunctionTimer()
{
    QueryPerformanceFrequency(&startTime);
    tickPerMillisecond = double(startTime.QuadPart) / 1000.0;
};

void FunctionTimer::startTimer()
{
    QueryPerformanceCounter(&startTime);
};

double
FunctionTimer::totalTime()
{
    QueryPerformanceCounter(&currentTime);
    return (currentTime.QuadPart - startTime.QuadPart) / tickPerMillisecond;
};

int main(int argc, char** argv)
{
    int procs_rank, procs_count, N, r;
    MPI_Init(&argc, &argv); //инициализация MPI
    MPI_Comm_size(
        MPI_COMM_WORLD,
        &procs_count); //определение кол-ва процессов, записывает в procs_count
    MPI_Comm_rank(MPI_COMM_WORLD,
        &procs_rank); //определение ранка вызывающего процесса,
    //записывает в procs_rank

    int* A = nullptr;
    int* B = nullptr;
    int* localC = nullptr;
    int* localB = nullptr;

    double timer;
    
    if (procs_rank == 0) {
        std::cout << "Input size: ";
        std::cin >> N;
    }
    MPI_Bcast(&N, 1, MPI_INT, 0, MPI_COMM_WORLD);
    r = N / procs_count + int(procs_rank < (N % procs_count));

    localC = new int[r * N];
    memset(localC, 0, r * N * sizeof(int));

    if (procs_rank != 0) {
        A = new int[r * N];
        localB = new int[N];
        MPI_Recv(A, r * N, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
    } else {
        int counter = N / procs_count;

        for (int q = 1; q < procs_count; ++q) {
            int procSize = (counter + int(q < (N % procs_count))) * N;

            A = new int[procSize];
            for (int i = 0; i < procSize; ++i) {
                A[i] = -100 + rand() % 201;
            }

            MPI_Send(A, procSize, MPI_INT, q, 0, MPI_COMM_WORLD);
            delete[] A;
        }

        B = new int[N * N];
        for (int i = 0; i < N * N; ++i) {
            B[i] = -100 + rand() % 201;
        }
        
        A = new int[r * N];
        for (int i = 0; i < r * N; ++i) {
            A[i] = -100 + rand() % 201;
        }
    }

    timer = MPI_Wtime();

    for (int j = 0; j < N; ++j) {
        if (procs_rank > 0) {
            MPI_Recv(localB, N, MPI_INT, procs_rank - 1, MPI_ANY_TAG, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        } else {
            localB = B + j * N;
        }

        for (int i = 0; i < r; ++i) {
            for (int k = 0; k < N; ++k) {
                localC[N * i + j] = localC[N * i + j] + A[N * i + k] * localB[k];
            }
        }

        if (procs_rank < procs_count - 1) {
            MPI_Send(localB, N, MPI_INT, procs_rank + 1, 0, MPI_COMM_WORLD);
        }
    }

    int* resultC = nullptr;
    int* resultA = nullptr;

    if (procs_rank == 0) {
        resultC = new int[N * N];
        resultA = new int[N * N];
        memcpy(resultC, localC, r * N * sizeof(int));
        memcpy(resultA, A, r * N * sizeof(int));
    }

    if (procs_rank == 0) {
        int displ = r * N;
        int defSize = N / procs_count;

        for (int q = 1; q < procs_count; ++q) {
            int procSize = (defSize + int(q < (N % procs_count))) * N;
            MPI_Recv(resultC + displ, procSize, MPI_INT, q, MPI_ANY_TAG, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            MPI_Recv(resultA + displ, procSize, MPI_INT, q, MPI_ANY_TAG, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
            displ += procSize;
        }

        printf("Passed: %.5f milliseconds\n", (MPI_Wtime() - timer) * 1000);
        std::cout << "**************************************************" << std::endl;

        /*for (int i = 0; i < N; ++i) {
            for (int j = 0; j < N; ++j) {
                std::cout << resultA[i * N + j] << " ";
            }
            std::cout << std::endl;
        }
        std::cout << "**************************************************" << std::endl;

        for (int i = 0; i < N; ++i) {
            for (int j = 0; j < N; ++j) {
                std::cout << B[j * N + i] << " ";
            }
            std::cout << std::endl;
        }
        std::cout << "**************************************************" << std::endl;

        for (int i = 0; i < N; ++i) {
            for (int j = 0; j < N; ++j) {
                std::cout << resultC[i * N + j] << " ";
            }
            std::cout << std::endl;
        }
        std::cout << "**************************************************" << std::endl;*/
    } else {
        MPI_Send(localC, r * N, MPI_INT, 0, 0, MPI_COMM_WORLD);
        MPI_Send(A, r * N, MPI_INT, 0, 0, MPI_COMM_WORLD);
    }

    MPI_Finalize(); //завершение работы MPI
    return 0;
}