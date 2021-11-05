cmake_minimum_required(VERSION 3.13)

include(pico_sdk_import.cmake)
project(snippets C CXX ASM)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

pico_sdk_init()

add_executable(snippets)

# by default the header is generated into the build dir
pico_generate_pio_header(snippets ${CMAKE_CURRENT_LIST_DIR}/snippets.pio)

target_sources(snippets PRIVATE snippets.c)

target_link_libraries(snippets PRIVATE pico_stdlib hardware_pio)
pico_add_extra_outputs(snippets)
