make : 
	ghdl -a flip-flop.vhd
	ghdl -a plru-policy.vhd
	ghdl -a test/plru-policy-tb.vhd

	ghdl -e t_flip_flop
	ghdl -e plru_node
	ghdl -e plru_root
	ghdl -e plru_recursive
	ghdl -e plru_policy
	ghdl -e plru_policy_tb

.PHONY : test

test :
	ghdl -r plru_policy_tb --fst=out.fst --stop-time=50us