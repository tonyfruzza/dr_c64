<?php
    $values = array();
    
    $options = getopt("m:n:");
    
    // inserting our own message
    $string = $options['m'];
    
    for($i=0;$i<strlen($string);$i++){
        //echo "$string[$i]: ".
        getPETSCII($string[$i], $i, $values);
    }
    
    $count = 1;
    echo $options['n']." .byte ";
    for($i=0;$i<count($values);$i++){
        if(isset($values[$i][0]) && ($values[$i][0] == 92 || $values[$i][0] == "a")){
            continue;
        }
        if(isset($values[$i][0]) && $values[$i][0]!=""){
            echo $values[$i][0].", ";
            $count++;
        }
    }
    echo "0\n";
    $count++;
    //echo "Total Bytes: $count\n";
    
    function getPETSCII($chr, $idx, &$values){
        $asc = ord($chr);
        if($asc=="10"){
            return;
        }
        if($chr=="@"){
            return(doMath(0, $idx, $values));
        }
        if($chr=="["){
            return(doMath(27, $idx, $values));
        }
        if($chr=="]"){
            return(doMath(29, $idx, $values));
        }
        if($chr=="$"){
            return(doMath(36, $idx, $values));
        }
        if($chr=="~"){
            return(doMath(108, $idx, $values));
        }
        if($asc>96 && $asc<123){
            return(doMath($asc-96, $idx, $values));
        }
        return(doMath($asc, $idx, $values));
    }
    
    function doMath($val, $idx, &$values){
        $offset=0;
        $ret = ($val * 1) +$offset;
        $values[$idx][0] = $ret;
        $values[$idx][1] = $ret;
    }
    
?>
