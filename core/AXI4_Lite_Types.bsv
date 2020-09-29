package AXI4_Lite_Types;
/* 
 * Copyright (c) 2015-2020 Embedded Systems and Applications, TU Darmstadt.
 * This file is part of RT-LIFE
 * (see https://github.com/esa-tu-darmstadt/RT-LIFE).
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/*
=============
	Types
=============
*/

typedef enum {
		OKAY = 2'b00,
		EXOKAY = 2'b01,
		SLVERR = 2'b10,
		DECERR = 2'b11
	} AXI4_Lite_Response deriving(Bits, Eq, FShow);

typedef enum {
		UNPRIV_SECURE_DATA = 3'b000,
		UNPRIV_SECURE_INSTRUCTION = 3'b001,
		UNPRIV_INSECURE_DATA = 3'b010,
		UNPRIV_INSECURE_INSTRUCTION = 3'b011,
		PRIV_SECURE_DATA = 3'b100,
		PRIV_SECURE_INSTRUCTION = 3'b101,
		PRIV_INSECURE_DATA = 3'b110,
		PRIV_INSECURE_INSTRUCTION = 3'b111
	} AXI4_Lite_Prot deriving(Bits, Eq, FShow);

typedef struct {
		Bit#(addrwidth) addr;
		AXI4_Lite_Prot prot;
	} AXI4_Lite_Read_Rq_Pkg#(numeric type addrwidth) deriving(Bits, Eq, FShow);

typedef struct {
		Bit#(datawidth) data;
		AXI4_Lite_Response resp;
	} AXI4_Lite_Read_Rs_Pkg#(numeric type datawidth) deriving(Bits, Eq, FShow);

typedef struct {
		Bit#(addrwidth) addr;
		Bit#(datawidth) data;
		Bit#(TDiv#(datawidth, 8)) strb;
		AXI4_Lite_Prot prot;
	} AXI4_Lite_Write_Rq_Pkg#(numeric type addrwidth, numeric type datawidth) deriving(Bits, Eq, FShow);

typedef struct {
		AXI4_Lite_Response resp;
	} AXI4_Lite_Write_Rs_Pkg deriving(Bits, Eq, FShow);

/*
=============
	Generic AXI4 Lite Slave Types
=============
*/

typedef struct {
        Bit#(addr_width) index;
        function Action _(Bit#(data_width) d, Bit#(TDiv#(data_width, 8)) s, AXI4_Lite_Prot p) fun;
    } WriteOperation#(numeric type addr_width, numeric type data_width) deriving(Bits, FShow);

instance Eq#(WriteOperation#(addr_width, data_width));
    function Bool \== (WriteOperation#(addr_width, data_width) x, WriteOperation#(addr_width, data_width) y);
        return x.index == y.index;
    endfunction

    function Bool \/= (WriteOperation#(addr_width, data_width) x, WriteOperation#(addr_width, data_width) y);
        return !(x == y);
    endfunction
endinstance

typedef struct {
        Bit#(addr_width) index_min;
        Bit#(addr_width) index_max;
        function Action _(Bit#(addr_width) addr, Bit#(data_width) d, Bit#(TDiv#(data_width, 8)) s, AXI4_Lite_Prot p) fun;
    } WriteOperationRange#(numeric type addr_width, numeric type data_width) deriving(Bits, FShow);

instance Eq#(WriteOperationRange#(addr_width, data_width));
    function Bool \== (WriteOperationRange#(addr_width, data_width) x, WriteOperationRange#(addr_width, data_width) y);
        return x.index_min == y.index_min && x.index_min == x.index_max;
    endfunction

    function Bool \/= (WriteOperationRange#(addr_width, data_width) x, WriteOperationRange#(addr_width, data_width) y);
        return !(x == y);
    endfunction
endinstance

typedef struct {
        Bit#(addr_width) index;
        function ActionValue#(Bit#(data_width)) _(AXI4_Lite_Prot p) fun;
    } ReadOperation#(numeric type addr_width, numeric type data_width) deriving(Bits, FShow);

instance Eq#(ReadOperation#(addr_width, data_width));
    function Bool \== (ReadOperation#(addr_width, data_width) x, ReadOperation#(addr_width, data_width) y);
        return x.index == y.index;
    endfunction

    function Bool \/= (ReadOperation#(addr_width, data_width) x, ReadOperation#(addr_width, data_width) y);
        return !(x == y);
    endfunction
endinstance

typedef struct {
        Bit#(addr_width) index_min;
        Bit#(addr_width) index_max;
        function ActionValue#(Bit#(data_width)) _(Bit#(addr_width) addr, AXI4_Lite_Prot p) fun;
    } ReadOperationRange#(numeric type addr_width, numeric type data_width) deriving(Bits, FShow);

instance Eq#(ReadOperationRange#(addr_width, data_width));
    function Bool \== (ReadOperationRange#(addr_width, data_width) x, ReadOperationRange#(addr_width, data_width) y);
        return x.index_min == y.index_min && x.index_min == x.index_max;
    endfunction

    function Bool \/= (ReadOperationRange#(addr_width, data_width) x, ReadOperationRange#(addr_width, data_width) y);
        return !(x == y);
    endfunction
endinstance

typedef struct {
        Bit#(addr_width) index_min;
        Bit#(addr_width) index_max;
        function Action _(Bit#(addr_width) addr, AXI4_Lite_Prot p) fun;
        function ActionValue#(Bit#(data_width)) _() ret;
    } ReadOperationRangeDelayed#(numeric type addr_width, numeric type data_width) deriving(Bits, FShow);

instance Eq#(ReadOperationRangeDelayed#(addr_width, data_width));
    function Bool \== (ReadOperationRangeDelayed#(addr_width, data_width) x, ReadOperationRangeDelayed#(addr_width, data_width) y);
        return x.index_min == y.index_min && x.index_min == x.index_max;
    endfunction

    function Bool \/= (ReadOperationRangeDelayed#(addr_width, data_width) x, ReadOperationRangeDelayed#(addr_width, data_width) y);
        return !(x == y);
    endfunction
endinstance

typedef struct {
        Bit#(addr_width) index_min;
        Bit#(addr_width) index_max;
        function Action _(Bit#(addr_width) addr, Bit#(data_width) d, Bit#(TDiv#(data_width, 8)) s, AXI4_Lite_Prot p) fun;
        function Action _() ret;
    } WriteOperationRangeDelayed#(numeric type addr_width, numeric type data_width) deriving(Bits);

instance Eq#(WriteOperationRangeDelayed#(addr_width, data_width));
    function Bool \== (WriteOperationRangeDelayed#(addr_width, data_width) x, WriteOperationRangeDelayed#(addr_width, data_width) y);
        return x.index_min == y.index_min && x.index_min == x.index_max;
    endfunction

    function Bool \/= (WriteOperationRangeDelayed#(addr_width, data_width) x, WriteOperationRangeDelayed#(addr_width, data_width) y);
        return !(x == y);
    endfunction
endinstance

typedef union tagged {
    WriteOperation#(addr_width, data_width) Write;
    WriteOperationRange#(addr_width, data_width) WriteRange;
    WriteOperationRangeDelayed#(addr_width, data_width) WriteRangeDelayed;
    ReadOperation#(addr_width, data_width) Read;
    ReadOperationRange#(addr_width, data_width) ReadRange;
    ReadOperationRangeDelayed#(addr_width, data_width) ReadRangeDelayed;
} RegisterOperator#(numeric type addr_width, numeric type data_width) deriving(Bits, Eq, FShow);


endpackage