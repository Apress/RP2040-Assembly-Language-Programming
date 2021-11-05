cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(HelloWorld C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(HelloWorld
  HelloWorld.S
)

pico_enable_stdio_uart(HelloWorld 1)
pico_enable_stdio_usb(HelloWorld 0)

pico_add_extra_outputs(HelloWorld)

target_link_libraries(HelloWorld pico_stdlib)