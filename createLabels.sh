echo "Creating labels for VICE monitor debuggin from $1. load using: load_labels "/Users/Tony/Development/DrC64/labels.txt""
/usr/local/bin/mac2c64 -sx $1 2>&1 |grep ^[a-zA-Z]|awk '{printf("%s = %s\n", $1, $3);}' > labels.txt
