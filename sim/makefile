VCS = vcs top.sv	-full64 -sverilog +v2k \
			-l elab.log \
			-debug_acc+all \
			-kdb -lca \
			+lint=TFIPC-L \
			-work work_dut

VERDI = ./simv 	+fsdb+functions \
		-ucli -i dump.tcl \
		-l irun.log \
		-gui=verdi

comp:
	$(VCS)

verdi:
	$(VERDI)

clean:
	rm -rf csrc simv* *.lib *.lib++ nLint* novas*
	rm -rf *.log *.key *.fsdb
	rm -rf verdiLog

