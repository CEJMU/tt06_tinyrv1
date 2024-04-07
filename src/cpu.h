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

  // Regs
  sc_signal<sc_bv<5>> rs1adr; // iword[19:15]
  sc_signal<sc_bv<5>> rs2adr; // iword[24:20]
  sc_signal<sc_bv<5>> rdadr; // iword[11:7]
  sc_signal<int> rs1;
  sc_signal<int> rs2;
  sc_signal<int> rd;

  // Control flags
  sc_signal<bool> wbflag;
  sc_signal<bool> memflag;
  sc_signal<bool> pcflag;
  sc_signal<bool> s0;
  sc_signal<bool> s1;

  // Alu
  sc_signal<int> b; // Alu input. Either rs2 or imm
  sc_signal<sc_bv<17>> instruction;
  sc_signal<int> rd_alu;

  // Control
  sc_signal<int> imm;
  sc_signal<sc_bv<2>> instruction_type;

  // Inst
  sc_signal<sc_bv<16>> pc_out;
  sc_signal<sc_bv<16>> pc_offset;

  SC_CTOR(cpu) : alu("alu"), regs("regs"), inst("inst"), control("control") {
      SC_METHOD(update_signals);

      regs.clk(clk);
      regs.reset(reset);
      regs.rs1adr(rs1adr);
      regs.rs2adr(rs2adr);
      regs.rs1(rs1);
      regs.rs2(rs2);
      regs.rd(rd);
      regs.regwrite(wbflag);

      alu.clk(clk);
      alu.reset(reset);
      alu.a(rs1);
      alu.b(b);
      alu.instruction(instruction);
      alu.rd(rd_alu);

      control.clk(clk);
      control.reset(reset);
      control.imm(imm);
      control.instruction_type(instruction_type);
      control.iword(iword);
      control.wbflag(wbflag);
      control.memflag(memflag);
      control.pcflag(pcflag);

      inst.clk(clk);
      inst.reset(reset);
      inst.pcflag(pcflag);
      inst.s0(s0);
      inst.s1(s1);
      inst.pc_offset(pc_offset);
      inst.pc_new(pc_out);

  }

  void update_signals(){
      rs1adr.write(iword.read().range(19, 15));
      rs2adr.write(iword.read().range(24, 20));
      rdadr.write(iword.read().range(11, 7));
      instruction.write((iword.read().range(31, 25), iword.read().range(14, 12), iword.read().range(6, 0)));
      pc_offset.write(((sc_bv<32>) imm).range(15, 0));

      if (instruction_type.read() == "11") {
        s0.write(((sc_bv<32>)rd_alu).get_bit(16));
        s1.write(((sc_bv<32>)rd_alu).get_bit(17));
      } else {
        s0.write(0);
        s1.write(1);
      }

      addr.write(pc_out.read().range(15, 2));

      // TODO b.write()

  }
};

#endif // CPU_H_
