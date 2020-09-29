#!/bin/bash
 # 
 # Copyright (c) 2019-2020 Embedded Systems and Applications, TU Darmstadt.
 # This file is part of RT-LIFE
 # (see https://github.com/esa-tu-darmstadt/RT-LIFE).
 #
 # Permission is hereby granted, free of charge, to any person obtaining
 # a copy of this software and associated documentation files (the "Software"),
 # to deal in the Software without restriction, including without limitation
 # the rights to use, copy, modify, merge, publish, distribute, sublicense,
 # and/or sell copies of the Software, and to permit persons to whom the
 # Software is furnished to do so, subject to the following conditions:
 #
 # The above copyright notice and this permission notice shall be included
 # in all copies or substantial portions of the Software.
 #
 # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 # THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 # THE SOFTWARE.
 #
ifndef TAPASCO_RV_DIR
    $(error TAPASCO_RV_DIR not set)
endif

# GET fsm-settings.properties INFORMATION
dexieMemSize = 64

prep_sim_%: %_pe
	cp dexie_ip/esa.informatik.tu-darmstadt.de_dexie_$*_pe_dexie_1.0.zip tapasco-pe-tb/
	mv tapasco-pe-tb/esa.informatik.tu-darmstadt.de_dexie_$*_pe_dexie_1.0.zip tapasco-pe-tb/tapasco_pe_$*.zip

# Completely build simulation, only one manual step left: run make TEST=<testbench> in tapasco-pe-tb folder
%_sim: prep_sim_% binaries
	clear
	cd tapasco-pe-tb && $(MAKE) vivado_prj_$*

%_pe: package_core_%
	vivado -nolog -nojournal -mode batch -source $*_pe_dexie.tcl -tclargs --tapasco_riscv ${TAPASCO_RV_DIR} --dexieMemSize ${dexieMemSize}

# ILA taiga
# comment last line of taiga_pe_dexie.tcl
# open vivado project in taiga_pe and insert ila probes
# make finalizeTaiga
# create probes file: tapasco-compose --debugMode
# tapasco-load-bitstream
# sudo /opt/cad/xilinx/vivado/SDK/2018.3/bin/hw_server -d
# open vivado, connect to hw_server, insert probes
finalizeTaiga:
	vivado -nolog -nojournal -mode batch -source package_dexie_pe_taiga.tcl -tclargs --tapasco_riscv /home/wimi/cs/projects/tapasco-riscv --dexieMemSize ${dexieMemSize}

binaries:
	cd testPrograms && ./build.sh

package_core_flute32:
	cd core && $(MAKE) BSC_INCLUDES=':../ip/flute32/include' packageCore_flute32

package_core_piccolo32:
	cd core && $(MAKE) BSC_INCLUDES=':../ip/piccolo32/include' packageCore_piccolo32

package_core_%:
	cd core && $(MAKE) packageCore_$*

clean:
	rm -rf orca_pe
	rm -rf picorv32_pe
	rm -rf picorv32_formal_pe
	rm -rf piccolo32_pe
	rm -rf flute32_pe
	rm -rf vexriscv_pe
	rm -rf taiga_pe
	rm -rf dexie_ip
	rm -f tapasco-pe-tb/tapasco_pe.zip
	rm -rf tapasco-pe/simulate_testbench.*
	cd core && $(MAKE) clean
	cd testPrograms && $(MAKE) clean

