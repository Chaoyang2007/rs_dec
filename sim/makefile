VCS = vcs	-full64 -sverilog +v2k \
		-l elab.log \
		-debug_acc+all \
		-kdb -lca \
		+lint=TFIPC-L \
		-work work_dut 

SIM = ./simv 	+fsdb+functions \
		-ucli -i dump.tcl \
		-l irun.log 

VERDI = verdi	-full64 -dbdir ./simv.daidir

run:	comp sim

comp:
	$(VCS)	-f filelist.f

sim:
	$(SIM)
#	$(SIM)	-gui=verdi

verdi:
	$(VERDI)
#	$(VERDI) -ssf twave.fsdb

clean:
	rm -rf csrc simv* *.lib *.lib++ nLint* novas*
	rm -rf *.log *.key *.fsdb
	rm -rf verdiLog

