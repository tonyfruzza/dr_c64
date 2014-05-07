<?php
$values = array();
$string = "                          this horizontal scroller using 8 sprites all at the same time lined up together. the sprites shift over 16 pixels together and then copy in a new char from the character map from a null terminated message                       ";
$string = "                   presenting a preview of outbreak, a pill puzzle game in development, but i'm excited to share. use joystick 2 to play. comments can go to tony240zt@gmail.com enjoy our favorite 8bit pill game finally on the c64                      ";

if($argc==2){
 $string = $argv[1];
}

for($i=0;$i<strlen($string);$i++){
 //echo "$string[$i]: ".
 getPETSCII($string[$i], $i, $values);
}

echo "msgLow .byte ";
for($i=0;$i<count($values);$i++){
 echo "\$".$values[$i][1].", ";
}
echo "0\n";

$count = 1;
echo "msgHigh .byte ";
for($i=0;$i<count($values);$i++){
 echo "\$".$values[$i][0].", ";
 $count++;
}
echo "0\n";
$count++;
//echo "Total Bytes: $count\n";

function getPETSCII($chr, $idx, &$values){
 $asc = ord($chr);
 if($chr=="@"){
  return(doMath(0, $idx, $values));
 }
 if($asc>96 && $asc<123){
  return(doMath($asc-96, $idx, $values));
 }
 return(doMath($asc, $idx, $values));
}

function doMath($val, $idx, &$values){
 $offset=12288;
 $ret = dechex(($val * 8) +$offset);
 $values[$idx][0] = $ret[0].$ret[1];
 $values[$idx][1] = $ret[2].$ret[3];
}

?>
