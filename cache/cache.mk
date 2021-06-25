# > make [work]
# 		build all modules
# > make cache_block
# 		build cache-block.vhd only
# > make plru_policy
# 		build plru-policy.vhd only
# > make valid_policy
# 		build valid-policy.vhd only
# > make flip_flop
# 		build library for flip_flop and its dependencies 
# 		(cache-block.vhd, plru-policy.vhd, valid-policy.vhd)
# TODO these options could be moved to a README file

# library dependency
LIB = user_library-obj93.cf
LIB_PATH = pkg/
LIB_MAKE = user_library.mk

vpath %.cf ${LIB_PATH}

# VHDL compiler
GHDL = ghdl

# option values
STD = 93c

# option flags
OPTS = --std=${STD} -P=${LIB_PATH}

# object file names
CACHE_BLOCK  	= cache_block
PLRU_POLICY  	= plru_policy
VALID_POLICY 	= valid_policy
CACHE_SET    	= cache_set

# default - build all files
work : WORK 	= work
work : FILES 	= cache-block.vhd 						\
				  valid-policy.vhd 						\
				  plru-policy.vhd 						\
				  cache-set.vhd
work : work-obj93.cf

cache_block : WORK 	= ${CACHE_BLOCK}
cache_block : FILES = cache-block.vhd
cache_block : cache_block-obj93.cf

plru_policy : WORK 	= ${PLRU_POLICY}
plru_policy : FILES = plru-policy.vhd
plru_policy : plru_policy-obj93.cf

valid_policy : WORK = ${VALID_POLICY}
valid_policy : FILES = valid-policy.vhd
valid_policy : valid_policy-obj93.cf

cache_set : WORK = ${CACHE_SET}
cache_set : FILES = cache-block.vhd 					\
					valid-policy.vhd 					\
					plru-policy.vhd 					\
					cache-set.vhd
cache_set : cache_set-obj93.cf

# build library dependancy
${LIB} :
	@echo "Building ${LIB}..."
	@(cd ${LIB_PATH} && make -f ${LIB_MAKE})

# analysis
%-obj93.cf : ${LIB} ${FILES}
	@echo "Analyzing files...";
	@for file in ${FILES};								\
	do													\
		echo " > \033[0;36m$$file\033[0m" ; 			\
		${GHDL} -a --work=${WORK} ${OPTS} $$file ; 		\
	done ;
	@echo "Analysis finished : ${WORK}-obj93.cf"