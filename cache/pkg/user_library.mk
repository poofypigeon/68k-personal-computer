# > make [user_library]
# 		build full user library
# > make one_hot_type
# 		build library for one_hot_type only
# > make vector_tools
# 		build library for vector_tools only
# > make encoder
# 		build library for encoder and its dependencies (one_hot_type, vector_tools)
# > make flip_flop
# 		build library for flip_flop and its dependency (vector_tools)
# TODO these options could be moved to a README file

# VHDL compiler
GHDL = ghdl

# object file names
USR_LIB   	= user_library
ENCODER   	= encoder
FLIP_FLOP   = flip_flop
ONE_HOT   	= one_hot
VTOOLS 		= vector_tools
# option values
STD = 93c

# option flags
OPTS = --std=${STD}

# default - all libraries
user_library : WORK = ${USR_LIB}
user_library : FILES = 	one-hot-type.vhd 	\
						vector-tools.vhd 	\
						encoder.vhd 		\
						flip-flop.vhd 		
user_library : user_library-obj93.cf

one_hot_type : WORK = ${ONE_HOT}
one_hot_type : FILES = one-hot-type.vhd
one_hot_type : one_hot_type-obj93.cf

vector_tools : WORK = ${VTOOLS}
vector_tools : FILES = vector-tools.vhd
vector_tools : vector_tools-obj93.cf

encoder 	 : WORK = ${ENCODER}
encoder 	 : FILES = 	one-hot-type.vhd	\
						vector-tools.vhd 	\
						encoder.vhd
encoder 	 : encoder-obj93.cf

flip_flop 	 : WORK = ${FLIP_FLOP}
flip_flop 	 : FILES = flip-flop.vhd
flip_flop 	 : flip_flop-obj93.cf

# analysis
%-obj93.cf : ${FILES}
	@echo "Analyzing files...";
	@for file in ${FILES}; 									\
	do													\
		echo " > \033[0;36m$$file\033[0m" ; 			\
		${GHDL} -a --work=${WORK} ${OPTS} $$file ; 		\
	done ;
	@echo "Analysis finished : ${WORK}-obj93.cf"

