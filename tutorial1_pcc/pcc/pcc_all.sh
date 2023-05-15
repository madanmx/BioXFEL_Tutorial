#!/bin/tcsh

# calculate here difference map from calculated FC
# WITH pases!!!
# ONLY FCs REQUIRED

#usage make_pcc.sh <calulated difference map> <delay>
set sdir=$PWD

# edit here ===>

#Use the _wd maps for the input

set ref_map = $1
set obs_map = $2

#if( $#argv > 2 ) then
#	set out_map = ${3}
#       else
#endif

set out_map = all_mask.map

#echo $out_map

mkdir -p pcc_out
# ============== Selection region ===========

#PW 
#Chain A

set xc = 4.223
set yc = 17.031
set zc = 7.557

# sphere radius:
set radius = 3.0

set out_map = pcc_out/PWA_3_mask.map
set scriptdir = $sdir/
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp
echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo X,Y,Z           >> pcc.inp
echo 1/2-X,-Y,1/2+Z >> pcc.inp
echo -X,1/2+Y,1/2-Z >> pcc.inp
echo 1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp

#only run the below line comilation once
#gfortran -ffixed-line-length-none ${scriptdir}RDiffCCP4.f -o RDiffCCP4 
${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/PWA_3.out



# ============== subunit 3 round pyrole water B ===========

# sphere center:
set xc = 5.549
set yc = 11.266
set zc = -48.215

# sphere radius:
set radius = 3.0

set out_map = pcc_out/PWB_3_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere

echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/PWB_3.out


# ============== subunit 7 round pyrole water A ===========
#PW 
#Chain A
# sphere center: 4.249  17.031  7.557
set xc = 4.223
set yc = 17.031
set zc = 7.557

# sphere radius:
set radius = 9

set out_map = pcc_out/PWA_9_mask.map

echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp
echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo X,Y,Z           >> pcc.inp
echo 1/2-X,-Y,1/2+Z >> pcc.inp
echo -X,1/2+Y,1/2-Z >> pcc.inp
echo 1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp

#only run the below line comilation once
#gfortran -ffixed-line-length-none RDiffCCP4.f -o RDiffCCP4 
${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/PWA_9.out



# ============== subunit 7 round pyrole water B ===========

# sphere center:

set xc = 5.549
set yc = 11.266
set zc = -48.215

# sphere radius:
set radius = 9

set out_map = pcc_out/PWB_9_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere

echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/PWB_9.out


#************************************************************************


#************************* Around D-ring 3 Å
#A
# sphere center:

set xc = 6.315 
set yc = 22.351
set zc = 3.995

# sphere radius:
set radius = 4

set out_map = pcc_out/DA_4_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/DA_4.out

# ============== subunit B around D-ring===========
#B
# sphere center:


set xc = 4.036 
set yc = 5.886
set zc = -44.536

# sphere radius:
set radius = 4

set out_map = pcc_out/DB_4_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/DB_4.out


#**************************************************


#************************* Around His260 ***************

#A
# sphere center:
   
set xc = 0.57
set yc = 15.942
set zc = 6.537

# sphere radius:
set radius = 2.5

set out_map = pcc_out/H260A_2p5_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/H260A_2p5.out

#******************B
# sphere center:
#3.092  14.124 -47.589
set xc = 3.092 
set yc = 14.124
set zc = -47.589

# sphere radius:
set radius = 2.5

set out_map = pcc_out/H260B_2p5_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/H260B_2p5.out


#*******************************************************************

#************************* Around C36 1.5 Å
#A
# sphere center:
#0.468  17.216   1.378
set xc = 0.468 
set yc = 17.216
set zc = 1.378

# sphere radius:
set radius = 2.5

set out_map = pcc_out/CpropA_2p5_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/CpropA_2p5.out

#B
# sphere center:
#1.784  13.399 -42.272
set xc = 1.784 
set yc = 13.399
set zc = -42.272

# sphere radius:
set radius = 2.5

set out_map = pcc_out/CpropB_2p5_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/CpropB_2p5.out


#************************* Around C30 2 Å

#A
# sphere center:
#-0.400  11.378   4.030
set xc = -0.400
set yc = 11.378
set zc = 4.030

# sphere radius:
set radius = 2.5

set out_map = pcc_out/BpropA_2p5_mask.map


# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/BpropA_2p5.out

#B
# sphere center:
#4.505  18.546 -44.946
set xc = 4.505
set yc = 18.546
set zc = -44.946

# sphere radius:
set radius = 2.5

set out_map = pcc_out/BpropB_2p5_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/BpropB_2p5.out



#*************************** Above are C-prop and D-prop



# 9.367  18.568   8.217 CG Asp207 Chain A
#A
# sphere center:
set xc = 9.367
set yc = 18.568
set zc = 8.217

# sphere radius:
set radius = 3

set out_map = pcc_out/D207A_3_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/D207A_3.out

#B
# 9.133   7.071 -48.269 CG Asp207 Chain B
# sphere center:
set xc = 9.133 
set yc = 7.071
set zc = -48.269

# sphere radius:
set radius = 3

set out_map = pcc_out/D207B_3_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/D207B_3.out




#*************************** Magic water ************************************
#HETATM 5231  O   HOH S 286       6.880  18.478   8.309  0.50 50.92           O 


# 9.367  18.568   8.217 CG Asp207 Chain A
#A
# sphere center:
set xc = 6.880
set yc = 18.478
set zc = 8.309

# sphere radius:
set radius = 2

set out_map = pcc_out/MWA_2_mask.map

# prepare input file
# line 1: calculated difference map
# line 2: observed difference map
# line 3: output map with sphere
# line 4: number N of symmetry operators
# line 5 - 5+N: symmetry operators as in ccp4 lib
# line 6+N: center of the sphere for Pearson CC
# line 7+N: radius of sphere


echo $ref_map > pcc.inp
echo $obs_map >> pcc.inp
echo $out_map >> pcc.inp
echo 4                >> pcc.inp
echo  X,Y,Z           >> pcc.inp
echo   1/2-X,-Y,1/2+Z >> pcc.inp
echo   -X,1/2+Y,1/2-Z >> pcc.inp
echo   1/2+X,1/2-Y,-Z >> pcc.inp
echo $xc $yc $zc >> pcc.inp
echo $radius >> pcc.inp


${scriptdir}RDiffCCP4 < pcc.inp > pcc_out/MWA_2.out





#*****************************************************************

echo "Summary of pccs" > pcc_summary.txt

foreach file (pcc_out/*.out)
echo $file >> pcc_summary.txt
grep 'CORRELATION COEFFICIENT :' $file >> pcc_summary.txt
end


pend:

# rm -rf pcc_out/*mask.map
