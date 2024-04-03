#ifndef CONSTANTS_H_
#define CONSTANTS_H_
#include <systemc.h>
using namespace sc_dt;

const sc_bv<7> OP_RTYPE = "0110011";
const sc_bv<7> OP_ITYPE = "0010011";
const sc_bv<7> OP_JUMP = "1100111";
const sc_bv<7> OP_BRANCH = "1100011";

// funct7 and funct3 fields for R-Type
const sc_bv<7> FUNCT7_ADD = "0000000";
const sc_bv<3> FUNCT3_ADD = "000";

const sc_bv<7> FUNCT7_AND = "0000000";
const sc_bv<3> FUNCT3_AND = "111";

const sc_bv<7> FUNCT7_OR = "0000000";
const sc_bv<3> FUNCT3_OR = "110";

const sc_bv<7> FUNCT7_XOR = "0000000";
const sc_bv<3> FUNCT3_XOR = "100";

const sc_bv<7> FUNCT7_SRA = "0100000";
const sc_bv<3> FUNCT3_SRA = "101";

const sc_bv<7> FUNCT7_SRL = "0000000";
const sc_bv<3> FUNCT3_SRL = "101";

const sc_bv<7> FUNCT7_SLL = "0000000";
const sc_bv<3> FUNCT3_SLL = "001";

// funct 3 for most immediate instructions
const sc_bv<3> FUNCT3_ADDI = "000";

// funct3 for branches
const sc_bv<3> FUNCT3_BNE = "001";

#endif // CONSTANTS_H_
