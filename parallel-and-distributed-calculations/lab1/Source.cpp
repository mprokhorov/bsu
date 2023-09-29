#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include <functional>
#include <random>
#include <chrono>
#include <sstream>
#include <cassert>
#include <omp.h>

#undef NDEBUG
#include <assert.h>

const int thr = 8;

template <typename T>
std::string map_to_json(const std::map<int, T>& inputMap) {
    std::stringstream ss;
    ss << "{";
    bool first = true;
    for (const auto& pair : inputMap) {
        if (!first) {
            ss << ", ";
        }
        ss << "\"" << pair.first << "\": " << pair.second;
        first = false;
    }
    ss << "}";
    return ss.str();
}

template <typename T>
std::string map_to_json(const std::map<int, std::map<int, T>>& inputMap) {
    std::stringstream ss;
    ss << "{";
    bool first = true;
    for (const auto& pair : inputMap) {
        if (!first) {
            ss << ", ";
        }
        ss << "\"" << pair.first << "\": " << map_to_json(pair.second);
        first = false;
    }
    ss << "}";
    return ss.str();
}

bool compare_matrices(int* left, int* right, int size) {
    for (int i = 0; i < size; ++i) {
        if (left[i] != right[i]) {
            return false;
        }
    }
    return true;
}

void dot_serial(int* A, int* B, int* C, int N) {
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            int c_ij = 0;
            for (int k = 0; k < N; ++k) {
                c_ij += A[i * N + k] * B[k * N + j];
            }
            C[i * N + j] += c_ij;
        }
    }
}

void dot_parallel_outer(int* A, int* B, int* C, int N) {
    #pragma omp parallel for num_threads(thr)
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            int c_ij = 0;
            for (int k = 0; k < N; ++k) {
                c_ij += A[i * N + k] * B[k * N + j];
            }
            C[i * N + j] += c_ij;
        }
    }
}

void dot_parallel_inner(int* A, int* B, int* C, int N) {
    for (int i = 0; i < N; ++i) {
        #pragma omp parallel for num_threads(thr)
        for (int j = 0; j < N; ++j) {
            int c_ij = 0;
            for (int k = 0; k < N; ++k) {
                c_ij += A[i * N + k] * B[k * N + j];
            }
            C[i * N + j] += c_ij;
        }
    }
}

void block_serial(int* A, int* B, int* C, int N, int r) {
    int N_r = N % r == 0 ? N / r : N / r + 1;
    for (int i_gl = 0; i_gl < N_r; ++i_gl) {
        int i_left = i_gl * r;
        int i_right = i_gl == N_r - 1 ? N : (i_gl + 1) * r;
        for (int j_gl = 0; j_gl < N_r; ++j_gl) {
            int j_left = j_gl * r;
            int j_right = j_gl == N_r - 1 ? N : (j_gl + 1) * r;
            for (int k_gl = 0; k_gl < N_r; ++k_gl) {
                int k_left = k_gl * r;
                int k_right = k_gl == N_r - 1 ? N : (k_gl + 1) * r;
                for (int i = i_left; i < i_right; ++i) {
                    int i_N = i * N;
                    for (int j = j_left; j < j_right; ++j) {
                        int c_ij = 0;
                        for (int k = k_left; k < k_right; ++k) {
                            c_ij += A[i_N + k] * B[k * N + j];
                        }
                        C[i_N + j] += c_ij;
                    }
                }
            }
        }
    }
}

void block_parallel_outer(int* A, int* B, int* C, int N, int r) {
    int N_r = N % r == 0 ? N / r : N / r + 1;
    #pragma omp parallel for num_threads(thr)
    for (int i_gl = 0; i_gl < N_r; ++i_gl) {
        int i_left = i_gl * r;
        int i_right = i_gl == N_r - 1 ? N : (i_gl + 1) * r;
        for (int j_gl = 0; j_gl < N_r; ++j_gl) {
            int j_left = j_gl * r;
            int j_right = j_gl == N_r - 1 ? N : (j_gl + 1) * r;
            for (int k_gl = 0; k_gl < N_r; ++k_gl) {
                int k_left = k_gl * r;
                int k_right = k_gl == N_r - 1 ? N : (k_gl + 1) * r;
                for (int i = i_left; i < i_right; ++i) {
                    int i_N = i * N;
                    for (int j = j_left; j < j_right; ++j) {
                        int c_ij = 0;
                        for (int k = k_left; k < k_right; ++k) {
                            c_ij += A[i_N + k] * B[k * N + j];
                        }
                        C[i_N + j] += c_ij;
                    }
                }
            }
        }
    }
}

void block_parallel_inner(int* A, int* B, int* C, int N, int r) {
    int N_r = N % r == 0 ? N / r : N / r + 1;
    for (int i_gl = 0; i_gl < N_r; ++i_gl) {
        int i_left = i_gl * r;
        int i_right = i_gl == N_r - 1 ? N : (i_gl + 1) * r;
        #pragma omp parallel for num_threads(thr)
        for (int j_gl = 0; j_gl < N_r; ++j_gl) {
            int j_left = j_gl * r;
            int j_right = j_gl == N_r - 1 ? N : (j_gl + 1) * r;
            for (int k_gl = 0; k_gl < N_r; ++k_gl) {
                int k_left = k_gl * r;
                int k_right = k_gl == N_r - 1 ? N : (k_gl + 1) * r;
                for (int i = i_left; i < i_right; ++i) {
                    int i_N = i * N;
                    for (int j = j_left; j < j_right; ++j) {
                        int c_ij = 0;
                        for (int k = k_left; k < k_right; ++k) {
                            c_ij += A[i_N + k] * B[k * N + j];
                        }
                        C[i_N + j] += c_ij;
                    }
                }
            }
        }
    }
}

void reset_matrix(int* C, int N) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            C[i * N + j] = 0;
        }
    }
}

int main() {
    std::cout << std::boolalpha;
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> distrib(-100, 100);
    std::vector<int> N_set = { 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800, 1900, 2000, 64, 128, 256, 512, 1024, 2048 };
    std::vector<int> r_set = { 1, 2, 5, 10, 20, 50, 100, 200, 500 };

    std::map<std::string, std::function<void(int*, int*, int*, int)>> dot;
    dot["serial"] = dot_serial;
    dot["parallel_outer"] = dot_parallel_outer;
    dot["parallel_inner"] = dot_parallel_inner;
    std::map<std::string, std::map<int, long long>> durations_dot;
    durations_dot["serial"] = std::map<int, long long>();
    durations_dot["parallel_inner"] = std::map<int, long long>();
    durations_dot["parallel_outer"] = std::map<int, long long>();
    std::map<std::string, std::function<void(int*, int*, int*, int, int)>> block;
    block["serial"] = block_serial;
    block["parallel_outer"] = block_parallel_outer;
    block["parallel_inner"] = block_parallel_inner;
    std::map<std::string, std::map<int, std::map<int, long long>>> durations_block;
    durations_block["serial"] = std::map<int, std::map<int, long long>>();
    durations_block["parallel_outer"] = std::map<int, std::map<int, long long>>();
    durations_block["parallel_inner"] = std::map<int, std::map<int, long long>>();
    for (int N : N_set) {
        std::cout << "N = " << N << std::endl;
        int* A = new int[N * N];
        int* B = new int[N * N];
        int* C = new int[N * N];
        int* C_reference = new int[N * N];
        for (int i = 0; i < N * N; i++) {
            A[i] = distrib(gen);
            B[i] = distrib(gen);
            C[i] = 0;
            C_reference[i] = 0;
        }
        dot_serial(A, B, C_reference, N);
        for (std::string s : {"serial", "parallel_outer", "parallel_inner"}) {
            reset_matrix(C, N);
            auto start = std::chrono::high_resolution_clock::now();
            dot[s](A, B, C, N);
            auto end = std::chrono::high_resolution_clock::now();
            auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
            durations_dot[s][N] = duration.count();
            assert(compare_matrices(C, C_reference, N * N));
        }
        std::vector<int> r_sizes;
        for (auto it = r_set.begin(); it != r_set.end() && *it < N; ++it) {
            r_sizes.push_back(*it);
        }
        r_sizes.push_back(N);
        for (auto r : r_sizes) {
            for (std::string s : {"serial", "parallel_outer", "parallel_inner"}) {
                reset_matrix(C, N);
                auto start = std::chrono::high_resolution_clock::now();
                block[s](A, B, C, N, r);
                auto end = std::chrono::high_resolution_clock::now();
                auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
                durations_block[s][N][r] = duration.count();
                assert(compare_matrices(C, C_reference, N * N));
            }
        }
    }

    std::map<std::string, std::map<int, std::pair<int, int>>> min_durations_block;
    for (std::string s : {"serial", "parallel_outer", "parallel_inner"}) {
        for (auto const& i : durations_block[s]) {
            long long min_time = (((*i.second.begin()).second + (*std::next(i.second.begin())).second)) / 2;
            std::pair<int, int> min_r = { (*i.second.begin()).first, (*std::next(i.second.begin())).first };
            for (auto it = i.second.begin(); it != std::prev(i.second.end()); ++it) {
                if ((((*it).second + (*std::next(it)).second)) / 2 < min_time) {
                    min_r = { (*it).first, (*std::next(it)).first };
                    min_time = (((*it).second + (*std::next(it)).second)) / 2;
                }
            }
            min_durations_block[s][i.first] = min_r;
        }
    }

    std::map<std::string, std::map<int, int>> best_r_block;
    std::map<std::string, std::map<int, int>> best_time_block;
    for (std::string s : {"serial", "parallel_outer", "parallel_inner"}) {
        for (const auto& i : min_durations_block[s]) {
            int N = i.first;
            std::cout << s << ": N = " << N << std::endl;
            int left = i.second.first;
            int right = i.second.second;
            int steps = std::min(10, right - left);
            std::map<int, long long> r_sizes;
            r_sizes[left] = 0;
            for (int i = 0; i < steps; i++) {
                r_sizes[left + (right - left) * i / steps] = 0;
            }
            r_sizes[right] = 0;
            int* A = new int[N * N];
            int* B = new int[N * N];
            int* C = new int[N * N];
            int* C_reference = new int[N * N];
            for (int i = 0; i < N * N; i++) {
                A[i] = distrib(gen);
                B[i] = distrib(gen);
                C[i] = 0;
                C_reference[i] = 0;
            }
            dot_serial(A, B, C_reference, N);
            for (auto kv : r_sizes) {
                for (std::string s : {"serial", "parallel_outer", "parallel_inner"}) {
                    int r = kv.first;
                    reset_matrix(C, N);
                    auto start = std::chrono::high_resolution_clock::now();
                    block[s](A, B, C, N, r);
                    auto end = std::chrono::high_resolution_clock::now();
                    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start);
                    r_sizes[r] = duration.count();
                    assert(compare_matrices(C, C_reference, N * N));
                }
            }
            int min_k = r_sizes.begin()->first;
            long long min_v = r_sizes.begin()->second;
            for (auto kv : r_sizes) {
                if (kv.second < min_v) {
                    min_k = kv.first;
                    min_v = kv.second;
                }
            }
            best_time_block[s][N] = min_v;
            best_r_block[s][N] = min_k;
        }
    }
    std::ofstream out("out.txt");
    for (std::string s : {"serial", "parallel_outer", "parallel_inner"}) {
        out << map_to_json(durations_dot[s]) << std::endl;
    }
    for (std::string s : {"serial", "parallel_outer", "parallel_inner"}) {
        out << map_to_json(durations_block[s]) << std::endl;
    }
    for (std::string s : {"serial", "parallel_outer", "parallel_inner"}) {
        out << map_to_json(best_r_block[s]) << std::endl;
    }
    for (std::string s : {"serial", "parallel_outer", "parallel_inner"}) {
        out << map_to_json(best_time_block[s]) << std::endl;
    }
    return 0;
}