# VHDL compiler
GHDL = ghdl

# option values
STD = 93c

# option flags
OPTS = --std=$(STD)

.PHONY : work user_library one_hot vector_tools encoder flip_flop run clean

work : WORK 	= user_library
work : FILES 	= 	one_hot.vhd 																\
					vector_tools.vhd 															\
					encoder.vhd 																\
					flip_flop.vhd 																\
					test/encoder_tb.vhd															\
					test/flip_flop_tb.vhd
work : $(WORK)-obj93.cf

# default - all libraries
user_library : WORK = user_library
user_library : FILES = 	one_hot.vhd 															\
						vector_tools.vhd 														\
						encoder.vhd 															\
						flip_flop.vhd 		
user_library : $(WORK)-obj93.cf

one_hot : WORK = one_hot
one_hot : FILES = one_hot.vhd
one_hot : $(WORK)-obj93.cf

vector_tools : WORK = vector_tools
vector_tools : FILES = vector_tools.vhd
vector_tools : $(WORK)-obj93.cf

encoder 	 : WORK = encoder
encoder 	 : FILES = 	one_hot.vhd																\
						vector_tools.vhd 														\
						encoder.vhd
encoder 	 : $(WORK)-obj93.cf

flip_flop 	 : WORK = flip_flop
flip_flop 	 : FILES = flip_flop.vhd
flip_flop 	 : $(WORK)-obj93.cf

# analyses all of the files
$(WORK)-obj93.cf : $(FILES)
	@echo "\nBuilding $(WORK)-obj93.cf..."
	@echo "Analyzing files...";
	@for file in $(FILES); 																		\
	do																							\
		declare SUCCESS=0	;																	\
		echo " > \033[0;36m$$file\033[0m" ; 													\
		if ! $(GHDL) -a --work=$(WORK) $(OPTS) $$file; 											\
		then 																					\
			SUCCESS=1;																			\
			if [ -f "$(WORK)-obj93.cf" ]; then rm $(WORK)-obj93.cf; fi;							\
			break;																				\
		fi;																						\
	done; 																						\
	if [[ $$SUCCESS -eq 1 ]]; then exit 1; fi;
	@echo "Analysis finished : $(WORK)-obj93.cf";

run :
ifeq ($(strip $(UNIT)), )
	@echo "UNIT not found. Use UNIT=<value>."
	@exit 1;
endif
	$(GHDL) --elab-run $(UNIT)_tb --fst=out.fst --assert-level=error

clean :
	@if [ -f out.fst ]; then rm out.fst; fi
	@if [ -f *.cf ]; then rm *.cf; fi

