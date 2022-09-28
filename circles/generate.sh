#!/bin/bash
FILE=spacer.gcode
colDist=28 # millimeter
rowDist=31 # millimeter
radius=11 # millimeter

echo "G21    ; Metrische"
echo "G90     ( Absolute coordinates.        )" > $FILE
echo "S600  ( RPM spindle speed.           )" >> $FILE
echo "M3      ( Spindle on clockwise.        )" >> $FILE

echo "G64 P0.00500 ( set maximum deviation from commanded toolpath )"echo "G92.1    ; cancel offset coordinate system and set values to zero" >> $FILE
echo "G00 Z30" >> $FILE
echo "F1800     ; 1800mm/minutes movement speed" >> $FILE

for x in {1..10}
do
 for y in {1..11}
 do
   echo "; $x-$y" | tee -a $FILE
   currentX=$(expr $x \* $colDist)
   currentY=$(expr $y \* $rowDist)
   # (this line gives the machine a start point)
   end1=$(expr $currentX \- $radius)
   echo "G01 X$end1 Y$currentY" >> $FILE
   end2=$(expr $currentX \+ $radius)
   echo "G02 X$end2 Y$currentY R$radius" >> $FILE
   echo "G02 X$end1 Y$currentY R$radius" >> $FILE
 done
done
