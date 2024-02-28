cmake_minimum_required(VERSION 3.12)
project(tt06_cejmu_riscv)

include(FetchContent)

add_definitions(-w)

set(CMAKE_CXX_STANDARD 17 CACHE STRING "C++ Standard")
message(STATUS "CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}")

FetchContent_Declare(systemc
    GIT_REPOSITORY https://github.com/accellera-official/systemc.git
    GIT_TAG 2.3.4
)

FetchContent_MakeAvailable(systemc)

#******************************************************************************
# Copyright (c) 2020, Intel Corporation. All rights reserved.
#
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception.
#
# *****************************************************************************


enable_testing()

if(NOT DEFINED ENV{ICSC_HOME})
  message("ICSC_HOME is not defined!")
  return()
endif()

# *****************************************************************************
# Change these variables to fit your project


# Name of the toplevel SystemC component
set(SC_TOP "test_nand")

# Name of the toplevel SystemVerilog component
# (This should only differ from SC_TOP if the SystemC module has the name of a
# SystemVerilog keyword)
set(SV_TOP ${SC_TOP})
# *****************************************************************************

## SVC package contains ScTool and SystemC libraries
find_package(SVC REQUIRED)

# C++ standard must be the same as in ScTool, $(SystemC_CXX_STANDARD) contains 17
set(CMAKE_CXX_STANDARD 17)

#include_directories($ENV{ICSC_HOME}/include)


# All synthesizable source files must be listed here (not in libraries)
add_executable(${SC_TOP}
    testbench.cpp
)

# Add compilation options
# target_compile_definitions(mydesign PUBLIC -DMYOPTION)
# target_compile_options(mydesign PUBLIC -Wall)

# Add optional library, do not add SystemC library (it added by svc_target)
#target_link_libraries(mydesign sometestbenchlibrary)

# svc_target will create @mydesign_sctool executable that runs code generation
# and @mydesign that runs general SystemC simulation
# ELAB_TOP parameter accepts hierarchical name of DUT
# (that is SystemC name, returned by sc_object::name() method)
svc_target(${SC_TOP} INIT_LOCAL_VARS ELAB_TOP tb.dut_inst)

add_custom_command(OUTPUT sv_out/${SC_TOP}.sv
    COMMAND ./${SC_TOP}_sctool
    DEPENDS ${SC_TOP}_sctool

    COMMENT "Starting compilation to SystemVerilog"
)

add_custom_target(convert
    COMMAND yosys -p 'read_verilog -sv sv_out/${SC_TOP}.sv\; proc\; write_verilog ${SV_TOP}.v'

    BYPRODUCTS ${SV_TOP}.v
    DEPENDS sv_out/${SC_TOP}.sv

    COMMENT "Producing Verilog file"
)

add_custom_target(synthesis
    COMMAND yosys -p 'read_verilog -sv sv_out/${SC_TOP}.sv\; proc\; hierarchy -top ${SV_TOP}\; write_json ${SV_TOP}.json'

    BYPRODUCTS ${SV_TOP}.json
    DEPENDS sv_out/${SC_TOP}.sv

    COMMENT "Starting generic synthesis"
)

add_custom_target(synthesis_ice40
    COMMAND yosys -p 'read_verilog -sv sv_out/${SC_TOP}.sv\; hierarchy -top ${SV_TOP}\; synth_ice40 -dsp -spram -top ${SV_TOP}\; write_json ${SV_TOP}.json'

    BYPRODUCTS ${SV_TOP}.json
    DEPENDS sv_out/${SC_TOP}.sv

    COMMENT "Starting ice40 synthesis"
)

add_custom_target(visualize
    COMMAND sed -i -e 's/inout/output/g' ${SV_TOP}.json
    COMMAND netlistsvg ${SV_TOP}.json -o ${SV_TOP}.svg
    COMMAND svgo ${SV_TOP}.svg
    COMMAND rsvg-convert -f pdf -o ${SV_TOP}.pdf ${SV_TOP}.svg

    BYPRODUCTS ${SV_TOP}.svg
    BYPRODUCTS ${SV_TOP}.pdf

    DEPENDS ${SV_TOP}.json

    COMMENT "Generating svg and pdf visualization"
)

add_custom_target(pnr
    COMMAND nextpnr-ice40 --up5k --package sg48 --asc ${SV_TOP}.asc --json ${SV_TOP}.json
)

# add_dependencies(visualize synthesis)
add_dependencies(synthesis ${SC_TOP}_sctool)
add_dependencies(synthesis_ice40 ${SC_TOP}_sctool)
