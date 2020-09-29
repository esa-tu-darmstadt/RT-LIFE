package DExIE_Info;

import ISA_Decls::*;

typedef struct {
   WordXL    pc;
   Bit#(32)  instr;
   WordXL    next_pc;
} Dexie_CFData deriving (Bits);

typedef struct {
   WordXL    pc;
   Bool      load;
   Bool      store;
   Addr      addr;
   Bit#(2)   len;
   WordXL    storeval;
   Bool      stalling;
} Dexie_DFMemData deriving (Bits);

typedef struct {
   WordXL    pc;
   Bit#(5)   r_dest;
   WordXL    r_data;
} Dexie_DFRegData deriving (Bits);

endpackage
