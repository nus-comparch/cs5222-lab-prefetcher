cmake_minimum_required(VERSION 3.18)

project("dpc2sim" LANGUAGES C CXX)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 17)

# set(CMAKE_BUILD_TYPE "Release")
set(CMAKE_BUILD_TYPE "Debug")

# ######################################################################################################################
# SET LOCAL OPTIONS
# ######################################################################################################################

if(CMAKE_BUILD_TYPE STREQUAL "Release")
  add_compile_options(-O3)
else()
  add_compile_options(-Og -g -Wall -Wextra)
  add_compile_options(-fsanitize=address -fno-omit-frame-pointer)
  add_link_options(-fsanitize=address -fno-omit-frame-pointer)
  add_compile_definitions(DEBUG)
endif(CMAKE_BUILD_TYPE STREQUAL "Release")
add_compile_options(-Wno-unused-parameter)
add_link_options(-no-pie)

file(GLOB PREFETCHERS_CC example_prefetchers/*.cc)
file(GLOB TRACE_FILES traces/*.dpc.gz)

find_library(libdpc2sim dpc2sim ${CMAKE_SOURCE_DIR}/lib)
find_program(RUNNER runner.sh ${CMAKE_SOURCE_DIR})

add_custom_target(sim-all)

foreach(PREFETCHER IN LISTS PREFETCHERS_CC)
  get_filename_component(PREFETCHER_NAME ${PREFETCHER} NAME_WLE)
  string(REPLACE "_prefetcher" "" PREFETCHER_NAME ${PREFETCHER_NAME})
  set(PREFETCHER_EXE "dpc2sim-${PREFETCHER_NAME}")

  add_executable(${PREFETCHER_EXE} ${PREFETCHER} lib/dpc2sim.a)
  target_link_libraries(${PREFETCHER_EXE} PRIVATE ${libdpc2sim})

  add_custom_target(sim-${PREFETCHER_NAME})
  add_dependencies(sim-all sim-${PREFETCHER_NAME})

  foreach(TRACE IN LISTS TRACE_FILES)
    get_filename_component(TRACE_NAME ${TRACE} NAME_WLE)
    string(REPLACE "_trace2.dpc" "" TRACE_NAME ${TRACE_NAME})

    add_custom_target(
      sim-${PREFETCHER_NAME}-${TRACE_NAME}
      ${RUNNER} ${CMAKE_BINARY_DIR}/data ${PREFETCHER_NAME}-${TRACE_NAME} ${CMAKE_BINARY_DIR}/${PREFETCHER_EXE} ${TRACE}
      DEPENDS ${RUNNER} ${PREFETCHER_EXE})
    add_dependencies(sim-${PREFETCHER_NAME} sim-${PREFETCHER_NAME}-${TRACE_NAME})
  endforeach()

endforeach()

