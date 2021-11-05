cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(ControlFlow C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(ControlFlow
  ControlFlow.S 
)

pico_enable_stdio_uart(ControlFlow 1)
pico_enable_stdio_usb(ControlFlow 0)

pico_add_extra_outputs(ControlFlow)

target_link_libraries(ControlFlow pico_stdlib)