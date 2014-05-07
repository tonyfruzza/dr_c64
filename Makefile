all:
	# These small numbers are only 5 pixels tall, so I'm going to chop off the bottom 3 pixels
	# each number is 4x5 bits 
	echo ".org \$$9000" > compiledAssets.s
	tools/bitmapReader -t SN01 -cf outbreak_assets/smallNums/smallNum01.raw -w 8 -h 8 >> compiledAssets.s
	tools/bitmapReader -t SN23 -cf outbreak_assets/smallNums/smallNum23.raw -w 8 -h 8 >> compiledAssets.s
	tools/bitmapReader -t SN45 -cf outbreak_assets/smallNums/smallNum45.raw -w 8 -h 8 >> compiledAssets.s
	tools/bitmapReader -t SN67 -cf outbreak_assets/smallNums/smallNum67.raw -w 8 -h 8 >> compiledAssets.s
	tools/bitmapReader -t SN89 -cf outbreak_assets/smallNums/smallNum89.raw -w 8 -h 8 >> compiledAssets.s
	php tools/convertBitmapToCharMap.php -f outbreak_assets/worldmap-base40x25.raw -t WORLDCHARMAP -z >> compiledAssets.s
	php tools/convertBitmapToCharMap.php -f outbreak_assets/worldmap-progression40x25.raw -t WMCOLORMAP -z >> compiledAssets.s
	php tools/asciiToPETSCII.php -n "ENDMSG" -m "end" >> compiledAssets.s
	php tools/asciiToPETSCII.php -n "MSG_NEXT" -m "next" >> compiledAssets.s
	php tools/asciiToPETSCII.php -n "MSG_VIRUS" -m "virus" >> compiledAssets.s
	php tools/asciiToPETSCII.php -n "MSG_SCORE" -m "score" >> compiledAssets.s
	php tools/asciiToPETSCII.php -n "MSG_LEVEL" -m "level" >> compiledAssets.s
	php tools/asciiToPETSCII.php -n "MSG_CLEAR" -m "clear" >> compiledAssets.s
	php tools/asciiToPETSCII.php -n "PROGRESS" -m "global infestation progress  [00:00]" >> compiledAssets.s
	php tools/asciiToPETSCII.php -n "LABELS" -m "~all clear    ~outbreak    ~pandemic" >> compiledAssets.s

	cat baseGame.s subroutines.s customchars.s refreshCounter.s input.s drawBox.s layout.s drops.s \
    virusLevels.s lvlSelect.s search.s lookForConnect4.s down.s left.s right.s moveUtils.s newColor.s colorUtils.s \
    rotate.s scoreOverTop.s lvlPieceColor.s scoring.s wmBorderText.s  wmColor.s compiledAssets.s \
    > baseGameCombine.s
	/usr/local/bin/mac2c64 -r baseGameCombine.s
	tools/linker baseGameCombine.rwa baseGameCombine.rwb > drc64.prg
	tools/linker drc64.prg Outbreak-8000sng.prg > outbreak_wsong.prg
	tools/linker outbreak_wsong.prg outbreak_assets/chars3000.prg > outbreak_wchars.prg
	tools/exomizer sfx \$$$0801 -q outbreak_wchars.prg -o outbreak.prg
	@./createLabels.sh baseGameCombine.s
	/Applications/x64.app/Contents/MacOS/c1541 -format outbreak,02 d64 outbreak.d64 -attach outbreak.d64 -write outbreak.prg outbreak


#	tools/bitmapReader -t PILL_H -cf outbreak_assets/pill_h.raw -w 16 -h 8 > compiledAssets.s
#	tools/bitmapReader -t PILL_V -cf outbreak_assets/pill_v.raw -w 8 -h 16 >> compiledAssets.s
#	tools/bitmapReader -t PILL_HD -cf outbreak_assets/pill_h-dropped.raw -w 16 -h 8 >> compiledAssets.s
#	tools/bitmapReader -t PILL_VD -cf outbreak_assets/pill_v-dropped.raw -w 8 -h 16 >> compiledAssets.s
#	tools/bitmapReader -t PILL_HLF -cf outbreak_assets/pillHalf.raw -w 8 -h 8 >> compiledAssets.s
#	tools/bitmapReader -t PILL_HLF2 -cf outbreak_assets/pillHalf2.raw -w 8 -h 8 >> compiledAssets.s
#	tools/bitmapReader -t V1_AN -cf outbreak_assets/v1_an.raw -w 24 -h 8 >> compiledAssets.s
#	tools/bitmapReader -t GAME_BORDER -cf outbreak_assets/gameborder.raw -w 24 -h 24 >> compiledAssets.s
#	tools/bitmapReader -t leftTopSprite -sf outbreak_assets/leftTopSprite.raw -w 24 -h 21 > compiledAssets.s
#	tools/bitmapReader -t rightTopSprite -sf outbreak_assets/rightTopSprite.raw -w 24 -h 21 >> compiledAssets.s
#	tools/bitmapReader -t scorePopUp -sf outbreak_assets/scorePopUp.raw -w 24 -h 21 >> compiledAssets.s
#	tools/bitmapReader -t CLEAR_PIECE -cf outbreak_assets/clearPieces.raw -w 24 -h 8 >> compiledAssets.s
#	php tools/asciiToPETSCII.php "   hello    " >> compiledAssets.s
#	php tools/textToPETSCII.php "                       multi color splash screen bitmap messed up, overlapped mem. still working on my memory layout skills and such....               " >> compiledAssets.s
#	tools/bin2hex -kf outbreak_assets/dna6.kla -n dylan1 >> compiledAssets.s
#	tools/bin2hex -n customchars -f outbreak_assets/chars.raw >> compiledAssets.s

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
	cat highres.s > highresAll.s
	tools/bin2hex -kf kennel.kla -n highDot >> highresAll.s
	/usr/local/bin/mac2c64 -r highresAll.s
	mv highresAll.rw highres.prg
	
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
	cp -f showSprite.s showSpriteCombine.s
	tools/bitmapReader -t CUST_SPRITE_0 -w 24 -h 21 -s -f Images/spriteTitleTiles_1.raw >> showSpriteCombine.s
	/usr/local/bin/mac2c64 -r showSpriteCombine.s
	mv showSpriteCombine.rw showSprite.prg
newyear:
	/usr/local/bin/mac2c64 -r newyear.s
	mv newyear.rw newyear.prg
koalaplay:
# Using Project One to convert BMP to koala format
#	tools/linker koalaplay.rw dude.rw dna3-kola.kla > koalaplay.prg
	cat koalaplay.s > koala.s
	tools/bin2hex -kf 100inthemiddle.kla -n dna4 >> koala.s
#	tools/bin2hex -kf diana-almond.kla -n dna4 >> koala.s
	tools/bin2hex -kf tony-racing.kla -n dylan1 >> koala.s
	/usr/local/bin/mac2c64 -r koala.s
	mv koala.rw koala.prg

spritePath:
	/usr/local/bin/mac2c64 -r spritePath.s
	mv spritePath.rw spritePath.prg
vscroller:
	/usr/local/bin/mac2c64 -r vscroller.s
	mv vscroller.rw vscroller.prg
	 @./createLabels.sh vscroller.s
openBorders:
	/usr/local/bin/mac2c64 -r openBorders.s
	mv openBorders.rw openBorders.prg
spriteTextScroller:
	cp spriteTextScroller.s spriteTextScroller-bday.s
	tools/bin2hex -kf outbreak_assets/dna6.kla -n bday >> spriteTextScroller-bday.s
	/usr/local/bin/mac2c64 -r spriteTextScroller-bday.s
	mv spriteTextScroller-bday.rw spriteTextScroller-bday.prg
	 @./createLabels.sh spriteTextScroller.s
queue:
	/usr/local/bin/mac2c64 -r queue.s
	mv queue.rw queue.prg
	 @./createLabels.sh queue.s
int2:
	/usr/local/bin/mac2c64 -r int2.s
	mv int2.rw int2.prg
multiSprite:
	/usr/local/bin/mac2c64 -r multiSprite.s
	mv multiSprite.rw multiSprite.prg
	
songBy:
	echo ".org \x243000" > oblogo.s
	# 5 x 25 * 8 = 1000 bytes
	tools/bitmapReader -t logo -cf song/outbreak40x200.raw -w 40 -h 200 >> oblogo.s
	tools/bitmapReader -t status -cf song/status32x8.raw -w 40 -h 8

	echo ".org \x2433E8" > obby.s
	tools/bitmapReader -t songby -cf song/songby72x32.raw -w 72 -h 32 >> obby.s

	/usr/local/bin/mac2c64 -r songBy.s
	/usr/local/bin/mac2c64 -r oblogo.s
	/usr/local/bin/mac2c64 -r obby.s
	/Applications/x64.app/Contents/MacOS/c1541 -format outbreaksong,02 d64 ob-song.d64 -attach ob-song.d64 -write songBy.rw song -write oblogo.rw logo -write obby.rw by -write song/obsong.prg sid
	@./createLabels.sh songBy.s
simple:
	/usr/local/bin/mac2c64 -r simple.s
	mv simple.rw simple.prg
	@./createLabels.sh simple.s
prof:
	/usr/local/bin/mac2c64 -r prof.s
	mv prof.rw prof.prg
	tools/linker Sprites.prg  prof.prg > profsprite.prg
timerBasedCountDown:
	/usr/local/bin/mac2c64 -r timerBasedCountDown.s
	mv timerBasedCountDown.rw timerBasedCountDown.prg
	@./createLabels.sh timerBasedCountDown.s
pongBattle:
	cp -f pongBattle.s pongBattleCombine.s
	php tools/preCalcCircle.php >> pongBattleCombine.s
	tools/bitmapReader -t CUST_SPRITE_0 -w 24 -h 21 -s -f Images/squareSingleColorSprite.raw >> pongBattleCombine.s
	/usr/local/bin/mac2c64 -r pongBattleCombine.s
	mv pongBattleCombine.rw pongBattle.prg
	@./createLabels.sh pongBattleCombine.s
	/Applications/x64.app/Contents/MacOS/c1541 -format pongbattle,02 d64 pongbattle.d64 -attach pongbattle.d64 -write pongBattle.prg pongbattle
highResExp:
	cat highResExp.s > highResExpCombine.s
	php tools/preCalcBitmapTables.php >> highResExpCombine.s
	mac2c64 -r highResExpCombine.s
	mv highResExpCombine.rw highResExp.prg
	@./createLabels.sh highResExpCombine.s
#	/Applications/x64.app/Contents/MacOS/c1541 -format highresdraw,02 d64 highresdraw.d64 -attach highresdraw.d64 -write highResExp.prg highresdraw
