#ifndef REGS_H_
#define REGS_H_

#include <iostream>
#include <systemc.h>

SC_MODULE(regs) {
  sc_in<bool> clk;
  sc_in<bool> reset;

  sc_in<sc_bv<5>> rs1adr;
  sc_in<sc_bv<5>> rs2adr;
  sc_in<sc_bv<5>> rdadr;

  sc_in<int> rd;
  sc_in<bool> regwrite;

  sc_out<int> rs1;
  sc_out<int> rs2;

  SC_CTOR(regs) {
    SC_METHOD(process);
    sensitive << clk.pos() << reset;
  }

  void process() {
    if (reset) {
      rs1.write(0);
      rs2.write(0);
    } else if (clk.posedge()) {
      // Writing
      if (regwrite && rdadr.read().to_uint() != 0) {
        registers[rdadr.read().to_uint() - 1] = rd.read();
      }

      // Reading rs1
      if (rs1adr.read().to_uint() != 0) {
        rs1.write(registers[rs1adr.read().to_uint() - 1]);
      } else {
        rs1.write(0);
      }

      // Reading rs2
      if (rs2adr.read().to_uint() != 0) {
        rs2.write(registers[rs2adr.read().to_uint() - 1]);
      } else {
        rs2.write(0);
      }
    }
  }

private:
  int registers[31];
};

#endif // REGS_H_
