all:
	tools/bitmapReader -t PILL_H -cf outbreak_assets/pill_h.raw -w 16 -h 8 > compiledAssets.s
	tools/bitmapReader -t PILL_V -cf outbreak_assets/pill_v.raw -w 8 -h 16 >> compiledAssets.s
	tools/bitmapReader -t PILL_HLF -cf outbreak_assets/pillHalf.raw -w 8 -h 8 >> compiledAssets.s
	tools/bitmapReader -t PILL_HLF2 -cf outbreak_assets/pillHalf2.raw -w 8 -h 8 >> compiledAssets.s
	tools/bitmapReader -t V1_AN -cf outbreak_assets/v1_an.raw -w 24 -h 8 >> compiledAssets.s
	tools/bitmapReader -t NUMS -cf outbreak_assets/numbers.raw -w 80 -h 8 >> compiledAssets.s
	tools/bitmapReader -t GAME_BORDER -cf outbreak_assets/gameborder.raw -w 24 -h 24 >> compiledAssets.s
	tools/bitmapReader -t leftTopSprite -sf outbreak_assets/leftTopSprite.raw -w 24 -h 21 >> compiledAssets.s
	tools/bitmapReader -t rightTopSprite -sf outbreak_assets/rightTopSprite.raw -w 24 -h 21 >> compiledAssets.s
	cat baseGame.s subroutines.s customchars.s refreshCounter.s testScenarios.s input.s drawBox.s layout.s drops.s \
    virusLevels.s lvlSelect.s search.s lookForConnect4.s down.s left.s right.s moveUtils.s newColor.s colorUtils.s \
    rotate.s compiledAssets.s layout_sprites.s > baseGameCombine.s
	/usr/local/bin/mac2c64 -r baseGameCombine.s
	mv baseGameCombine.rw drc64.prg
#	tools/linker drc64.prg quiet.prg > outbreak.prg
	tools/linker drc64.prg everlasting.prg > outbreak.prg
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
newyear:
	/usr/local/bin/mac2c64 -r newyear.s
	mv newyear.rw newyear.prg
koalaplay:
# Using Project One to convert BMP to koala format
#	tools/linker koalaplay.rw dude.rw dna3-kola.kla > koalaplay.prg
	cat koalaplay.s > koala.s
	tools/bin2hex -kf diana-almond.kla -n dna4 >> koala.s
	tools/bin2hex -kf tony-racing.kla -n dylan1 >> koala.s
	/usr/local/bin/mac2c64 -r koala.s
	mv koala.rw koala.prg

spritePath:
	/usr/local/bin/mac2c64 -r spritePath.s
	mv spritePath.rw spritePath.prg
