#include <systemc>
using namespace sc_core;

SC_MODULE(tt_um_test_nand) {
  sc_in<sc_dt::sc_bv<8>> ui_in;
  sc_out<sc_dt::sc_bv<8>> uo_out;
  sc_in<sc_dt::sc_bv<8>> uio_in;
  sc_out<sc_dt::sc_bv<8>> uio_out;
  sc_out<sc_dt::sc_bv<8>> uio_oe;
  sc_in<bool> ena;
  sc_in<bool> clk;
  sc_in<bool> rst_n;

  SC_CTOR(tt_um_test_nand) {
    SC_METHOD(process);
    sensitive << ui_in << uio_in << ena << clk << rst_n;
  }

  void process() {
      sc_dt::sc_bv<4> test;
      uo_out.write(!(ui_in.read()[0] && ui_in.read()[1]));
      uio_out.write(0);
      uio_oe.write(0);
  }
};
