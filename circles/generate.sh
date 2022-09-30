#!/bin/bash
FILE=WordclockSpacer.ngc
colDist=28 # millimeter
rowDist=31 # millimeter
radius=11 # millimeter
frameHeight=500 # 50 centimeter

travelheight=3
depth=2

echo -n "Offset in millimeter on left side:"
read dtgSide
echo ""
echo -n "Offset in millimeter on bottom side:"
read dtgBottom
echo ""

echo "G21    ; Metrische" > $FILE
echo "G90     ( Absolute coordinates.        )" >> $FILE
echo "S600  ( RPM spindle speed.           )" >> $FILE
echo "M3      ( Spindle on clockwise.        )" >> $FILE

echo "G64 P0.00500 ( set maximum deviation from commanded toolpath )" >> $FILE
echo "G92.1    ; cancel offset coordinate system and set values to zero" >> $FILE
echo "G00 Z30" >> $FILE
echo "F1800     ; 1800mm/minutes movement speed" >> $FILE
echo "F300     ; 300mm/minutes movement speed" >> $FILE

offsetSide=$(expr $radius \-  $dtgSide )
offsetBottom=$(expr $radius \- $dtgBottom )
workDepth=$(expr $travelheight \+ $depth )
for y in {0..9}
do
 for x in {0..10}
 do
   echo "; $x-$y" | tee -a $FILE
   currentY=$(expr $y \* $rowDist \+ $offsetBottom )
   currentX=$(expr $x \* $colDist \+ $offsetSide)
   # (this line gives the machine a start point)
   end1=$(expr $currentX \- $radius)
   echo "M3      ( Spindle on clockwise.        )" >> $FILE
   echo "G00 X$end1 Y$currentY" >> $FILE
   echo "G00 Z-$travelheight" >> $FILE
   echo "G01 Z-$workDepth" >> $FILE
   end2=$(expr $currentX \+ $radius)
   echo "G02 X$end2 Y$currentY R$radius" >> $FILE
   echo "G02 X$end1 Y$currentY R$radius" >> $FILE
   echo "G00 Z$travelheight" >> $FILE
   echo "T1" >> $FILE
   echo "M5 (Spindle stop. )" >> $FILE
 done
done
echo "G00 Z30" >> $FILE
echo "M2 ( Program end. )" >> $FILE

