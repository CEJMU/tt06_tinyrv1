/******************************************************************************
 * Copyright (c) 2020, Intel Corporation. All rights reserved.
 *
 * SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception.
 *
 *****************************************************************************/

// Design template

#include "test_nand.cpp"
#include <iostream>
#include <systemc.h>

// ICSC requires DUT top should be instantiated inside wrapper (typically TB)
// and all DUT ports are bound.
struct Tb : sc_module {
  sc_signal<sc_dt::sc_bv<8>> ui_in;
  sc_signal<sc_dt::sc_bv<8>> uo_out;
  sc_signal<sc_dt::sc_bv<8>> uio_in;
  sc_signal<sc_dt::sc_bv<8>> uio_out;
  sc_signal<sc_dt::sc_bv<8>> uio_oe;
  sc_signal<bool> ena;
  sc_signal<bool> clk;
  sc_signal<bool> rst_n;

  tt_um_test_nand dut_inst{"dut_inst"};

  SC_CTOR(Tb) {
    // dut_inst.clk(clk);
    // dut_inst.reset(reset);
    dut_inst.ui_in(ui_in);
    dut_inst.uo_out(uo_out);
    dut_inst.uio_in(uio_in);
    dut_inst.uio_out(uio_out);
    dut_inst.uio_oe(uio_oe);
    dut_inst.ena(ena);
    dut_inst.clk(clk);
    dut_inst.rst_n(rst_n);

    SC_THREAD(test);
  }

  void test() {
    ui_in.write(0);
    wait(SC_ZERO_TIME);
    std::cout << uo_out.read() << std::endl;
    sc_stop();
  }
};

int sc_main(int argc, char **argv) {
  Tb tb("tb");
  // sc_clock my_clock("clock", 10, SC_NS, 0.5, 0, SC_NS, false);
  // tb.clk(my_clock);
  sc_start();

  return 0;
}
