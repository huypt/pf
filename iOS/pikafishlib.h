#pragma once

#include <stdio.h>
#include <string>
#include <stdio.h>
#include <sstream>

#ifndef PIKAFISHLIB_H
#define PIKAFISHLIB_H

#ifdef _WIN32
#define PIKAFISHLIB_API __declspec(dllexport)
#elif __APPLE__
#include <TargetConditionals.h>
#if TARGET_OS_IOS
#define PIKAFISHLIB_API __attribute__((visibility("default")))
#else
#define PIKAFISHLIB_API
#endif
#else
#define PIKAFISHLIB_API
#endif

extern "C" {

    PIKAFISHLIB_API void cpp_init_pikafish(double skill, double time, const char* path);
    PIKAFISHLIB_API void cpp_init_custom_pikafish(double skill, double time, const char* customFEN, const char* path);
    PIKAFISHLIB_API void cpp_set_position(const std::string& fen);
    PIKAFISHLIB_API void cpp_call_move(int from, int to);
    PIKAFISHLIB_API int cpp_search_move();
    PIKAFISHLIB_API void cpp_undo_move();
    PIKAFISHLIB_API void cpp_new_game();
    PIKAFISHLIB_API bool cpp_draw_check();
    PIKAFISHLIB_API void cpp_release_resource();

    typedef void(*FuncCallBack)(const char* message, int size);
    static FuncCallBack callbackInstance = nullptr;
    PIKAFISHLIB_API void RegisterDebugCallback(FuncCallBack cb);
}

class Debug
{
public:
    static void Log(const char* message);
    static void Log(const std::string message);

private:
    static void send_log(const std::stringstream& ss);
};
#endif // PIKAFISHLIB_H
