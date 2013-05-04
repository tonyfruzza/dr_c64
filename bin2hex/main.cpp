//
//  main.cpp
//  bin2hex
//
//  Created by Tony Fruzza on 4/28/13.
//  Copyright (c) 2013 Lightspeed Systems. All rights reserved.
//

#include <iostream>
#include <string>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sstream>

#define FLAGS_FILE_SET  0x01
#define FLAGS_NAME_SET  0x02
#define FLAGS_KOALA     0x04

using namespace std;

int main(int argc, char * argv[]){
    int ch, bytesRead;
    size_t lastRead = 1;
    unsigned char readChar;
    u_int8_t flags = 0;
    string fileName, descName, finishingString;
    FILE *fp;
    char *tmpCString;
    stringstream returnLine;
    
    while((ch = getopt(argc, argv, "f:n:k")) != -1){
        switch (ch){
            case 'f':
                flags |= FLAGS_FILE_SET;
                fileName = optarg;
                break;
            case 'n':
                flags |= FLAGS_NAME_SET;
                descName = optarg;
                break;
            case 'k':
                flags |= FLAGS_KOALA;
                break;
        }
    }
    argc -= optind;
    argv += optind;
    
    if(!(flags & FLAGS_FILE_SET)){
        cout << "Specify -f filename to read in." << endl;
        exit(1);
    }
    
    if(!(fp = fopen(fileName.c_str(), "r"))){
        cout << "Could not open file for reading." << endl;
        exit(1);
    }
    
    returnLine << descName << " .byte ";
    tmpCString = new char[6];

    bytesRead = 0;
    while(!feof(fp) && lastRead > 0){
        if(!(lastRead = fread(&readChar, 1, 1, fp))){
            continue;
        }
        bytesRead++;
        if(bytesRead < 3 && flags & FLAGS_KOALA){
            continue;
        }
        sprintf(tmpCString, "$%02x, ", readChar);
        returnLine << tmpCString;
    }
    
    finishingString = returnLine.str();
    finishingString = finishingString.substr(0, finishingString.size()-2);
    cout << finishingString << endl;
    
    fclose(fp);
    return 0;
}

