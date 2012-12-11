//
//  bitmapReader.h
//  C64First
//
//  Created by Tony Fruzza on 12/1/12.
//  Copyright (c) 2012 Lightspeed Systems. All rights reserved.
//

#ifndef C64First_bitmapReader_h
#define C64First_bitmapReader_h

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <unistd.h>

#define FLAG_CHAR_TYPE      0x00
#define FLAG_SPRITE_TYPE    0x01

using namespace std;

struct c64Char {
    char rowBits[8];
    inline c64Char(){
        for(int i=0;i<8;i++){
            rowBits[i] = 0;
        }
    }
};

struct c64Sprite {
    char rowBits[21];
    inline c64Sprite(){
        for(int i=0;i<21;i++){
            rowBits[i] = 0;
        }
    }
};


// each C64 char is 8bytes * 256
class rawImageParser{
    int imgWidth, imgHeight;
    unsigned long bytesRead;
    char *imgBuffer;
    FILE *imgptr;
    c64Char *c64CharData;
    c64Sprite *c64SpriteData;
    
    string chr2binary(char &in);
    void reverseByte(char &reverseMe);
    
public:
    ~rawImageParser();
    size_t readImageFile(string fileName);
    void   setImageSize(int width, int height);
    int    parseCharacterMap();
    int    parseSingleSprite();
    void   printChar(int charToPrint);
    void   printBinOfImage();
    void   printAsmOfChar(int charToPrint);
};


#endif
