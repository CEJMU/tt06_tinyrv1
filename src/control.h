#ifndef CONTROL_H_
#define CONTROL_H_

#include <systemc.h>

SC_MODULE(control) {
  sc_in<bool> clk;
  sc_in<bool> reset;

  sc_in<sc_bv<32>> iword;
  sc_out<int> imm;

  sc_out<sc_bv<2>> instruction_type;
  sc_out<bool> wbflag;
  sc_out<bool> memflag;
  sc_out<bool> pcflag;

  SC_CTOR(control) {}
};

#endif // CONTROL_H_
