cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(test_project C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(CEmbedAsm
  uppertst2.c
)

pico_enable_stdio_uart(CEmbedAsm 1)

pico_add_extra_outputs(CEmbedAsm)

target_link_libraries(CEmbedAsm pico_stdlib)