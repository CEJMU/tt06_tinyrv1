#include "cpu.h"
#include <systemc.h>

SC_MODULE(cpu_tb) {
  cpu dut{"dut"};

  sc_clock clk{"clk", 10, SC_NS, 0.5};
  sc_signal<bool> reset{"reset"};
  sc_signal<sc_bv<32>> iword{"iword"};
  sc_signal<sc_bv<14>> addr{"addr"};

  sc_bv<32> program[10] = {
      "0x93005000", "0x33011000", "0xB3011102", "0x23223000", "0x03224000",
      "0xE39600FE", "0xB3021102", "0xB3021102", "0xB3021102", "0xB3021102"};

  SC_CTOR(cpu_tb) {
    dut.clk(clk);
    dut.reset(reset);
    dut.iword(iword);
    dut.addr(addr);

    SC_THREAD(cpu_test);
  }

  void cpu_test() {
    sc_trace_file *waveform = sc_create_vcd_trace_file("cpu_tb.vcd");
    sc_trace(waveform, clk, "clk");
    sc_trace(waveform, reset, "reset");
    sc_trace(waveform, iword, "iword");
    sc_trace(waveform, addr, "addr");
    sc_trace(waveform, dut.rd_alu, "rd_alu");

    for (int i = 0; i <= 100; i++) {
      iword.write(program[addr.read().to_uint()]);
      // wait(SC_ZERO_TIME);
      wait(clk.posedge_event());
    }

    sc_stop();
    sc_close_vcd_trace_file(waveform);
  }
};

int sc_main(int argc, char **argv) {
  cpu_tb tb{"tb"};

  sc_start();
  return 0;
}
