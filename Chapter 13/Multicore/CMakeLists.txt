cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(multicore C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(multicore
  multicore.S 
)

pico_enable_stdio_uart(multicore 1)
pico_enable_stdio_usb(multicore 0)

pico_add_extra_outputs(multicore)

target_link_libraries(multicore pico_stdlib pico_multicore)