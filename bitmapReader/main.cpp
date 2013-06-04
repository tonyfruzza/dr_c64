#include "bitmapReader.h"

using namespace std;

void printUsage(){
    cout << "Usage:\n\
    w #     : specify width\n\
    h #     : specify height\n\
    f path  : .raw image filename\n\
    c       : convert to character map\n\
    s       : convert to sprite\n\
    m #,#,# : multicolor bgc1, bgc2, bgc3 in decimal value\n\
    ";
}

int main(int argc, char *argv[]){
    int ch, width, height;
    string bitmapName, bgColorsString, title;
    int bgc1, bgc2, bgc3;
    u_int8_t flags = 0;
    while((ch = getopt(argc, argv, "w:h:f:scm:o:t:nd")) != -1){
        switch (ch) {
            case 't':
                title = optarg;
                flags |= FLAG_TITLE_SET;
                break;
            case 'o':
                cout << ".org $" << optarg << endl;
                break;
            case 'w':
                width = atoi(optarg);
                break;
            case 'h':
                height = atoi(optarg);
                break;
            case 'f':
                bitmapName = optarg;
                break;
            case 'c':
                flags |= FLAG_CHAR_TYPE;
                break;
            case 's':
                flags |= FLAG_SPRITE_TYPE;
                break;
            case 'n':
                flags |= FLAG_NO_TITLE;
                break;
            case 'd':
                flags |= FLAG_DEBUG;
                break;
            case 'm':
                flags |= FLAG_MULTI_COLOR;
                if(sscanf(optarg, "%d,%d,%d", &bgc1, &bgc2, &bgc3) != 3){
                    cout << "Multicolor mode bgcolors options should be: -m #,#,#" << endl;
                }else{
                    cout << "; Multcolor set using:" << endl << ";bgc1: " << bgc1 << endl << ";bgc2: " << bgc2 << endl << ";bgc3: " << bgc3 << endl;
                }
                break;
            default:
                printUsage();
                
        }
    }
    argc -= optind;
    argv += optind;
     
    
    rawImageParser *rip = new rawImageParser();
    rip->flags = flags;
    if(flags & FLAG_TITLE_SET){
        rip->setTitle(title);
    }
    rip->readImageFile(bitmapName);
    //cout << "Setting width " << width << "px, height " << height << "px" << endl;
    rip->setImageSize(width, height);
    
    
    if(flags & FLAG_CHAR_TYPE){
        int charactersParsed;
        if(flags & FLAG_MULTI_COLOR){
            cout << "; Doing multicolor character set" << endl;
            charactersParsed = rip->parseCharacterMapMultiColor(bgc1, bgc2, bgc3);
        }else{
            if(flags & FLAG_DEBUG){
                cout << "; Doing single color character set" << endl;
            }
            charactersParsed = rip->parseCharacterMap();
        }
        if(flags & FLAG_DEBUG){
            cout << "Parsed: " << endl << charactersParsed << " characters..." << endl;
            rip->printBinOfImage();
        }
        
        for(int i=0;i<charactersParsed;i++){
            rip->printAsmOfChar(i);
        }
    }
    rip->printAsmOfColors();

    if(flags & FLAG_SPRITE_TYPE){
        rip->parseSingleSprite();
        //rip->printBinOfSprite();
        rip->printAsmOfSprite();
//        rip->printAsmOfChar(1);
    }

//    rip->printChar(1);
    delete rip;
    
    /*
    // My part to write raw data
    FILE *outFile;
    char in;
    int bytes=0;
    outFile = fopen("image2.raw", "w");
    while(!feof(imgptr)){
        fread(&in, 1, 1, imgptr);
        fwrite(&in, 1, 1, outFile);
        bytes++;
    }
    printf("Wrote %d bytes\n", bytes);
     */
    
    return 0;
}