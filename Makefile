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

# VHDL compiler
GHDL = ghdl

# library dependencies
LIB = user_library-obj93.cf
LIB_MAKE = user_library.mk

# stimulus dependencies
STIM_FOLDER 		= test/stimulus/
vpath %.py $(STIM_FOLDER)
STIM_FILES 			= plru.stim
STIM_SCRIPTS_PATH 	= scripts/
STIM_SCRIPTS 		= plru-stim-gen.py

# option values
STD = 93c
LIB_PATH = pkg/

# option flags
GHDL_OPTS = --std=$(STD) -P=$(LIB_PATH)

.PHONY : work run stim

# build all files and tests
work : FILES = cache-block.vhd 																	\
				  valid-policy.vhd 																\
				  plru-policy.vhd 																\
				  cache-set.vhd																	\
				  test/cache-block-tb.vhd														\
				  test/plru-policy-tb.vhd														\
				  test/valid-policy-tb.vhd
work : work-obj93.cf

run : # FIXME
	ghdl -r -P=pkg plru_policy_tb --stop-time=200ns

# build library dependancy
$(LIB) :
	@(cd $(LIB_PATH) && make -f $(LIB_MAKE))

$(STIM_FOLDER) :
	mkdir $(STIM_FOLDER)

stim : $(STIM_FOLDER)
	@for script in $(STIM_SCRIPTS);																\
	do																							\
		(cd $(STIM_FOLDER) && python3 ../../$(STIM_SCRIPTS_PATH)$$script > /dev/null);			\
	done;

# analysis
work-obj93.cf : stim $(LIB) $(FILES)
	@echo "\nBuilding work-obj93.cf..."
	@echo "Analyzing files...";
	@for file in $(FILES);																		\
	do																							\
		echo " > \033[0;36m$$file\033[0m"; 														\
		if ! $(GHDL) -a $(GHDL_OPTS) $$file; 													\
		then 																					\
			declare SUCCESS=1;																	\
			rm work-obj93.cf;																	\
			break;																				\
		fi;																						\
	done;																						\
	if [[ $$SUCCESS -eq 0 ]]; 																	\
	then 																						\
		echo "Analysis finished : work-obj93.cf"; 												\
	fi;