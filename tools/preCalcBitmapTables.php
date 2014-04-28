<?php
    $arrayCount = 0;
    $ytablelow = $ytablehigh = $xtablelow = $xtablehigh = array();

    for($i=0;$i<25;$i++){
        for($n=0;$n<8;$n++){
            // Add $6000 for where screen memeory is located
            $val = str_pad(dechex($n+(320*$i)+24576), 4, "0", STR_PAD_LEFT);
            $ytablehigh[$arrayCount]    = "$".$val[0].$val[1];
            $ytablelow[$arrayCount]     = "$".$val[2].$val[3];
            $arrayCount++;
        }
    }

    echo "ytablelow .byte ";
    for($i=0;$i<count($ytablelow);$i++){
        echo $ytablelow[$i];
        if(($i+1)!=count($ytablelow)){
            echo ", ";
        }
    }
    echo "\n";
    
    echo "ytablehigh .byte ";
    for($i=0;$i<count($ytablehigh);$i++){
        echo $ytablehigh[$i];
        if(($i+1)!=count($ytablehigh)){
            echo ", ";
        }
    }
    echo "\n";

    for($arrayCount=$i=0;$i<40;$i++){
        for($n=0;$n<8;$n++){
            $val = str_pad(dechex($i*8), 4, "0", STR_PAD_LEFT);
            $xtablehigh[$arrayCount]    = "$".$val[0].$val[1];
            $xtablelow[$arrayCount]     = "$".$val[2].$val[3];
            $arrayCount++;
        }
    }
    
    echo "xtablelow .byte ";
    for($i=0;$i<count($xtablelow);$i++){
        echo $xtablelow[$i];
        if(($i+1)!=count($xtablelow)){
            echo ", ";
        }
    }
    echo "\n";
    
    echo "xtablehigh .byte ";
    for($i=0;$i<count($xtablehigh);$i++){
        echo $xtablehigh[$i];
        if(($i+1)!=count($xtablehigh)){
            echo ", ";
        }
    }
    echo "\n";
    
    echo "mask .byte ";
    for($i=0;$i<40;$i++){
        echo "128, 64, 32, 16, 8, 4, 2, 1";
        if($i+1!=40){
            echo ", ";
        }
    }
    echo "\n";

?>
