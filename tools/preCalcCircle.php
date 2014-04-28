<?php
    $largestX = $largestY = $angle = $i = 0;
    $angle_stepsize = 0.1;
    $length = 50;
    
    while($angle < 2 * pi()){
        $xList[$i] = round($length * cos($angle))*2+130;
        $largestX = $largestX<$xList[$i]?$xList[$i]:$largestX;
        $yList[$i] = round($length * sin($angle)*1.8)+145;
        $largestY = $largestY<$yList[$i]?$yList[$i]:$largestY;
        $angle += $angle_stepsize;
        $i++;
    }
    
    echo "xlist .byte \$fe, ";
    for($i=0;$i<count($xList);$i++){
        echo $xList[$i].", ";
    }
    echo "\$ff\n";
    
    echo "ylist .byte \$fe, ";
    for($i=0;$i<count($yList);$i++){
        echo $yList[$i].", ";
    }
    echo "\$ff\n";
    $xlist_count = count($xList);
    echo "xlist_count .byte $xlist_count\n";
    echo "; Largest X: $largestX, largest y: $largestY\n";

?>
