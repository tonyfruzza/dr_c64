<?php
    $options = getopt("f:t:z");
    echo $options['t']." .byte ";
    $fh = fopen($options['f'], "rb");
    //$rawImg = fread($fh, filesize($options['f']));
    for($i=0;$i<filesize($options['f']);$i++){
        $char = fread($fh, 1);
        $val = unpack("c", $char);
        switch($val[1]){
            case 0:
                echo "32";
                break;
            // For map to char
            case 15:
                echo "108";
                break;
            case 1:
                echo "109";
                break;
            default:
                echo $val[1];
        }
        if($i+1 != filesize($options['f'])){
            echo ", ";
        }
//        print_r($val);
//        echo dechex($val[1]).",";
    }
    if(isset($options['z'])){
        echo ", 0";
    }
    echo "\n";
    fclose($fh);
    
?>