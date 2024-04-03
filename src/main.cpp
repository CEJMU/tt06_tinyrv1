#include "alu.h"
#include "constants.h"
#include "regs.h"
#include <iostream>
#include <systemc.h>

SC_MODULE(Tb) {
  alu alu;
  sc_signal<bool> clk;
  sc_signal<bool> reset;
  sc_signal<int> a;
  sc_signal<int> b;
  sc_signal<int> rd;
  sc_signal<sc_bv<17>> instruction;

  regs regs;
  sc_signal<bool> clkRegs;
  sc_signal<bool> resetRegs;
  sc_signal<sc_bv<5>> rs1adr;
  sc_signal<sc_bv<5>> rs2adr;
  sc_signal<sc_bv<5>> rdadr;
  sc_signal<int> rdRegs;
  sc_signal<bool> regwrite;
  sc_signal<int> rs1;
  sc_signal<int> rs2;

  SC_CTOR(Tb) : alu("alu"), regs("regs") {

    alu.clk(clk);
    alu.reset(reset);
    alu.a(a);
    alu.b(b);
    alu.rd(rd);
    alu.instruction(instruction);

    regs.clk(clkRegs);
    regs.reset(resetRegs);
    regs.rs1adr(rs1adr);
    regs.rs2adr(rs2adr);
    regs.rdadr(rdadr);
    regs.rd(rdRegs);
    regs.regwrite(regwrite);
    regs.rs1(rs1);
    regs.rs2(rs2);

    rdadr.write("00000");
    rs1adr.write("00000");
    rs2adr.write("00000");
    regwrite.write(false);
    rd.write(0);

    SC_THREAD(test);
  }

  void test(){
    std::cout << "========== alu test ==========" << std::endl;
    clk.write(0);

    reset.write(0);
    a.write(15);
    b.write(5);
    instruction.write((FUNCT7_ADD, FUNCT3_ADD, OP_RTYPE));
    clk.write(1);
    wait(SC_ZERO_TIME);
    clk.write(0);
    wait(SC_ZERO_TIME);
    std::cout << "a + b = " << rd.read() << std::endl;

    a.write(5);
    b.write(1);
    instruction.write((FUNCT7_XOR, FUNCT3_XOR, OP_RTYPE));
    clk.write(1);
    wait(SC_ZERO_TIME);
    clk.write(0);
    wait(SC_ZERO_TIME);
    std::cout << "a ^ b = " << rd.read() << std::endl;

    a.write(5);
    b.write(1);
    instruction.write((FUNCT7_AND, FUNCT3_AND, OP_RTYPE));
    clk.write(1);
    wait(SC_ZERO_TIME);
    clk.write(0);
    wait(SC_ZERO_TIME);
    std::cout << "a & b = " << rd.read() << std::endl;

    std::cout << std::endl;

    std::cout << "========== regs test ==========" << std::endl;
    clkRegs.write(0);
    wait(SC_ZERO_TIME);

    resetRegs.write(0);
    rdadr.write(1);
    rdRegs.write(5);
    regwrite.write(1);
    clkRegs.write(1);
    wait(SC_ZERO_TIME);
    clkRegs.write(0);
    wait(SC_ZERO_TIME);

    rs1adr.write(1);
    regwrite.write(0);
    clkRegs.write(1);
    wait(SC_ZERO_TIME);
    clkRegs.write(0);
    wait(SC_ZERO_TIME);
    std::cout << "x1 = " << rs1.read() << std::endl;

    std::cout << std::endl;
  }
};

int sc_main(int argc, char **argv) {
  Tb tb("tb");
  sc_start();
  return 0;
}
