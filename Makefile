# FIXME structure this all better and comments n' stuff
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

# VHDL compiler
GHDL = ghdl

# option values
STD = 93c

# option flags
OPTS = --std=$(STD) -P=$(LIB_PATH)

# default - build all files
cache : WORK 	= work
cache : FILES 	= cache-block.vhd 						\
				  valid-policy.vhd 						\
				  plru-policy.vhd 						\
				  cache-set.vhd
cache : $(WORK)-obj93.cf

# build all files and tests
testing : WORK 	= tests
testing : STIM  = 
testing : FILES = cache-block.vhd 						\
				  valid-policy.vhd 						\
				  plru-policy.vhd 						\
				  cache-set.vhd							\
				  test/cache-block-tb.vhd				\
				  test/plru-policy-tb.vhd				\
				  test/valid-policy-tb.vhd
testing : $(WORK)-obj93.cf

cache_block : WORK 	= cache_block
cache_block : FILES = cache-block.vhd
cache_block : $(WORK)-obj93.cf

plru_policy : WORK 	= plru_policy
plru_policy : FILES = plru-policy.vhd
plru_policy : $(WORK)-obj93.cf

valid_policy : WORK = valid_policy
valid_policy : FILES = valid-policy.vhd
valid_policy : $(WORK)-obj93.cf

cache_set : WORK = cache_set
cache_set : FILES = cache-block.vhd 					\
					valid-policy.vhd 					\
					plru-policy.vhd 					\
					cache-set.vhd
cache_set : $(WORK)-obj93.cf

# TODO Generate stimulus from script automagically (may be in old commits)


.PHONY : run

run : # FIXME
	ghdl -r --work=tests -P=pkg plru_policy_tb --stop-time=200ns

# build library dependancy
$(LIB) :
	@echo "Building $(LIB)..."
	@(cd $(LIB_PATH) && make -f $(LIB_MAKE))

# analysis
$(WORK)-obj93.cf : $(LIB) $(FILES)
	@echo "Analyzing files...";
	@for file in $(FILES);								\
	do													\
		echo " > \033[0;36m$$file\033[0m" ; 			\
		$(GHDL) -a --work=$(WORK) $(OPTS) $$file ; 		\
	done ;
	@echo "Analysis finished : $(WORK)-obj93.cf"