vpath %.vhd ..

GHDL = ghdl

# OPTS
WORK = flipflop
WORK_DIR = sim/

# RUN_OPTS
STOP_TIME = 200ns
ASSERT = error
FST = out.fst

# FLAGS
OPTS = --work=${WORK} --workdir=${WORK_DIR}
RUN_OPTS = --stop-time=${STOP_TIME} --assert-level=${ASSERT} --fst=${WORK_DIR}${FST}

UNIT_TB = ${UNIT}_tb

test : flip-flop-tb flip-flop
ifeq ($(strip ${UNIT}),)
	@echo "UNIT not provided. Use UNIT=<value> to set it."
	@exit 1
endif
	${GHDL} -e ${OPTS} ${UNIT}
	${GHDL} -e ${OPTS} ${UNIT_TB}
	${GHDL} -r ${OPTS} ${UNIT_TB} ${RUN_OPTS}

flip-flop-tb : flip-flop-tb.vhd
	${GHDL} -a ${OPTS} $<
	
	
flip-flop : flip-flop.vhd
	${GHDL} -a ${OPTS} $<
	
.PHONY : view

view : 
	open ${WORK_DIR}${FST}