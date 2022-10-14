#!/bin/bash
FILE=WordclockSpacer.ngc
colDist=28 # millimeter
rowDist=31 # millimeter

targetRadius=14 # millimeter

frameHeight=500 # 50 centimeter

# Z parameter
travelheight=3
depth=2
repeate=6

echo -n "Offset in millimeter on left side:"
read dtgSide
echo ""
echo -n "Offset in millimeter on bottom side:"
read dtgBottom
echo ""
echo -n "Tool diameter:"
read drillDiameter
echo ""

echo "; Generated with generate.sh $date" > $FILE
echo "; Parameter:" >> $FILE
echo "; side: $dtgSide mm" >> $FILE
echo "; bottom: $dtgBottom mm" >> $FILE
echo "; drill diameter: $drillDiameter mm" >> $FILE
echo "G21    ; Metrische" >> $FILE
echo "G90     ( Absolute coordinates.        )" >> $FILE
echo "S600  ( RPM spindle speed.           )" >> $FILE
echo "M3      ( Spindle on clockwise.        )" >> $FILE

echo "G64 P0.00500 ( set maximum deviation from commanded toolpath )" >> $FILE
echo "G92.1    ; cancel offset coordinate system and set values to zero" >> $FILE
echo "G00 Z30" >> $FILE
echo "F200     ; 200mm/minutes movement speed" >> $FILE

echo "Start generation..."

radius=$(expr $targetRadius \- $drillDiameter )
offsetSide=$(expr $radius \-  $dtgSide )
offsetBottom=$(expr $radius \- $dtgBottom )
workDepth=$(expr $travelheight \+ $depth )
for y in {0..9}
do
 for x in {0..10}
 do
   echo "; $x-$y" >> $FILE
   currentY=$(expr $y \* $rowDist \+ $offsetBottom )
   currentX=$(expr $x \* $colDist \+ $offsetSide)
   # (this line gives the machine a start point)
   end1=$(expr $currentX \- $radius)
   echo "M3      ( Spindle on clockwise.        )" >> $FILE
   echo "G00 X$end1 Y$currentY" >> $FILE
   echo "G00 Z$travelheight" >> $FILE
   for z in $( seq 0 $repeate )
   do
   currentDepth=$(expr $z \* $depth )
   echo "G01 Z-$currentDepth" >> $FILE
   end2=$(expr $currentX \+ $radius)
   echo "G02 X$end2 Y$currentY R$radius" >> $FILE
   echo "G02 X$end1 Y$currentY R$radius" >> $FILE
   done
   echo "G00 Z$travelheight" >> $FILE
   echo "T1" >> $FILE
   echo "M5 (Spindle stop. )" >> $FILE
 done
done
echo "G00 Z30" >> $FILE
echo "M2 ( Program end. )" >> $FILE

# 10 Zeilen brauchen
rowHeight=$(expr 9 \* $rowDist \+ $offsetBottom \+ $radius )
echo "Cicles use $rowHeight mm"
offsetStart=$(expr \( $frameHeight \- $rowHeight \) \/ 2 )
echo "Move to $offsetStart mm"

