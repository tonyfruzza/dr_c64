all:
	tools/bitmapReader -t PILL_H -cf outbreak_assets/pill_h.raw -w 16 -h 8 > compiledAssets.s
	tools/bitmapReader -t PILL_V -cf outbreak_assets/pill_v.raw -w 8 -h 16 >> compiledAssets.s
	tools/bitmapReader -t PILL_HLF -cf outbreak_assets/pillHalf.raw -w 8 -h 8 >> compiledAssets.s
	tools/bitmapReader -t PILL_HLF2 -cf outbreak_assets/pillHalf2.raw -w 8 -h 8 >> compiledAssets.s
	tools/bitmapReader -t V1_AN -cf outbreak_assets/v1_an.raw -w 24 -h 8 >> compiledAssets.s
	tools/bitmapReader -t NUMS -cf outbreak_assets/numbers.raw -w 80 -h 8 >> compiledAssets.s
	cat baseGame.s subroutines.s customchars.s refreshCounter.s testScenarios.s input.s drawBox.s layout.s drops.s \
    virusLevels.s lvlSelect.s search.s lookForConnect4.s down.s left.s right.s moveUtils.s newColor.s colorUtils.s \
    rotate.s compiledAssets.s > baseGameCombine.s
	/usr/local/bin/mac2c64 -r baseGameCombine.s
	mv baseGameCombine.rw drc64.prg
	tools/linker drc64.prg quiet.prg > outbreak.prg
	@./createLabels.sh baseGameCombine.s
#	/Applications/x64.app/Contents/MacOS/c1541 -format dr64,02 d64 dr64.d64 -attach dr64.d64 -write drc64.prg drc64
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
#	tools/bitmapReader -f Images/8ballVerticalMove.raw -w 256 -h 8
	/usr/local/bin/mac2c64 -r charAni.s
	mv charAni.rw charAni.prg	
showSprite:
	@/Users/Tony/Library/Developer/Xcode/DerivedData/C64First-bcaelnhlmpesixdidkmnvslvslar/Build/Products/Debug/bitmapReader -w 24 -h 21 -s -f Images/spriteTitleTiles_1.raw
	@/Users/Tony/Library/Developer/Xcode/DerivedData/C64First-bcaelnhlmpesixdidkmnvslvslar/Build/Products/Debug/bitmapReader -w 24 -h 21 -s -f Images/spriteTitleTiles_2.raw
	@/Users/Tony/Library/Developer/Xcode/DerivedData/C64First-bcaelnhlmpesixdidkmnvslvslar/Build/Products/Debug/bitmapReader -w 24 -h 21 -s -f Images/spriteTitleTiles_3.raw
	@/Users/Tony/Library/Developer/Xcode/DerivedData/C64First-bcaelnhlmpesixdidkmnvslvslar/Build/Products/Debug/bitmapReader -w 24 -h 21 -s -f Images/spriteTitleTiles_4.raw
	@/Users/Tony/Library/Developer/Xcode/DerivedData/C64First-bcaelnhlmpesixdidkmnvslvslar/Build/Products/Debug/bitmapReader -w 24 -h 21 -s -f Images/spriteTitleTiles_5.raw
	@/Users/Tony/Library/Developer/Xcode/DerivedData/C64First-bcaelnhlmpesixdidkmnvslvslar/Build/Products/Debug/bitmapReader -w 24 -h 21 -s -f Images/spriteTitleTiles_6.raw
	@/Users/Tony/Library/Developer/Xcode/DerivedData/C64First-bcaelnhlmpesixdidkmnvslvslar/Build/Products/Debug/bitmapReader -w 24 -h 21 -s -f Images/spriteTitleTiles_7.raw
	@/Users/Tony/Library/Developer/Xcode/DerivedData/C64First-bcaelnhlmpesixdidkmnvslvslar/Build/Products/Debug/bitmapReader -w 24 -h 21 -s -f Images/spriteTitleTiles_8.raw
	/usr/local/bin/mac2c64 -r showSprite.s
	tools/linker showSprite.rwa showSprite.rwb > showSprite.prg
tree:
	/usr/local/bin/mac2c64 -r tree.s
#	mv tree.rw tree.prg
	tools/linker tree.rwa tree.rwb > tree.prg
newyear:
	/usr/local/bin/mac2c64 -r newyear.s
	mv newyear.rw newyear.prg
koalaplay:
	/usr/local/bin/mac2c64 -r koalaplay.s
	tools/bitmapReader -o 3000 -sf dude1.raw -w 24 -h 21 > dude1.spr
	tools/bitmapReader -o 3040 -sf dude2.raw -w 24 -h 21 > dude2.spr
	tools/bitmapReader -o 3080 -sf dude3.raw -w 24 -h 21 > dude3.spr
	tools/bitmapReader -o 30C0 -sf dude4.raw -w 24 -h 21 > dude4.spr
	tools/bitmapReader -o 3100 -sf dude5.raw -w 24 -h 21 > dude5.spr
	tools/bitmapReader -o 3140 -sf dude6.raw -w 24 -h 21 > dude6.spr
	tools/bitmapReader -o 3180 -sf dude7.raw -w 24 -h 21 > dude7.spr
	tools/bitmapReader -o 31C0 -sf dude8.raw -w 24 -h 21 > dude8.spr

	/usr/local/bin/mac2c64 -r dude1.spr
	/usr/local/bin/mac2c64 -r dude2.spr
	/usr/local/bin/mac2c64 -r dude3.spr
	/usr/local/bin/mac2c64 -r dude4.spr
	/usr/local/bin/mac2c64 -r dude5.spr
	/usr/local/bin/mac2c64 -r dude6.spr
	/usr/local/bin/mac2c64 -r dude7.spr
	/usr/local/bin/mac2c64 -r dude8.spr
	mv dude1.rw dude1.prg
	mv koalaplay.rw koalaplay.prg
	#tools/linker koalaplay.rw dude.rw dna3-kola.kla > koalaplay.prg 
