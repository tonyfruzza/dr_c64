all:
	cat baseGame.s subroutines.s customchars.s refreshCounter.s testScenarios.s input.s drawBox.s layout.s drops.s \
    virusLevels.s lvlSelect.s search.s lookForConnect4.s down.s left.s right.s moveUtils.s newColor.s colorUtils.s \
    rotate.s > baseGameCombine.s
	/usr/local/bin/mac2c64 -r baseGameCombine.s
	mv baseGameCombine.rw drc64.prg
	@./createLabels.sh baseGameCombine.s
	/Applications/x64.app/Contents/MacOS/c1541 -format dr64,02 d64 dr64.d64 -attach dr64.d64 -write drc64.prg drc64
linker:
	/Users/Tony/Library/Developer/Xcode/DerivedData/C64First-bcaelnhlmpesixdidkmnvslvslar/Build/Products/Debug/linker drc64.prg quiet.prg 2049 > combined.prg
compress:
	pucrunch -c64 combined.prg compressed.prg
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

cia:
	/usr/local/bin/mac2c64 -r ciaTimer.s
	mv ciaTimer.rw ciaTimer.prg
highres:
	/usr/local/bin/mac2c64 -r highres.s
	mv highres.rw highres.prg
	
scroller:
	/usr/local/bin/mac2c64 -r scroller.s
	mv scroller.rw scroller.prg
friday:
	/usr/local/bin/mac2c64 -r friday.s
	tools/linker friday.rwa friday.rwb > friday.prg
charAni:
	tools/bitmapReader -f Images/8ballVerticalMove.raw -w 256 -h 8
	/usr/local/bin/mac2c64 -r charAni.s
	mv charAni.rw charAni.prg	
