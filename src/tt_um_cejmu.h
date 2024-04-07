#ifndef TT_UM_CEJMU_H_
#define TT_UM_CEJMU_H_

#include "cpu.h"
#include <systemc.h>

SC_MODULE(tt_um_cejmu) {
  sc_in<sc_bv<8>> ui_in;    // Dedicated inputs
  sc_out<sc_bv<8>> uo_out;  // Dedicated outputs
  sc_in<sc_bv<8>> uio_in;   // IOs: Input path
  sc_out<sc_bv<8>> uio_out; // IOs: Output path
  sc_out<sc_bv<8>> uio_oe;  // IOs: Enable path (0=input, 1=output)
  sc_in<bool> ena;          // High when the design is enabled
  sc_in<bool> clk;
  sc_in<bool> rst_n; // active low

  cpu cpu;

  SC_CTOR(tt_um_cejmu) : cpu("cpu") {}
};

#endif // TT_UM_CEJMU_H_
