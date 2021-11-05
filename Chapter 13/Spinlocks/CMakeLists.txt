cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(spinlocks C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(spinlocks
  spinlocks.S 
)

pico_enable_stdio_uart(spinlocks 1)
pico_enable_stdio_usb(spinlocks 0)

pico_add_extra_outputs(spinlocks)

target_link_libraries(spinlocks pico_stdlib)