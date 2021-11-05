cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(test_project C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(flashledsasm
  mainmem.S
)

pico_enable_stdio_uart(flashledsasm 1)

pico_add_extra_outputs(flashledsasm)

target_link_libraries(flashledsasm pico_stdlib)