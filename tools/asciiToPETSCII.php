<?php
$values = array();
$string = "                          this horizontal scroller using 8 sprites all at the same time lined up together. the sprites shift over 16 pixels together and then copy in a new char from the character map from a null terminated message                       ";
$string = "                   presenting a preview of what is to come later this year. use joystick 2 to play. the game has a lot of work left, but i'm excited to share comments can go to tony240zt@gmail.com enjoy our favorite 8bit pill game                       ";
/*
012345678901234567890123456789
*/
$string ="\
 outbreak preview  brought to \
 you by flimsoft code by tony \
 fruzza.  sid  by richard  of \
 new  dimension  included  w/ \
 goattracker.  the  full game \
 to  include  additional game \
 modes,    original    music, \
 improved gfx, more levels to \
 enjoy mutating away  on your \
 c=64.   coming   late   2013 \
        available from        \
  http://www.flimsoft.co.uk/  \
                              \
                              \
                              \
                              \
                              \
 \
"; 


for($i=0;$i<strlen($string);$i++){
 //echo "$string[$i]: ".
 getPETSCII($string[$i], $i, $values);
}

$count = 1;
echo "endingMsg .byte ";
for($i=0;$i<count($values);$i++){
 if($values[$i][0] == 92 || $values[$i][0] == "a"){
  continue;
 }
 if($values[$i][0]!=""){
  echo $values[$i][0].", ";
  $count++;
 }
}
echo "0\n";
$count++;
echo "Total Bytes: $count\n";

function getPETSCII($chr, $idx, &$values){
 $asc = ord($chr);
 if($asc=="10"){
  return;
 }
 if($chr=="@"){
  return(doMath(0, $idx, $values));
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
