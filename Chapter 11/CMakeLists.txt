cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(timeint C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(timeint)

target_sources(timeint PRIVATE timeint.S)

target_link_libraries(timeint PRIVATE pico_stdlib)
pico_add_extra_outputs(timeint)
