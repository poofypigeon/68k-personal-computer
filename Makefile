LIB_PATH = pkg/ #### CHANGE ME

# library dependencies
LIB = user_library-obj93.cf

# VHDL compiler
GHDL = ghdl

# stimulus dependencies
vpath %.py $(STIM_FOLDER)
STIM_FOLDER = test/stimulus/
STIM_FILES 	= plru.stim

# option values
STD = 93c


# option flags
GHDL_OPTS = --std=$(STD) -P=$(LIB_PATH)

.PHONY : clean

FILES = cache_block.vhd 																		\
 		valid_policy.vhd 																		\
		plru_policy.vhd 																		\
		cache_set.vhd																			\
		test/cache_block_tb.vhd																	\
		test/plru_policy_tb.vhd																	\
		test/valid_policy_tb.vhd

work-obj93.cf : $(FILES)
	@echo "\nBuilding work-obj93.cf..."
	@echo "Analyzing files...";
	@for file in $(FILES);																		\
	do																							\
		declare SUCCESS=0;																		\
		echo " > \033[0;36m$$file\033[0m"; 														\
		if ! $(GHDL) -a $(GHDL_OPTS) $$file; 													\
		then 																					\
			SUCCESS=1;																			\
			if [ -f "work-obj93.cf" ]; then rm work-obj93.cf; fi;								\
			break;																				\
		fi;																						\
	done;																						\
	if [[ $$SUCCESS -eq 0 ]]; 																	\
	then 																						\
		echo "Analysis finished : work-obj93.cf"; 												\
	fi;

run :
ifeq ($(strip $(UNIT)), )
	@echo "UNIT not found. Use UNIT=<value>."
	@exit 1;
endif
	$(GHDL) --elab-run -P=$(LIB_PATH) $(UNIT)_tb --fst=out.fst --assert-level=error

clean :
	@if [ -f out.fst ]; then rm out.fst; fi
	@if [ -f *.cf ]; then rm *.cf; fi