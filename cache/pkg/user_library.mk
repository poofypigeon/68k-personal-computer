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

GHDL = ghdl
# object file names
USR_LIB   	= user_library
ENCODER   	= encoder
FLIP_FLOP   = flip_flop
ONE_HOT   	= one_hot
VTOOLS 		= vector_tools

# option values
WORK_DIR  	= obj/
STD 	 	= 93c

# option flags
OPTS = --std=${STD} --workdir=${WORK_DIR}

# default - all libraries
user_library : WORK = ${USR_LIB}
user_library : FILES = 	one-hot-type.vhd 	\
						vector-tools.vhd 	\
						encoder.vhd 		\
						flip-flop.vhd 		
user_library : ${WORK}-obj93.cf

# one_hot_type only
one_hot_type : WORK = ${ONE_HOT}
one_hot_type : FILES = one-hot-type.vhd
one_hot_type : ${WORK}-obj93.cf
# vector_tools only
vector_tools : WORK = ${VTOOLS}
vector_tools : FILES = vector-tools.vhd
vector_tools : ${WORK}-obj93.cf

# encoder only
encoder 	 : WORK = ${ENCODER}
encoder 	 : FILES = 	one-hot-type.vhd	\
						vector-tools.vhd 	\
						encoder.vhd
encoder 	 : ${WORK}-obj93.cf
# flip_flop only
flip_flop 	 : WORK = ${FLIP_FLOP}
flip_flop 	 : FILES = flip-flop.vhd
flip_flop 	 : ${WORK}-obj93.cf

# make directory if it doesn't exist
${WORK_DIR} :
	@echo "Making directory ${WORK_DIR}..."
	@mkdir ${WORK_DIR}

${WORK}-obj93.cf : ${WORK_DIR} ${FILES}
	@echo "Analyzing files...";
	@for file in ${FILES}; 								\
	do													\
		echo " > \033[0;36m$$file\033[0m" ; 			\
		${GHDL} -a --work=${WORK} ${OPTS} $$file ; 		\
	done ;
	@echo "Analysis finished : ${WORK_DIR}${WORK}-obj93.cf"

