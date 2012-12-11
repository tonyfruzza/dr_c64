#include "bitmapReader.h"

using namespace std;

int main(int argc, char *argv[]){
    int ch, width, height;
    u_int8_t flags;
    string bitmapName;

    while((ch = getopt(argc, argv, "w:h:f:")) != -1){
        switch (ch) {
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
                
        }
    }
    argc -= optind;
    argv += optind;
     
    
    rawImageParser *rip = new rawImageParser();
    rip->readImageFile(bitmapName);
    rip->setImageSize(width, height);
    int charactersParsed = rip->parseCharacterMap();
    
    //cout << "Parsed: " << endl << rip->parseCharacterMap() << " characters..." << endl;
    
    for(int i=0;i<charactersParsed;i++){
        rip->printAsmOfChar(i);
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