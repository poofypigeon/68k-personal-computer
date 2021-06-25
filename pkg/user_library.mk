# > make [user_library]
# 		build full user library
# > make one_hot
# 		build library for one_hot only
# > make vector_tools
# 		build library for vector_tools only
# > make encoder
# 		build library for encoder and its dependencies (one_hot, vector_tools)
# > make flip_flop
# 		build library for flip_flop and its dependency (vector_tools)
# TODO these options could be moved to a README file

# VHDL compiler
GHDL = ghdl

# option values
STD = 93c

# option flags
OPTS = --std=$(STD)

# default - all libraries
user_library : WORK = user_library
user_library : FILES = 	one-hot.vhd 					\
						vector-tools.vhd 				\
						encoder.vhd 					\
						flip-flop.vhd 		
user_library : $(WORK)-obj93.cf

one_hot : WORK = one_hot
one_hot : FILES = one-hot.vhd
one_hot : $(WORK)-obj93.cf

vector_tools : WORK = vector_tools
vector_tools : FILES = vector-tools.vhd
vector_tools : $(WORK)-obj93.cf

encoder 	 : WORK = encoder
encoder 	 : FILES = 	one-hot.vhd						\
						vector-tools.vhd 				\
						encoder.vhd
encoder 	 : $(WORK)-obj93.cf

flip_flop 	 : WORK = flip_flop
flip_flop 	 : FILES = flip-flop.vhd
flip_flop 	 : $(WORK)-obj93.cf

# analysis
$(WORK)-obj93.cf : $(FILES)
	@echo "Analyzing files...";
	@for file in $(FILES); 								\
	do													\
		echo " > \033[0;36m$$file\033[0m" ; 			\
		$(GHDL) -a --work=$(WORK) $(OPTS) $$file ; 		\
	done ;
	@echo "Analysis finished : $(WORK)-obj93.cf"

