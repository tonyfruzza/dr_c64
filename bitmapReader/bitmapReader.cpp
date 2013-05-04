//
//  bitmapReader.cpp
//  C64First
//
//  Created by Tony Fruzza on 12/1/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

// Sprites are 24 x 21

#include "bitmapReader.h"


rawImageParser::~rawImageParser(){
    if (imgBuffer) {
        delete imgBuffer;
    }
    if(imgptr){
        fclose(imgptr);
    }
}

size_t rawImageParser::readImageFile(string fileName){
    size_t lastRead = 1;
    bytesRead = 0;
    imgBuffer = new char[40960];
    //Open the image
    if (!(imgptr = fopen (fileName.c_str(), "r"))) {
        fprintf (stderr, "Image failed to load\n");
        return 1;
    }
    
    while(!feof(imgptr) && lastRead > 0){
        if(!(lastRead = fread(&imgBuffer[bytesRead], 1, 1, imgptr))){
            continue;
        }
        bytesRead++;
    }
    return bytesRead;
}

void rawImageParser::setImageSize(int width, int height){
    imgWidth  = width;
    imgHeight = height;
}

int rawImageParser::parseCharacterMap(){
    int rows = imgHeight/8;
    int cols, columnWidth;
    char tmp;

    columnWidth = 8;
    cols        = imgWidth/columnWidth;
    
    int charctersToParse = imgHeight&&imgWidth?rows * cols:0;
    c64CharData = new c64Char[charctersToParse];
    
    if(!imgBuffer){
        cout << "is imgBuffer NULL?" << endl;
    }
    
    
    // 16 high 0 - 15, 0 - 7 = 0 (0-7), 1 (8-15)
    // 8 - 15 = 1 (0-7), 2 (8-15)
    
    for(int n=0;n<(imgHeight);n++){
        for(int i=0;i<(imgWidth);i++){
            //cout << "Filling data for character[" << ((n/8)+1)*(i/8) << "]" << n%8 << "/" << i%8 << endl;
            //cout << "Reading character: " << i+(n*imgWidth) << endl;
            tmp = imgBuffer[i+(n*imgWidth)]>0?1:0;
            //cout << i << "+" << n*imgWidth << ":" << i+(n*imgWidth)  << ": " << chr2binary(imgBuffer[i+(n*imgWidth)]) << endl;
            
            tmp = tmp << (i%8);
            //cout << " Shifted bits in " << ((n/8)+1)*(i/8) << " for byte " << i+(n*imgWidth) << " " << chr2binary(tmp) << endl;
            //cout << ((n/8)+1) << " * " << (i/8) << endl;
            // (int)imgWidth/8 + (int)imgHeight/8
            //cout << "Doing character: " << (int)i/8 << " + " <<  (int)n/8*imgWidth/8 << endl;
            //c64CharData[((n/8)+1)*(i/8)].rowBits[n%8] |= tmp;
            c64CharData[(int)i/8+(int)n/8*imgWidth/columnWidth].rowBits[n%8] |= tmp;
        }
        //cout << chr2binary(c64CharData[0].rowBits[n]) << endl;
    }
    
    return charctersToParse;
}

// In multicolor mode photoshop uses 8bit colors, which we need to map to 1 out of 3 backgrounds or 1 foreground color (2bit color depth)
// These background colors are specified with the -m options. If the color does not match a bgcolor it's assumed to be a fgcolor
// setup $d011 = $1b
// setup $d016 = $18 , multicolor bit = 1
// "00": bgcolor 0 ($d021)
// "01": bgcolor 1 ($d022)
// "10": bgcolor 2 ($d023)
// "11": color from bits 8-10 of color data
int rawImageParser::parseCharacterMapMultiColor(const u_int8_t bgc1, const u_int8_t bgc2, const u_int8_t bgc3){
    int rows = imgHeight/8;
    int cols, columnWidth;
    char tmp, colorVal, rowColorVal;
    b1 = bgc1;
    b2 = bgc2;
    b3 = bgc3;
    columnWidth = 4;
    cols        = imgWidth/columnWidth;
    
    int charctersToParse = imgHeight&&imgWidth?rows * cols:0;
    c64CharData = new c64Char[charctersToParse];
    
    if(!imgBuffer){
        cout << "is imgBuffer NULL?" << endl;
    }
    
    
    // n = row number
    // i = column number
    for(int n=0;n<(imgHeight);n++){
        rowColorVal = 0;
        for(int i=0;i<(imgWidth);i++){
            tmp = imgBuffer[i+(n*imgWidth)];
            if(tmp == bgc1){
                colorVal = 0;
            }else if(tmp == bgc2){
                colorVal = 1;
            }else if(tmp == bgc3){
                colorVal = 2;
            }else{
                colorVal = 3;
            }
            
            //cout << "r" << i*(n+1) << chr2binary(tmp) << endl;
            //cout << "c" << i%4 << chr2binary(colorVal) << endl;
            //cout << "Filling data for character[" << ((n/8)+1)*(i/8) << "]" << n%8 << "/" << i%8 << endl;
//            tmp = imgBuffer[i+(n*imgWidth)]>0?1:0;
//            rowColorVal |= colorVal << (i%4)*2;
            
            //cout << i << "+" << n*imgWidth << ":" << i+(n*imgWidth)  << ": " << chr2binary(imgBuffer[i+(n*imgWidth)]) << endl;
            
            //tmp = tmp << (i%8);
            //cout << " Shifted bits in " << i%8 << "= " << chr2binary(tmp) << endl;
            //c64CharData[((n/8)+1)*(i/columnWidth)].rowBits[n%8] |= tmp;
            //cout << "c64CharData[((n/8)+1)*(i/columnWidth)].rowBits[n%8] |= colorVal << (i%4)*2" << endl;
            //cout << "c64CharData[" << ((n/8)+1) << "+" << ((i/columnWidth)+1) << "].rowBits[" << n%8 << "]" << endl;
            //cout << "c64CharData[" << (int)n/8 * (imgWidth/columnWidth) + (i/columnWidth) << "].rowBits[" << n%8 << "]" << endl;
            //cout << "c64CharData[" << (int)n/8 * (imgWidth/columnWidth) + (i/columnWidth) << endl;
            c64CharData[(int)n/8 * (imgWidth/columnWidth) + (i/columnWidth)].rowBits[n%8] |= colorVal << (i%4)*2;
        }
    }
    
    return charctersToParse;
}


int rawImageParser::parseSingleSprite(){
    char tmp;

    c64SpriteData = new c64Sprite[3];
    //cout << "Allocated " << charctersToParse << " characters." << endl;
    
    if(!imgBuffer){
        cout << "is imgBuffer NULL?" << endl;
    }
    
    for(int n=0;n<(imgHeight);n++){
        for(int i=0;i<(imgWidth);i++){
            //cout << "Filling data for character[" << ((n/21)+1)*(i/8) << "]" << n%21 << "/" << i%8 << endl;
            tmp = imgBuffer[i+(n*imgWidth)]>0?1:0;
            //cout << i << "+" << n*imgWidth << ":" << i+(n*imgWidth)  << ": " << chr2binary(imgBuffer[i+(n*imgWidth)]) << endl;
            
            tmp = tmp << (i%8);
            //cout << " Shifted bits in " << i%8 << "= " << chr2binary(tmp) << endl;
            c64SpriteData[((n/21)+1)*(i/8)].rowBits[n%21] |= tmp;
        }
    }
    for(int n=0;n<21;n++){
        reverseByte(c64SpriteData[0].rowBits[n]);
        reverseByte(c64SpriteData[1].rowBits[n]);
        reverseByte(c64SpriteData[2].rowBits[n]);
    }

    return 1;
}

void rawImageParser::printChar(int charToPrint){
    if(charToPrint > ((imgHeight/8)*(imgWidth/8))){
        cout << charToPrint << " is out of character range." << endl;
        return; // Out of range
    }
    
    for(int i=0;i<8;i++){
        reverseByte(c64CharData[charToPrint].rowBits[i]);
        cout << chr2binary(c64CharData[charToPrint].rowBits[i]) << " : " << int(c64CharData[charToPrint].rowBits[i]) << endl;
    }
}

void rawImageParser::printAsmOfColors(){
    if(flags & (FLAG_MULTI_COLOR & FLAG_CHAR_TYPE)){
        cout << "; $d021 = " << (int)b1 << endl;
        cout << "; $d022 = " << (int)b3 << endl;
        cout << "; $d023 = " << (int)b2 << endl;
    }
}

void rawImageParser::printAsmOfChar(int charToPrint){
    int colWidth = flags&FLAG_MULTI_COLOR?4:8;
    if(charToPrint > ((imgHeight/8)*(imgWidth/colWidth))){
        cout << charToPrint << " is out of character range." << endl;
        return; // Out of range
    }
    
    if(flags & FLAG_TITLE_SET){
        if(charToPrint == 0){
        cout << title << " .byte ";
        }else{
            // pad out
            cout << title << "_" << charToPrint << " .byte ";
        }
    }else{
        cout << "CUST_CHAR_" << charToPrint << " .byte ";
    }
    for(int i=0;i<8;i++){
        reverseByte(c64CharData[charToPrint].rowBits[i]);
        cout << int(u_int8_t(c64CharData[charToPrint].rowBits[i]));
        if(i!=7){
            cout << ", ";
        }
    }
    cout << endl;
}

void rawImageParser::printAsmOfSprite(){
    if(flags & FLAG_TITLE_SET && title != ""){
        cout << title;
    }else if(flags & FLAG_NO_TITLE){
        // nothing!
    }else{
        cout << "CUST_SPRITE_0";
    }

    for(int i=0;i<21;i++){
        cout << "  .byte " << int(u_int8_t(c64SpriteData[0].rowBits[i])) << ", " << int(u_int8_t(c64SpriteData[1].rowBits[i])) << ", " << int(u_int8_t(c64SpriteData[2].rowBits[i])) << endl;
    }
}

void rawImageParser::printBinOfSprite(){
    for(int n=0;n<21;n++){
        cout << chr2binary(c64SpriteData[0].rowBits[n]) << chr2binary(c64SpriteData[1].rowBits[n]) << chr2binary(c64SpriteData[2].rowBits[n]) << endl;
    }
    cout << endl;
}

void rawImageParser::printBinOfImage(){
    for(int i=0;i<bytesRead;i++){
        cout << chr2binary(imgBuffer[i]) << endl;
    }
}

string rawImageParser::chr2binary(char &in){
    string out = "";
    out += 128 & in?"o":".";
    out +=  64 & in?"o":".";
    out +=  32 & in?"o":".";
    out +=  16 & in?"o":".";
    out +=   8 & in?"o":".";
    out +=   4 & in?"o":".";
    out +=   2 & in?"o":".";
    out +=   1 & in?"o":".";
    return(out);
}

void rawImageParser::reverseByte(char &reverseMe){
    char output;
    char bit;

    for(int count=1;count<=8;count++){
        bit = reverseMe & 0x01;
        reverseMe=reverseMe>>1;
        output=output<<1;
        if(bit==1)
            output=output+1;
        
    }
    reverseMe = output;    
}

void rawImageParser::setTitle(const string &customTitle){
    title = customTitle;
}