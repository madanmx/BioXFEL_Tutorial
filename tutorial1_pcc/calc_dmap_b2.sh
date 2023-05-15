#!/bin/tcsh -e

# calculate here difference map from calculated FC
# WITH pases!!!
# ONLY FCs REQUIRED

#Run the script using the below command
#./calc_dmap tp_001.pdb tp #where tp is the timepoint 1ps or 10ps 
#$1 pdb of light $2 mtz light $3 timepoint (for column labels) 

set sdir=$PWD

set dark_model = $sdir/dark.pdb            

set dark_FC = $sdir/refine.mtz               

set light_mtz = $sdir/$2      
set refi_model = $sdir/$1
set tim = $3
#set add = $3
set resmax = 2.12
set scalmin = 20.0
set mapmin = 20.0

set make_nonphased_map = 1 #toggle computation of the nonphased map on and offf

mkdir -p work

#prepare the refine.mtz by changing colum label of sig_dark
cad             \
HKLIN1 $dark_FC    \
HKLOUT work/temp_dark.mtz \
<< END-cad

LABIN FILE 1 E1=FC_DARK E2=SIGF_DARK E3=PHIC_DARK
CTYP  FILE 1 E1=F E2=Q E3=P 
LABOUT FILE 1 E1=F_DARK E2=SIGF_${tim} E3=PHIC_${tim}
CTYP  FILE 1 E1=F E2=Q E3=P

END
END-cad



sfall HKLIN work/temp_dark.mtz XYZIN $refi_model HKLOUT work/temp_model_tt.mtz << eof-sfall

# Set the mode for structure factor calc. from a xyzin
      MODE sfcalc hklin xyzin
      CELL 54.98 116.69 117.86 90.00 90.00 90.00 #
      LABIN FP=F_DARK SIGFP=SIGF_${tim}
      LABOUT FC=FC_${tim} PHIC=PHIC_${tim}
      RESOLUTION 20 $resmax
      symmetry 19
      end
eof-sfall

set light_FC = work/temp_model_tt.mtz


# cad things together


cad             \
HKLIN1 $dark_FC    \
HKLIN2 $light_FC     \
HKLOUT work/temp_all.mtz \
<< END-cad

LABIN FILE 1 E1=FC_DARK E2=SIGF_DARK E3=PHIC_DARK
CTYP  FILE 1 E1=F E2=Q E3=P 
LABIN FILE 2 E1=FC_${tim} E2=SIGF_${tim} E3=PHIC_${tim}
CTYP  FILE 2 E1=F E2=Q E3=P


END
END-cad


# scale the things
# labels so far:
# H K L FC_DARK  PHIC_DARK SIGF_DARK FC_LIGHT SIGF_LIGHT PHIC_LIGHT
# 1 scale dark to FC dark
# 2 scale light to dark


echo " SCALEIT NUMBER 1, MARIUS CHECK "


scaleit \
HKLIN work/temp_all.mtz    \
HKLOUT work/temp_all_sc1.mtz    \
<< END-scaleit1
TITLE FPHs scaled to FP
reso $scalmin $resmax      # Usually better to exclude lowest resolution data
#WEIGHT            Sigmas seem to be reliable, so use for weighting
#refine anisotropic
#Exclude FP data if: FP < 5*SIGFP & if FMAX > 1000000
EXCLUDE FP SIG 4 FMAX 10000000
#AUTO
LABIN FP=FC_DARK SIGFP=SIGF_DARK  -
  FPH1=FC_${tim} SIGFPH1=SIGF_${tim} 
CONV ABS 0.000001 TOLR  0.00000001 NCYC 100 
END
END-scaleit1

freerflag HKLIN work/temp_all_sc1.mtz HKLOUT work/temp_all_sc1_free.mtz <<+
freerfrac 0.05
+


echo "MARIUS non-phased (Fourier approximation) map"
echo "FIRST FFT ===> "

fft HKLIN work/temp_all_sc1.mtz MAPOUT work/${tim}_diff_nonph.map << endfft
  RESO $mapmin  $resmax
  GRID 120 250 250
  BINMAPOUT
  LABI F1=FC_${tim} SIG1=SIGF_${tim} F2=FC_DARK SIG2=SIGF_DARK PHI=PHIC_DARK
endfft

# dump the scaled files to calculate the weighted map

mtz2various HKLIN work/temp_all_sc1.mtz  HKLOUT work/temp_light_scaled.hkl << end_mtzv1
     LABIN FP=FC_${tim} SIGFP=SIGF_${tim} PHIC = PHIC_${tim}
     OUTPUT USER '(3I5,3F12.3)'
     RESOLUTION 33.0 $resmax 
end_mtzv1

mtz2various HKLIN work/temp_all_sc1.mtz  HKLOUT work/temp_dark_scaled.hkl << end_mtzv2
     LABIN FP=FC_DARK SIGFP=SIGF_DARK PHIC = PHIC_DARK
     OUTPUT USER '(3I5,3F12.3)'
     RESOLUTION 33.0 $resmax 
end_mtzv2


# this is the wmar.inp file FOR DIFF MAPS ONLY FROM FCALC

echo work/temp_light_scaled.hkl > work/temp_wmar.inp
echo work/temp_light_scaled.hkl >> work/temp_wmar.inp
echo work/temp_dark_scaled.hkl >> work/temp_wmar.inp
echo work/temp_${tim}_dark_calc.phs >> work/temp_wmar.inp


# run summation program
# =======================>

echo "Marius get into one file"
#cp mock-dark.f work/
#./weight_zv2 < temp_wmar.inp
gfortran mock-dark.f -o work/mock-dark 
./mock-dark < work/temp_wmar.inp


#get files back into mtz
f2mtz HKLIN work/temp_${tim}_dark_calc.phs HKLOUT work/temp_${tim}_dphs.mtz << end_weight 
CELL  54.980  116.690  117.860  # angles default to 90
SYMM 19 
LABOUT H   K  L   FC_D_L DUM  DPHI
CTYPE  H   H  H   F       Q    P
END
end_weight


#calculate <phased> difference map

echo
echo "SECOND FFT ===> "

fft HKLIN work/temp_${tim}_dphs.mtz MAPOUT $1_wd.map << END-wfft
  RESO 20.0  $resmax 
  GRID 120 250 250
  BINMAPOUT
  LABIN F1=FC_D_L PHI=DPHI
END-wfft

mapmask mapin $1_wd.map mapout $1_wdex.map xyzin $dark_model << ee
extend xtal
border 0.0
ee








