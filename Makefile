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

.PHONY : work run stim clean

# build all files and tests
work : FILES = cache-block.vhd 																	\
				  valid-policy.vhd 																\
				  plru-policy.vhd 																\
				  cache-set.vhd																	\
				  test/cache-block-tb.vhd														\
				  test/plru-policy-tb.vhd														\
				  test/valid-policy-tb.vhd
work : work-obj93.cf

# build library dependancy
$(LIB) :
	@(cd $(LIB_PATH) && make -f $(LIB_MAKE) || if [[ -f "work-obj93.cf" ]]; then rm work-obj93.cf; fi;)
	@if [[ ! -f "work-obj93.cf" ]] && [[ ! -f "pkg/user_library-obj93.cf" ]]; 					\
	then																						\
		rm -r test/stimulus;																	\
		exit 1;																					\
	fi;

# make stimulus folder if it doesn't exist
$(STIM_FOLDER) :
	mkdir $(STIM_FOLDER)

# run Python scripts to generate stimulus files
stim : $(STIM_FOLDER)
	@echo "\nRunning stimulus generation scripts..."
	@for script in $(STIM_SCRIPTS);																\
	do																							\
		declare SUCCESS=0;																		\
		echo " > \033[0;36m$$script\033[0m";													\
		(cd $(STIM_FOLDER) && 																	\
		if ! python3 ../../$(STIM_SCRIPTS_PATH)$$script > stim_ascii.txt;						\
		then																					\
			declare SUCCESS=1;																	\
			rm -r ../test/stimulus;																\
			break;																				\
		fi); 																					\
	done;																						\
	if [[ $$SUCCESS -eq 0 ]]; 																	\
	then 																						\
		echo "Stimulus generation finished"; 													\
	fi;

# analyses all of the files
work-obj93.cf : stim $(LIB) $(FILES)
	@echo "\nBuilding work-obj93.cf..."
	@echo "Analyzing files...";
	@for file in $(FILES);																		\
	do																							\
		declare SUCCESS=0;																		\
		echo " > \033[0;36m$$file\033[0m"; 														\
		if ! $(GHDL) -a $(GHDL_OPTS) $$file; 													\
		then 																					\
			SUCCESS=1;																			\
			if [ -d ../test/stimulus ]; then rm -r ../test/stimulus; fi;						\
			if [ -f "work-obj93.cf" ]; then rm work-obj93.cf; fi;								\
			break;																				\
		fi;																						\
	done;																						\
	if [[ $$SUCCESS -eq 0 ]]; 																	\
	then 																						\
		echo "Analysis finished : work-obj93.cf"; 												\
	fi;

# I don't like typing
run :
ifeq ($(strip $(UNIT)), )
	@echo "UNIT not found. Use UNIT=<value>."
	@exit 1;
endif
	$(GHDL) --elab-run -P=$(LIB_PATH) $(UNIT)_tb --fst=out.fst --assert-level=error

# get rid of it
clean :
	@if [ -d test/stimulus ]; then rm -r test/stimulus; fi
	@if [ -f out.fst ]; then rm out.fst; fi
	@if [ -f *.cf ]; then rm *.cf; fi
	@if [ -f **/*.cf ]; then rm **/*.cf; fi