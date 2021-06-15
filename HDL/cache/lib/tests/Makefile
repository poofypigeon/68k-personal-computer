GHDL = ghdl

# OPTS
WORK = flipflop
WORK_DIR = sim/

# RUN_OPTS
STOP_TIME = 400ns
ASSERT = error
FST = out.fst

# FLAGS
OPTS = --work=${WORK} --workdir=${WORK_DIR}
RUN_OPTS = --stop-time=${STOP_TIME} --assert-level=${ASSERT} --fst=${WORK_DIR}${FST}

UNIT_TB = ${UNIT}_tb

test : unit flip-flop-tb flip-flop elab
	${GHDL} -r ${OPTS} ${UNIT_TB} ${RUN_OPTS}

view : 
	open ${WORK_DIR}${FST}
	
unit : 
ifeq ($(strip ${UNIT}),)
	@echo "UNIT not provided. Use UNIT=<value> to set it."
	@exit 1
endif

flip-flop-tb : flip-flop-tb.vhd
	${GHDL} -a ${OPTS} flip-flop-tb.vhd
	
	
flip-flop : flip-flop.vhd
	${GHDL} -a ${OPTS} flip-flop.vhd
	
elab :
	${GHDL} -e ${OPTS} ${UNIT_TB}
	${GHDL} -e ${OPTS} ${UNIT}

