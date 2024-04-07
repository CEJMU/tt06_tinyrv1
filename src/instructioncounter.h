#ifndef INSTRUCTIONCOUNTER_H_
#define INSTRUCTIONCOUNTER_H_

#include <systemc.h>

SC_MODULE(instructioncounter) {
  sc_in<bool> clk;
  sc_in<bool> reset;

  sc_in<bool> pcflag;
  sc_in<bool> s0;
  sc_in<bool> s1;
  sc_in<sc_bv<16>> pc_offset;
  sc_out<sc_bv<16>> pc_new;

  SC_CTOR(instructioncounter) {}
};

#endif // INSTRUCTIONCOUNTER_H_
