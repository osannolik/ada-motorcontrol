ADA_PRJ = ada_motorcontrol.gpr

TOOL = /usr/gnat
GPRBUILD = $(TOOL)/bin/gprbuild
OD = $(TOOL)/bin/arm-eabi-objdump

OUTFILE = obj/main
LISTFILE = obj/main.lst

PORT_REM = 4242

# use -vl or -vm or -vh
VERB?= 
ifneq ($(VERB), )
V=
else
V=@
endif

.PHONY: all target_connect run debug

all: $(OUTFILE) $(LISTFILE)

$(OUTFILE): $(ADA_PRJ)
	$(V) $(GPRBUILD) -P $< $(VERB)

$(LISTFILE): $(OUTFILE)
	$(V) $(OD) -S $< > $@

target_connect:
	st-util --listen_port=$(PORT_REM) &

run: $(OUTFILE) target_connect
	arm-eabi-gdb --se=$(OUTFILE) --command=load_run.gdbinit

debug: $(OUTFILE) target_connect
	arm-eabi-gdb --se=$(OUTFILE) --command=load_debug.gdbinit
