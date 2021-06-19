make : 
	ghdl -a ../lib/flip-flop.vhd
	ghdl -a plru-policy.vhd
	ghdl -a test/replacement-policy-tb.vhd

	ghdl -e t_flip_flop
	ghdl -e plru_node
	ghdl -e plru_root
	ghdl -e plru_branch
	ghdl -e plru_tree
	ghdl -e plru_tree_tb

	