SRC_PATH = ../
LIB_PATH = ../pkg/
LIB_OBJ	 = ../pkg/obj/

LIB_MAKE = user_library.mk

vpath %.vhd ${SRC_PATH}
vpath %.cf  ${LIB_PATH}

GHDL = ghdl

# OPTS
WORK_DIR 	= sim/
STD 	 	= 93c

# option flags
OPTS = --std=${STD} --workdir=${WORK_DIR} -P=${LIB_OBJ}

# RUN_OPTS
STOP_TIME 	= 200ns
ASSERT 	  	= error
FST 	  	= out.fst

LIB = user_library-obj93.cf
FILES = cache-block.vhd valid-policy.vhd plru-policy.vhd cache-set.vhd

work-obj93.cf : ${LIB} ${FILES}
	@echo "Analyzing files...";
	@for file in ${FILES}; 								\
	do													\
		echo " > \033[0;36m$$file\033[0m" ; 			\
		${GHDL} -a ${OPTS} ${SRC_PATH}$$file ; 			\
	done ;
	@echo "Analysis finished : ${WORK_DIR}${WORK}-obj93.cf"

# make directory if it doesn't exist
${WORK_DIR} :
	@echo "Making directory ${WORK_DIR}..."
	@mkdir ${WORK_DIR}

${LIB} :
	@echo "Building ${LIB}..."
	@(cd ${LIB_PATH} && make -f ${LIB_MAKE})
