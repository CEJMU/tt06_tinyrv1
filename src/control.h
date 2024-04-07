#ifndef CONTROL_H_
#define CONTROL_H_

#include <systemc.h>
#include <constants.h>

SC_MODULE(control) {
  sc_in<bool> clk;
  sc_in<bool> reset;

  sc_in<sc_bv<32>> iword;
  sc_out<int> imm;

  sc_out<sc_bv<2>> instruction_type_out;
  sc_out<bool> wbflag;
  sc_out<bool> memflag;
  sc_out<bool> pcflag;
  sc_out<sc_bv<3>> control_flags_out;

  sc_signal<sc_bv<2>> instruction_type;

  //reg_write[0] imm_as_a[1] jump[2]
  sc_signal<sc_bv<3>> control_flags_internal; 

  enum statedef {rst, fetch, decode, execute, memory, writeback};
  sc_signal<statedef> state;


  SC_CTOR(control) : clk("clk"), reset("reset"), iword("iword"), imm("imm"), instruction_type("instruction_type"),
  wbflag("wbflag"), memflag("memflag"), pcflag("pcflag"), control_flags_out("control_flags_out"){
    SC_METHOD(process);
    sensitive << clk.pos() << reset;

    SC_METHOD(Control_flags_1);
    SC_METHOD(Control_flags_2);
    SC_METHOD(I_B_J_Immediate);
  }

  void process(){

      if(reset){
        state.write(rst);
      }else if(clk.posedge()){
        if(state.read() == rst){
            state.write(fetch);

        }else if(state.read() == writeback){
          state.write(fetch);

        }else if(state.read() == fetch){
          state.write(decode);

        }else if(state.read() == decode){
          state.write(execute);

        }else if(state.read() == execute && (control_flags_internal.read()[0] == "0")){
          state.write(memory);
        }else if(state.read() == memory || state.read() == execute &&(control_flags_internal.read()[0] == "0")){
          state.write(writeback);
        }
      };
  }

// Control flags
  void Control_flags_1(){

    if(state.read() == execute && (instruction_type.read() == "00" || instruction_type.read() == "11")){
      pcflag.write(1);
    }else{
      pcflag.write(0);
    }

    if(state.read() == execute && instruction_type.read() == "01"){
      memflag.write(1);
    }else{
      memflag.write(0);
    }

    if((state.read() == execute && instruction_type.read() == "00")){
      wbflag.write(1);
    }else{
      wbflag.write(0);
    }
  }

  void Control_flags_2(){
    sc_bv<3> zw = "000";
    control_flags_out.write(control_flags_internal); 
    if(iword.read().range(6,0) == OP_BRANCH){
      zw = control_flags_internal.read();
      zw[0] = 0;    //reg_write[0]
      control_flags_internal.write(zw);
    }else{
      zw = control_flags_internal.read();
      zw[0] = 1;   //reg_write[0]
      control_flags_internal.write(zw);
    }
    if(iword.read().range(6,0) == OP_ITYPE || iword.read().range(6,0) == OP_JUMP){
      zw = control_flags_internal.read();
      zw[1] = 1;  //imm_as_a[1]
      control_flags_internal.write(zw);
    }else{        //imm_as_a[1]
      zw = control_flags_internal.read();
      zw[1] = 0; 
      control_flags_internal.write(zw);
    }
    if(iword.read().range(6,0) == OP_BRANCH || iword.read().range(6,0) == OP_JUMP){
      zw = control_flags_internal.read();
      zw[2] = 1;  //jump[2]
      control_flags_internal.write(zw);
    }else{
      zw = control_flags_internal.read();
      zw[2] = 0;  //jump[2]
      control_flags_internal.write(zw);
    }
  }

  void I_B_J_Immediate(){
    sc_bv<21> msb = "0000000000000000000000"; 
    if(iword.read()[31]){
    sc_bv<21> msb = "1111111111111111111111"; 
    }
    if(iword.read().range(6,0) == OP_ITYPE){
      imm.write((msb,iword.read().range(30,25),iword.read().range(24,20)).to_int()); // I-Type
    }else if(iword.read().range(6,0) == OP_BRANCH){
      imm.write((msb.range(20,1),iword.read()[7], iword.read().range(30,25), iword.read().range(11,8),"0" ).to_int()); // B-Type
    }else if(iword.read().range(6,0) == OP_JUMP){
      imm.write((msb.range(11,0), iword.read().range(19,12), iword.read()[20], iword.read().range(30,25), iword.read().range(24,21), "0").to_int()); //J-Type
    }


  }
  

};

#endif // CONTROL_H_
