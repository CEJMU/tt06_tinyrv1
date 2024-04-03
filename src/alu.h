#ifndef ALU_H_
#define ALU_H_

#include "constants.h"
#include <systemc.h>

SC_MODULE(alu) {
  sc_in<bool> clk;
  sc_in<bool> reset;

  sc_in<int> a;
  sc_in<int> b;
  sc_in<sc_bv<17>> instruction;

  sc_out<int> rd;

  sc_bv<7> opcode;
  sc_bv<7> funct7;
  sc_bv<3> funct3;

  SC_CTOR(alu)
      : clk("clk"), reset("reset"), a("a"), b("b"), instruction("instruction"),
        rd("rd") {
    SC_METHOD(process);
    sensitive << clk.pos() << reset;
  }

  void process() {
    if (reset) {
      // do reset
      rd.write(0);
    } else if (clk.posedge()) {
      opcode = instruction.read().range(6, 0);
      funct7 = instruction.read().range(16, 10);
      funct3 = instruction.read().range(9, 7);

      // ADD | ADDI
      if ((funct7 == FUNCT7_ADD && funct3 == FUNCT3_ADD &&
           opcode == OP_RTYPE) ||
          (funct3 == FUNCT3_ADDI && opcode == OP_ITYPE)) {
        rd.write(a.read() + b.read());
      }
      // AND
      else if (funct7 == FUNCT7_AND && funct3 == FUNCT3_AND &&
               opcode == OP_RTYPE) {
        rd.write(a.read() & b.read());
      }
      // XOR
      else if (funct7 == FUNCT7_XOR && funct3 == FUNCT3_XOR &&
               opcode == OP_RTYPE) {
        rd.write(a.read() ^ b.read());
      }
      // JAL
      else if (opcode == OP_JUMP) {
        sc_bv<14> upper = "000000000000";
        sc_bv<2> s1s0 = "00";
        sc_bv<16> lower = "0000000000000000";
        rd.write((upper, s1s0, lower).to_int());
      }
      /* // JR */
      /* else if (opcode == OP_JUMP) { */
      /* } */
      // BNE
      else if (funct3 == FUNCT3_BNE && opcode == OP_BRANCH) {
        sc_bv<14> upper = "000000000000";
        sc_bv<2> s1s0;
        sc_bv<16> lower = "0000000000000000";

        if (a == b) {
          s1s0 = "10";
        } else {
          s1s0 = "00";
        }
        rd.write((upper, s1s0, lower).to_int());
      }
    }
  }
};

#endif // ALU_H_
