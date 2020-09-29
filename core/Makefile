#!/bin/bash


# Directories
VERILOGDIR=${BLUESPECDIR}/Verilog

ifndef BLUESPECDIR
	$(error BLUESPECDIR is not set)
endif

BSC_MACROS+=\
-steps-max-intervals 5000000

packageCore_%: buildDexieCoreWrapper_%
	vivado -nolog -nojournal -mode batch -source ../dexie_ip.tcl -tclargs $*
	rm -rf dummy*

Test%:	clean
	#clear
	bsc $(BSC_MACROS) -u -sim -g mk$@ $@.bsv
	bsc -sim -o $@ -e mk$@
	rm *.bo *.c* *.h *.ba *.o

showVariables:
	@echo "GLOBAL_MAX_TOTAL_STATES is"$(GLOBAL_MAX_TOTAL_STATES)
	@echo "GlobalFmSize is"$(GlobalFmSize)
	@echo "AcSize is"$(AcSize)
	@echo "BranchTableSize is"$(BranchTableSize)
	@echo "TTSize is"$(TTSize)
	@echo "DexieMemSize is"$(DexieMemSize)
build%:
	bsc $(BSC_MACROS) -p $(BSC_INCLUDES):+ -u -verilog -show-range-conflict -g mk$* $*.bsv
	mkdir -p IP
	rm -f IP/mk*.v
	cp -f mk$*.v IP/
	cp $(VERILOGDIR)/RegFile.v $(VERILOGDIR)/SizedFIFO.v $(VERILOGDIR)/BRAM1.v $(VERILOGDIR)/BRAM2.v  $(VERILOGDIR)/FIFO2.v IP/

clean:
	@rm -rf IP
	@rm -f dump.vcd
	@rm -f $(FSM_CONFIG_FILE)
	@rm -f *.ba *.*o *.h *.cxx *.v
	@find . -maxdepth 1 -type f -executable -delete
	@echo "make clean successful"
