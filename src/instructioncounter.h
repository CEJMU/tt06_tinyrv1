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

  sc_signal<sc_bv<16>> zw; 

  SC_CTOR(instructioncounter) :clk("clk"), reset("reset"), pcflag("pcflag"), s0("s0"), s1("s1"),
  pc_offset("pc_offset"), pc_new("pc_new"){

    SC_METHOD(process);
    sensitive << clk << reset;

    SC_METHOD(concurrent_assignments);
  }

  void process(){
    if(clk.posedge()){
      if(reset){
        zw.write("0000000000000000");
      }else if(pcflag){
        
        if(!s0 && !s1){
          sc_int<16> x =(sc_int<16>) zw.read() + (sc_int<16>)pc_offset.read();
          zw.write(x);
        }else if(s1 && !s0){
          sc_int<16> x = (sc_int<16>) zw.read() + 4;
          zw.write(x);
        }else if(!s1 && s0){
          zw.write(pc_offset);
        }
      }
    }
  }

  void concurrent_assignments(){
    pc_new.write(zw);
  }
};

#endif // INSTRUCTIONCOUNTER_H_
