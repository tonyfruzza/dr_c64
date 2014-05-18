<?php
    // 0: Black     = $00
    // 1: White     = $01
    // 2: DarkGrey  = $0f
    $options = getopt("a:b:c:d:t:");
    $debug = false;
    echo $options['t']." .byte ";
    $filesCombinedArray = array();
    $fileArray = array($options['a'], $options['b'], $options['c'], $options['d']);
    for($n=0;$n<4;$n++){
        $shiftAmount = 2 * $n;
        $fh = fopen($fileArray[$n], "rb");
        for($i=0;$i<filesize($fileArray[$n]);$i++){
            $char = fread($fh, 1);
            $val = unpack("c", $char);
            if($val[1] == 15 || $val[1] == 11){
                $val[1] = 2;
            }
            if($debug){
                echo ($val[1] << $shiftAmount).",";
            }
            $filesCombinedArray[$i] = ($val[1] << $shiftAmount) | @$filesCombinedArray[$i];
        }
        fclose($fh);
        if($debug){
            echo "\n";
        }
    }
    
    for($i=0;$i<count($filesCombinedArray);$i++){
        echo $filesCombinedArray[$i].", ";
    }
    echo "255\n";
    
?>