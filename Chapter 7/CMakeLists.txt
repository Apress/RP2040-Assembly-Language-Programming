cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(Functions C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(Functions
  main.S
  codesnippets.S
  upper.S
  mainmacro.S
)

pico_enable_stdio_uart(Functions 1)
pico_enable_stdio_usb(Functions 0)

pico_add_extra_outputs(Functions)

target_link_libraries(Functions pico_stdlib)