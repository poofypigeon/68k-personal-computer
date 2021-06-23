GHDL = ghdl

USR_LIB     	= usrlib
VEC_TOOLS 		= vectools
ONE_HOT    		= onehot

USR_LIB_WORK    = --work=${USR_LIB}
VEC_TOOLS_WORK = --work=${VEC_TOOLS}
ONE_HOT_WORK    = --work=${ONE_HOT}

WORK_DIR = sim/
STD 	 = 93c

OPTS = --std=${STD} --workdir=${WORK_DIR}

# default - all libraries
lib : usr-lib-obj93.cf
# one_hot_type only
one_hot_type : one-hot-obj93.cf
# vector_tools only
vector_tools : vect-tools-obj93.cf

usr-lib-obj93.cf : one-hot-type.vhd vector-tools.vhd
	${GHDL} -i ${USR_LIB_WORK} ${OPTS} $^

one-hot-obj93.cf : one-hot-type.vhd
	${GHDL} -i ${ONE_HOT_WORK} ${OPTS} $^

vect-tools-obj93.cf : vector-tools.vhd
	${GHDL} -i ${VEC_TOOLS_WORK} ${OPTS} $^