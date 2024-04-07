#ifndef CPU_H_
#define CPU_H_

#include "alu.h"
#include "control.h"
#include "instructioncounter.h"
#include "regs.h"
#include <systemc.h>

SC_MODULE(cpu) {
  sc_in<bool> clk;
  sc_in<bool> reset;

  sc_in<sc_bv<32>> iword;
  sc_out<sc_bv<14>> addr;
  // sc_in<bool> addr_ready;

  alu alu;
  regs regs;
  instructioncounter inst;
  control control;

  SC_CTOR(cpu) : alu("alu"), regs("regs"), inst("inst"), control("control") {}
};

#endif // CPU_H_
