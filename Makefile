all:
	cat baseGame.s subroutines.s customchars.s refreshCounter.s testScenarios.s input.s > baseGameCombine.s
	/usr/local/bin/mac2c64 -r baseGameCombine.s
	mv baseGameCombine.rw drc64.prg
	@./createLabels.sh baseGameCombine.s
	/Applications/x64.app/Contents/MacOS/c1541 -format dr64,02 d64 dr64.d64 -attach dr64.d64 -write drc64.prg drc64
demo:
	/usr/local/bin/mac2c64 -r lightspeed.s
	mv lightspeed.rw lightspeed.prg
number:
	/usr/local/bin/mac2c64 -r number.s
	mv number.rw number.prg
customchars:
	/usr/local/bin/mac2c64 -r customchars.s
	mv customchars.rw customchars.prg

joytest:
	/usr/local/bin/mac2c64 -r joytest.s
	mv joytest.rw joytest.prg
	@./createLabels.sh joytest.s
interrupts:
	/usr/local/bin/mac2c64 -r interrupt.s
	mv interrupt.rw interrupt.prg

