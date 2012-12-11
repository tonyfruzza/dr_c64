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
    imgBuffer = new char[2048];
    //Open the image
    if (!(imgptr = fopen (fileName.c_str(), "r"))) {
        fprintf (stderr, "Image failed to load\n");
        return 1;
    }
    
    while(!feof(imgptr) && lastRead > 0){
        lastRead = fread(&imgBuffer[bytesRead], 1, 1, imgptr);

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
    int cols = imgWidth/8;
    char tmp;
    int charctersToParse = imgHeight&&imgWidth?rows * cols:0;
    c64CharData = new c64Char[charctersToParse];
    //cout << "Allocated " << charctersToParse << " characters." << endl;
    
    if(!imgBuffer){
        cout << "is imgBuffer NULL?" << endl;
    }
    
    for(int n=0;n<(imgHeight);n++){
        for(int i=0;i<(imgWidth);i++){
            //cout << "Filling data for character[" << ((n/8)+1)*(i/8) << "]" << n%8 << "/" << i%8 << endl;
            //tmp = 1;
            tmp = imgBuffer[i+(n*imgWidth)]>0?1:0;
            //cout << i << "+" << n*imgWidth << ":" << i+(n*imgWidth)  << ": " << chr2binary(imgBuffer[i+(n*imgWidth)]) << endl;
            
            tmp = tmp << (i%8);
            //cout << " Shifted bits in " << i%8 << "= " << chr2binary(tmp) << endl;
            c64CharData[((n/8)+1)*(i/8)].rowBits[n%8] |= tmp;
        }
    }
    
    return charctersToParse;
}

int rawImageParser::parseSingleSprite(){
    int rows = 1;
    int cols = 3;
    char tmp;
    int charctersToParse = 3;
    c64SpriteData = new c64Sprite[charctersToParse];
    //cout << "Allocated " << charctersToParse << " characters." << endl;
    
    if(!imgBuffer){
        cout << "is imgBuffer NULL?" << endl;
    }
    
    for(int n=0;n<(imgHeight);n++){
        for(int i=0;i<(imgWidth);i++){
            cout << "Filling data for character[" << ((n/21)+1)*(i/8) << "]" << n%21 << "/" << i%8 << endl;
            //tmp = 1;
            tmp = imgBuffer[i+(n*imgWidth)]>0?1:0;
            //cout << i << "+" << n*imgWidth << ":" << i+(n*imgWidth)  << ": " << chr2binary(imgBuffer[i+(n*imgWidth)]) << endl;
            
            tmp = tmp << (i%8);
            //cout << " Shifted bits in " << i%8 << "= " << chr2binary(tmp) << endl;
            c64CharData[((n/21)+1)*(i/8)].rowBits[n%21] |= tmp;
        }
    }
    
    return charctersToParse;

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

void rawImageParser::printAsmOfChar(int charToPrint){
    if(charToPrint > ((imgHeight/8)*(imgWidth/8))){
        cout << charToPrint << " is out of character range." << endl;
        return; // Out of range
    }
    
    cout << "CUST_CHAR_" << charToPrint << " .byte ";
    for(int i=0;i<8;i++){
        reverseByte(c64CharData[charToPrint].rowBits[i]);
        cout << int(u_int8_t(c64CharData[charToPrint].rowBits[i]));
        if(i!=7){
            cout << ", ";
        }
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
    out += 128 & in?"1":"0";
    out +=  64 & in?"1":"0";
    out +=  32 & in?"1":"0";
    out +=  16 & in?"1":"0";
    out +=   8 & in?"1":"0";
    out +=   4 & in?"1":"0";
    out +=   2 & in?"1":"0";
    out +=   1 & in?"1":"0";
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