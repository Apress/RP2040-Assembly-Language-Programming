cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(iot C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

include_directories(${CMAKE_SOURCE_DIR})

add_executable(iot
  iot.S adctemp.S mmath.S muart.S
)

pico_enable_stdio_uart(iot 0)
pico_enable_stdio_usb(iot 1)

pico_add_extra_outputs(iot)

target_link_libraries(iot pico_stdlib)