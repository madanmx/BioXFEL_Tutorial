
C WITHIN A CERTAIN MASK
C 
C ALGORITHM
C READ IN REFERENCE MAP (MAY BE CALCULATED)
C READ IN OBSERVED MAP
C SPECIFY MASK (COORDINATES AND RADIUS)
C RUN OVER ALL GRID POINTS IN THE MASK
C CALCULATE
C                          SUM (RHO1 - RMS1)*(RHO2-RMS2)
C    PEARSON_RHO = --------------------------------------------
C                  SQRT(SUM (RHO1 - RMS1)**2*(RHO2-RMS2)**2) )
C 
C RESTRICIONS
C WORKS NOW WITH MAPS IN CCP4 FORMAT 
C Marius Schmidt Jan 2019


       COMMON /MAPIO/ INMAP,IOMAP,NHDRS,CCELL,NNSYM,NX,NY,NZ,
     *                AMN,AMX,AMEAN,ARMS,BUFI
       DIMENSION CCELL(6),BUFI(20000000)

        DIMENSION RHOR(100000),RHOO(100000),MASK(100000)
        CHARACTER*80 FRO,FREF,OUTMAP

        CHARACTER*36 SYMOP(24)
        DIMENSION SYM(3,4,24)


        WRITE(*,100) 'REFERENCE DIFFERENCE ELECTRON DENSITY        : '
        READ(*,200)   FREF 
        WRITE(*,300)  FREF(1:40)
        WRITE(*,100) 'OBSERVED DIFFERENCE ELECTRON DENSITY         : '
        READ(*,200)   FRO 
        WRITE(*,300)  FRO(1:40)
        WRITE(*,100) 'OUTPUT MAP DISPAYING SPHERICAL VOLUME ONLY   : '
        READ(*,200)   OUTMAP
        WRITE(*,300)  OUTMAP(1:40)

C 
C SYMMETRY OPERATORS
        WRITE(*,*)
        WRITE(*,*)
        
        WRITE(*,*) ' READ SYMMETRY OPERATORS (FOR OUTPUT ONLY) ===> '
        READ(*,*) NSYM
        DO 1300 I = 1, NSYM
        READ(*,'(A)') SYMOP(I)
        J = MATSYM(SYM(1,1,I), SYMOP(I), ICOL)
        IF (J .LE. 0) GO TO 1300
        WRITE(*,1200) J, I, SYMOP, ICOL
 1200    FORMAT(' ERROR NUMBER',I2,' AT MATSYM IN SYMMETRY OPERATOR', I2,
     *       /,'->',A36,/,
     *       ' AT CHARACTER POSITION ',I2)
        STOP ' MATSYM ERROR '
 1300    WRITE(*,1400) I, SYMOP(I), ((SYM(J,K,I),K=1,4),J=1,3)
 1400    FORMAT(/,'SYMMETRY OPERATOR: ',I2,5X,A36,/,
     *       3(5X,3F5.1,5X,F10.5,/) )


        WRITE(*,*)
        WRITE(*,100) 'READ MASK COORDINATES                        : '
        READ(*,*)     X,Y,Z 
        WRITE(*,400)  X,Y,Z 
        WRITE(*,100) 'READ MASK RADIUS                             : '
        READ(*,*) RADIUS
        WRITE(*,500) RADIUS

100    FORMAT(A)
200    FORMAT(A)
300    FORMAT(' FILE: ',A40)
400    FORMAT(' MASK COORDINATES X Y Z :  ',3F8.3)
500    FORMAT(' MASK RADIUS            :  ',F8.3)

C PREPARE REFERENCE MAP 
        CALL RDCCP4(FREF)
        ARMS1 = ARMS
        CALL SETMAT(CCELL)
        CALL GEN_MASK(RADIUS,X,Y,Z,MASK,NM)
        WRITE(*,600) NM
 600    FORMAT(' NUMBER OF GRID POINTS IN MASK : ',I15,/,/) 
        CALL GETRHO(MASK,RHOR,NM)

C PREPARE OBSERVED MAP 
        CALL RDCCP4(FRO)
        ARMS2 = ARMS
        CALL GETRHO(MASK,RHOO,NM)

C SCALE RHOO AND RHOR
C SCALING NOT NECESSARY FOR PEARSON
C        CALL SCALMAP(RHOR,RHOO,NM)

C CALCULATE PEARSON CORRELATION-VALUE
        CALL PCORR(RHOR,RHOO,NM,ARMS1,ARMS2,IP,RR)

        WRITE(*,*)
        WRITE(*,*) 
        WRITE(*,*)  ' ===================================== '
        WRITE(*,*)  ' ===================================== '
        WRITE(*,*)
        WRITE(*,900) IP,NM,RR
 900    FORMAT(' PEARSON CORRELATION COEFFICIENT     ',/,
     *         ' MATCHED GRID POINTS > 1.5 SIGMA     ',I15,/,
     *         ' SELECTED FROM GRID POINTS IN MASK   ',I15,/,
     *         ' CORRELATION COEFFICIENT :',F15.3)
        WRITE(*,*)
        WRITE(*,*)  ' ===================================== '
        WRITE(*,*)  ' ===================================== '



C ===================================== 
C ONLY RELEVANT FOR OUTPUT MAP, MAP/MASK CAN BE CHECKED IN COOT
C AFTER EXTENDING OVER MOLECULE SCRIPT ext.sh
C SYMOPS ARE USED TO RECONSTRUCT UNIT CELL
C OTHERWISE NO PROPER DISPLAY WITH COOT
C DELETE BUFI AFTER HEADER

C DELETE BUFFER       
       IR=NX*NY*NZ
       DO 1900 I=NHDRS+1,IR+NHDRS
         BUFI(I)=0.0
 1900  CONTINUE

C WRITE OUT SPHERE
C EXPAND BY SYMOPS

       DO 3300 I=1,NM

        NGRID=MASK(I)-NHDRS

C FOR TEST
C        GOTO 2150

          Z= INT( NGRID / (NX*NY)) / FLOAT(NZ)
          NXY= MOD(NGRID,NX*NY)
          IF (NXY.EQ.0) NXY=NX*NY
          X= INT( NXY / NY) / FLOAT(NX)
          NNY=MOD(NGRID,NY)
          IF (NNY.EQ.0) NNY=NY
          Y= NNY/ FLOAT(NY)

         DO 2300  J=1,NSYM
          XP = SYM(1,1,J)*X + SYM(1,2,J)*Y + SYM(1,3,J)*Z + SYM(1,4,J)
          YP = SYM(2,1,J)*X + SYM(2,2,J)*Y + SYM(2,3,J)*Z + SYM(2,4,J)
          ZP = SYM(3,1,J)*X + SYM(3,2,J)*Y + SYM(3,3,J)*Z + SYM(3,4,J)
          XP = AMOD(XP, 1.0)
          YP = AMOD(YP, 1.0)
          ZP = AMOD(ZP, 1.0)
C          write(*,*) xp,yp,zp
          IF (XP .LT. 0.0) XP = XP + 1.0
          IF (YP .LT. 0.0) YP = YP + 1.0
          IF (ZP .LT. 0.0) ZP = ZP + 1.0

          II=XP*NX
          KK=YP*NY
          JJ=ZP*NZ 
C JJ IS Z, KK IS Y, II IS X   
          NNGRID = JJ*NX*NY+II*NY+KK 

          IF (NNGRID.GT.IR) WRITE(*,*) 'EXCEEDS GRID'
          IF (NNGRID.LT.0)  WRITE(*,*) 'NEGATIVE GRID'

C FOR TEST ONLY
C          IF (J.EQ.1) WRITE(*,*) NGRID,NNGRID

           BUFI(NNGRID+NHDRS) = 2.0

 2300   CONTINUE

 3300  CONTINUE


       WRITE(*,*)
       WRITE(*,*) 'WRITE EMPTY MAP WITH MASK FOR CHECK ONLY '
       NTOT = IR + NHDRS
       NBYTE = NTOT*4
       WRITE(*,3500) NTOT,NBYTE,OUTMAP
 3500  FORMAT(' EMPTY MAP WRITTEN OUT, WITH MASK VOLUME FILLED WITH RHO = 2.0 ',/,
     *        ' TOTAL NUMBER OF WORDS, TOTAL NUMBER OF BYTES : ',2I15,
     *        ' FILENAME : ',A60,/,/) 
       open(unit=11,file=OUTMAP,access='direct',
     * form='unformatted',recl=NBYTE)
       WRITE(11,rec=1) BUFI(1:NTOT)
       close(11)
    

       END



       SUBROUTINE PCORR(RHO1,RHO2,NM,AR1,AR2,IPOS,RR)

       DIMENSION RHO1(1),RHO2(1)
       RSM1=0.0
       RSM2=0.0
       IPOS=0
C RRRD TIME ARMS FOR EACH MAP
       RRRD = 1.5
       ANUM = 0.0
       DNM1 = 0.0
       DNM2 = 0.0
C PEARSON CORRELATION
C RSMs ARE USUALLY ZERO,,, MIGHT NOT BE IN BLOB
C PICK MAP1 (REFERENCE MAP)
       DO 1000 I=1,NM
        IF  ((RHO1(I).GT.RRRD*AR1.OR.RHO2(I).GT.RRRD*AR2).OR. 
     *  (RHO1(I).LT.-RRRD*AR1.OR.RHO2(I).LT.-RRRD*AR2) ) THEN
          RSM1=RSM1+RHO1(I)
          RSM2=RSM2+RHO2(I)
          IPOS=IPOS+1
        ENDIF
 1000   CONTINUE
        RSM1=RSM1/IPOS
        RSM2=RSM2/IPOS

       DO 2000 I=1,NM

         ANUM = ANUM + (RHO1(I)-RSM1) * (RHO2(I)-RSM2)
         DNM1 = DNM1 + (RHO1(I)-RSM1)**2
         DNM2 = DNM2 + (RHO2(I)-RSM2)**2
 2000  CONTINUE

C PEARSON CORRELATION

       RR = ANUM/(SQRT(DNM1*DNM2))

       RETURN
       END
      




       SUBROUTINE GETRHO(MASK,RHO,NP)
C MASK: CONTAINS GRIDPOINT NUMBER (OUTPUT)
C RHO : CONTAINS RHO AT GRIDPOINT NUMBER (OUTPUT)
C NP  : NUMBER OF POINTS IN MASK
C USES GRID VALUES STORED IN MASK TO EXTRACT
C RHO VALUES FROM A MAP
C MAP MUST BE CALCULATED ON SAME GRID AS
C MASK
C
C NOTE ! CCELL IS OBSOLETE IN THIS SUBROUTINE SINCE
C INPUT BY INPUT FILE

       COMMON /MAPIO/ INMAP,IOMAP,NHDRS,CCELL,NNSYM,NX,NY,NZ,
     *                AMN,AMX,AMEAN,ARMS,BUFI
       DIMENSION CCELL(6),BUFI(20000000)

       COMMON /CORRECT/ CORRF(50),RLASER(50)
C
       DIMENSION MASK(1)
       DIMENSION RHO(1)
        DO  900 I=1,NP
        NGRID=MASK(I)
        RHO(I)=BUFI(NGRID)
  900  CONTINUE
       RETURN
       END


       SUBROUTINE OL(XF,YF,ZF,D)
C DETERMINES ORHOGONAL LENGTH OF FRACTIONAL VECTOR XF,YF,ZF
C COMMON
       COMMON /MATRIX/  MAT11,MAT12,MAT13,MAT22,MAT23,MAT33,
     *            IMAT11,IMAT12,IMAT13,IMAT22,IMAT23,IMAT33
       REAL*4  MAT11,MAT12,MAT13,MAT22,MAT23,MAT33
       REAL*4  IMAT11,IMAT12,IMAT13,IMAT22,IMAT23,IMAT33

        XO=XF*MAT11+YF*MAT12+ZF*MAT13
        YO=YF*MAT22+ZF*MAT23
        ZO=ZF*MAT33
        D=SQRT(XO**2+YO**2+ZO**2)
       RETURN
       END



          SUBROUTINE GEN_MASK(RADIUS,X,Y,Z,MASK,NM)
C PRETTY OBVIOUS
C
C SPHERE WILL BE GENERATED WITH RADIUS AROUND X,Y,Z
C AND GRID POINT NUMBER WILL BE STORED IN MASK. GRID
C POINT NUMBER IS FULLY DETERMINED BY NX,NY,NZ AND
C THE CELL CONSTANTS, NO MAP NEED TO BE READ IN UNLESS
C INFORMATION OF NX,NY,NZ AND CELL IS NEEDED FROM THE
C HEADER.
C NM CONTAINS TOTAL NUMBER OF GRID POINTS IN MASK
C

       COMMON /MAPIO/ INMAP,IOMAP,NHDRS,CCELL,NNSYM,NX,NY,NZ,
     *                AMN,AMX,AMEAN,ARMS,BUFI
       DIMENSION CCELL(6),BUFI(20000000)
       COMMON /CORRECT/ CORRF(50),RLASER(50)

C
       DIMENSION MASK(1)
C
C
C DETERMINE X-MAX/MIN,Y-MAX/MIN,ZMAX/MIN IN SPHERE
C ADD ABOUT HALF OF A GRID POINT:
        XA=CCELL(1)/(2*NX)
        YA=CCELL(2)/(2*NY)
        ZA=CCELL(3)/(2*NZ)
 
C
        XMAX=X+(RADIUS+XA)
        XMIN=X-(RADIUS+XA)
        YMAX=Y+(RADIUS+YA)
        YMIN=Y-(RADIUS+YA)
        ZMAX=Z+(RADIUS+ZA)
        ZMIN=Z-(RADIUS+ZA)

C        write(*,*) 'head, cell ', nhdrs,ccell,xmax,xmin,ymax,ymin,zmax,zmin

C FRACTIONALIZE COORDINATE AND EXTREMA IN SPHERE TO DETERMINE
C WHERE TO RUN, COORDINATE IS TAKEN AS IT IS  (CARE FOR PERIODIC
C BOUNARY LATER)
        CALL O2F(X,Y,Z,XF,YF,ZF)
        CALL O2F(XMAX,Y,Z,XMXF,DUMM,DUMMY)
        CALL O2F(XMIN,Y,Z,XMNF,DUMM,DUMMY)
        CALL O2F(X,YMAX,Z,DUMM,YMXF,DUMMY)
        CALL O2F(X,YMIN,Z,DUMM,YMNF,DUMMY)
        CALL O2F(X,Y,ZMAX,DUMM,DUMMY,ZMXF)
        CALL O2F(X,Y,ZMIN,DUMM,DUMMY,ZMNF)

C        write(*,*) 'x,y,z,xf,yf,zf ', x,y,z,xf,yf,zf 
      
        write(*,200) xmin,xmax,ymin,ymax,zmin,zmax
 200    FORMAT(' BOX FROM XMIN TO XMAX,      YMIN TO YMAX,      ZMIN TO ZMAX ',/,
     *         '       ',2F8.3,' ||  ',2F8.3,' ||  ',2F8.3,/) 

C DETERMINE SEARCH BOX BOUNDARIES:
C FRACTIONAL TO GRID INT(FC*NX)+1
C NINT NOT VERY RELIABLE
        NXMX=INT(XMXF*NX)+2
        NXMN=INT(XMNF*NX)-2
        NYMX=INT(YMXF*NY)+2
        NYMN=INT(YMNF*NY)-2
        NZMX=INT(ZMXF*NZ)+2
        NZMN=INT(ZMNF*NZ)-2


C RUN THROUGH SEARCH BOX
        LL=0
        NNX=NXMX-NXMN
        NNY=NYMX-NYMN
        NNZ=NZMX-NZMN

        WRITE(*,300) nxmn,nymn,nzmn,nxmx,nymx,nzmx,nnx,nny,nnz
 300    FORMAT(' BOX GRID FROM NXMIN TO NXMAX, NYMIN TO NYMAX, NZMIN TO NZMAX ',/,
     *         ' NXMIN   ',I8,' || NYMIN  ',I8,' || NZMIN  ',I8,/,
     *         ' NXMAX   ',I8,' || NYMAX  ',I8,' || NZMAX  ',I8,/,
     *         ' TOTALX  ',I8,' || TOTALY ',I8,' || TOTALZ ',I8)

       DO 1500 JJ=1,NNZ
        DO 1400 KK=1,NNY
          DO 1300 II=1,NNX
C DON'T MIND NEGATIVE VALUES
C NEGATIVE (ZERO) GRID VALUES WILL BE CORRECTED BY PERIODIC
C BOUDARIES LATER IN THE PROGRAM
C
           J=NZMN+JJ-1
           K=NYMN+KK-1
           I=NXMN+II-1
           GFX=FLOAT(I)/FLOAT(NX)
           GFY=FLOAT(K)/FLOAT(NY)
           GFZ=FLOAT(J)/FLOAT(NZ)
C DETERMINE FRACTIONAL DISTANCES BETWEEN COORDINATES
          DX=GFX-XF
          DY=GFY-YF
          DZ=GFZ-ZF
C
C DETERMINe LENGTH OF VECTOR DX,DY,DZ IN ORTHO
C SUBROUTINE OL TAKES SQRT
        CALL OL(DX,DY,DZ,DIST)

        IF (DIST.LT.RADIUS) THEN
            LL=LL+1

C PERIODIC BOUNDARY CONDITIONS:
            KKK=K
            JJJ=J
            III=I
C IF NEGATIVE SUBSTRACT ABSOLUTE GRID (ADD NEGATIVE)
C J IS Z, I IS X, K IS Y
            IF (KKK.LE.0)     KKK=NY+KKK
            IF (KKK.GT.NY)    KKK=KKK-NY
            IF (JJJ.LE.0)     JJJ=NZ+JJJ
            IF (JJJ.GT.NZ)    JJJ=JJJ-NZ
            IF (III.LE.0)     III=NX+III
            IF (III.GT.NX)    III=III-NX
C STORE GRID VALUE IN MASK
C            NGRID=KKK*NX*NZ+JJJ*NX+III+1
C            NGRID=JJJ*NX*NY+KKK*NX+III + 1
C J IS Z, I IS X, K IS Y
             NGRID=JJJ*NX*NY+III*NY+KKK 
C            write(*,*) LL,NGRID
            MASK(LL)=NGRID+NHDRS
         ENDIF
 1300  CONTINUE
 1400  CONTINUE
 1500  CONTINUE
 1302  CONTINUE
       NM=LL
       RETURN
       END


C
       SUBROUTINE O2F(X,Y,Z,XF,YF,ZF)
C FRACTIONALIZES VECTOR X,Y,Z
       COMMON /MATRIX/  MAT11,MAT12,MAT13,MAT22,MAT23,MAT33,
     *            IMAT11,IMAT12,IMAT13,IMAT22,IMAT23,IMAT33
       REAL*4  MAT11,MAT12,MAT13,MAT22,MAT23,MAT33
       REAL*4  IMAT11,IMAT12,IMAT13,IMAT22,IMAT23,IMAT33

        XF=x*IMAT11+y*IMAT12+z*IMAT13
        YF=y*IMAT22+z*IMAT23
        ZF=z*IMAT33
C TAKE CARE OF PERIODIC BOUNDARIES SOMEWHERE ELSE
C        XF=AMOD(XF,1.0)
C        YF=AMOD(YF,1.0)
C        ZF=AMOD(ZF,1.0)
C        IF (XF.LT.0.0) XF=XF+1.0
C        IF (YF.LT.0.0) YF=YF+1.0
C        IF (ZF.LT.0.0) ZF=ZF+1.0

       RETURN
       END


	SUBROUTINE RDCCP4(FNAM)

C IN CCP4 MAPS, THE HEADER IS ALWAYS 1024 BYTES
C THIS CLEARLY FAVOURS THE SIZE OF THE BUFFER BEEING 1024 BYTES      
C THIS SUBROUTINE CALCULATES THE SIZE OF THE ENTIRE MAP
C FROM HEADER INFORMATION. THEN CLOSES THE FILE, AND REOPENS
C WITH THIS SIZE INFORMATION. IT READS THEN ONLY _ONE_ RECORD 
C FFT MAPS FROM CCP4 DIFFER FROM THEIR ASSIGNMENT OF COLUMNS/ROWS/SECTIONS 
C NORMALLY Z IS FASTEST, FOLLOWED BY X AND THEN Y
C IN FSFOUR MAPS X IS NORMALLY FASTEST FOLLOWED BY Y AND Z
C
C
C       COMMON /MAPARM/ NC,NR,NS,NMODE,NCST,NRST,NSST,NX,NY,NZ,CELL,
C     *                 MAPC,MAPR,MAPS,NSB 
C
       COMMON /MAPIO/ INMAP,IOMAP,NHDRS,CCELL,NNSYM,NX,NY,NZ,
     *                AMN,AMX,AMEAN,ARMS,BUFI
       DIMENSION CCELL(6),BUFI(20000000)

       CHARACTER*80 FNAM,TIT
C
       BYTE BUF(1024)
       DIMENSION HDRBUF(256)
       dimension CELL(6),DATA(256)
       CHARACTER*1024 CBUF 
       CHARACTER*80 CLABL(10)
C EQUIVALENCE TO INTERPRET THE HEADER 
       EQUIVALENCE (HDRBUF(1),NC),(HDRBUF(2),NR),(HDRBUF(3),NS)
       EQUIVALENCE (HDRBUF(4),NMODE),(HDRBUF(5),NCST),(HDRBUF(6),NRST)
       EQUIVALENCE (HDRBUF(7),NSST),(HDRBUF(8),NNX),(HDRBUF(9),NNY)
       EQUIVALENCE (HDRBUF(10),NNZ),(HDRBUF(11),CELL(1))
       EQUIVALENCE (HDRBUF(17),MAPC),(HDRBUF(18),MAPR),(HDRBUF(19),MAPS)
       EQUIVALENCE (HDRBUF(20),AAMN),(HDRBUF(21),AAMX),
     *             (HDRBUF(22),AAMEAN)
       EQUIVALENCE (HDRBUF(23),IISPG),(HDRBUF(24),NSB),(HDRBUF(25),LSKF)
       EQUIVALENCE (HDRBUF(54),MACH)
       EQUIVALENCE (HDRBUF(55),AARMS),(HDRBUF(56),NLABL)
       EQUIVALENCE (HDRBUF(57),CLABL(1))
       EQUIVALENCE (buf(1),dat1), (buf(5),dat2)
       EQUIVALENCE (DATA(1),BUF(1))
C       

C  READ THE BUFFER, CALCULATE THE LENGTH  

       OPEN(UNIT=10,FILE=FNAM,ACCESS='DIRECT',
     * FORM='UNFORMATTED',RECL=1024)

       read(10,rec=1) HDRBUF 

C  ASSIGN EQUIVALENCES TO COMMON VARIABLES
       NX = NNX
       NY = NNY
       NZ = NNZ
       ISPG = IISPG
       AMN=AAMN
       AMX=AAMX
       AMIN = AMN
       AMAX = AMX
       AMEAN = AAMEAN
       ARMS = AARMS
       DO 100 I=1,6 
        CCELL(I)=CELL(I)
 100   CONTINUE
       WRITE(*,400) NC,NR,NS,NMODE,NCST,NRST,NSST
       WRITE(*,500) NX,NY,NZ
       WRITE(*,600) CCELL
       WRITE(*,700) MAPC,MAPR,MAPS,ISPG,NSB,NLABL
       DO 300 I=1,NLABL
        WRITE(*,350) I,CLABL(I)
 300   CONTINUE
 350   FORMAT(' LABEL(',I1,'):',A)
       WRITE(*,800) AMN,AMX,AMEAN,ARMS,MACH

 400   FORMAT(' NUMBER OF COLUMNS      : ', I10,/,
     *        ' NUMBER OF ROWS         : ', I10,/,
     *        ' NUMBER OF SECTIONS     : ', I10,/,
     *        ' MODE (O,1,2,3,4)       : ', I10,/,
     *        ' FIRST COLUMN IN MAP    : ', I10,/,
     *        ' FIRST ROW IN MAP       : ', I10,/,
     *        ' FIRST SECTION IN MAP   : ', I10 )
 500   FORMAT(' INTERVALS ALONG X      : ', I10,/,
     *        ' INTERVALS ALONG Y      : ', I10,/,
     *        ' INTERVALS ALONG Z      : ', I10)
 600   FORMAT(' CELL DIMENSIONS ',/,
     *        ' A      : ',F10.3,/,
     *        ' B      : ',F10.3,/,
     *        ' C      : ',F10.3,/, 
     *        ' ALPHA  : ',F10.3,/, 
     *        ' BETA   : ',F10.3,/, 
     *        ' GAMMA  : ',F10.3)
 700   FORMAT(' AXIS CORRESPONDING TO COLUMNS  : ',I6,/,
     *        ' AXIS CORRESPONDING TO ROWS     : ',I6,/,
     *        ' AXIS CORRESPONDING TO SECTIONS : ',I6,/,
     *        ' SPACE GROUP NUMBER             : ',I6,/,
     *        ' BYTES USED TO STORE SYM-OPS    : ',I6,/,
     *        ' NUMBER OF LABELS USED          : ',I6)
 800   FORMAT(' MINIMUM DENSITY IN MAP         : ',F12.6,/,
     *        ' MAXIMUM DENSITY IN MAP         : ',F12.6,/,
     *        ' AVERAGE (MEAN) DENSITY IN MAP  : ',F12.6,/,
     *        ' RMS DEVIATION FROM AVERAGE     : ',F12.6,/,
     *        ' MACHINE STAMP INT REPRESENT    : ',I12)           

 
      
      NNSYM=NSB/80
      NSW = NSB/4
      READ(10,REC=2) CBUF(1:NSB)
      WRITE(*,*) 'SYMMETRY OPERATORS: '
      DO 1000 I=1,NNSYM
      WRITE(*,900) CBUF(((I-1)*80+1):(80*I)) 
 900  FORMAT(' ',A)
1000  CONTINUE

      IR=NC*NR*NS+256+NSW
      NOR=INT(IR/256)
      NREST=MOD(IR,1024)
      WRITE(*,1100) NOR,NREST,IR*4,IR
1100  FORMAT(' NUMBER OF 256 WORD RECORDS INCL. HEADER: ',I10,/,
     *       ' + 1 PARTIALLY FILLED BY ',I4,' WORDS',/,
     *       ' TOTAL BYTES ', I10,/,
     *       ' TOTAL WORDS ', I10)

      NBYTE = IR * 4
      NTOT = IR
      NHDRS = 256+NSW

      WRITE(*,1200) NBYTE,NTOT,NHDRS
1200  FORMAT(' ENTIRE FILE WILL BE READ === ',/,
     *       ' TOTAL BYTES         : ',I15,/,
     *       ' TOTAL WORDS         : ',I15,/,
     *       ' HEADER              : ',I15) 

      CLOSE(10)
C TOTAL MAP: HEADER + SYMOP + MAPARRAY  WORDS
C THIS IS REALLY CRAZY
       OPEN(UNIT=10,FILE=FNAM,ACCESS='direct',form='unformatted',recl=NBYTE)
       READ(10,rec=1) BUFI(1:NTOT)
       CLOSE(10)


      END
 





        SUBROUTINE RDFSFOUR
C READS FSFOUR MAP (INTEGER*4 MAP)
C XTAL VIEW FSFOUR MAPS DO NOT CONTAIN SYMMETRY OPERATORS
C READ MAPS FROM COMMON VARIABLE INMAP 
C E-DENSITY (FLOAT) IS FOUND IN BUFI


       COMMON /MAPIO/ INMAP,IOMAP,NHDRS,CCELL,NNSYM,NX,NY,NZ,
     *                AMN,AMX,AMEAN,ARMS,BUFI
       DIMENSION CCELL(6),BUFI(20000000)


       DIMENSION IBUF(500)
       DIMENSION TS(3,24),IS(2,3,24)


        READ (INMAP) TIT,NOSET,CCELL,NNSYM,NCENT,LATT,NPIC
C IN MOST CASES NO SYM OPS ARE STORED IN FSFOUR MAP
C BUT THE NUMBER OF SYM OPS
        DO 100 I=1,NNSYM
          READ(INMAP) (TS(J,I),(IS(K,J,I),K=1,2),J=1,3)
 100    CONTINUE
        READ(INMAP) NX,NY,NZ,SCALE,NORN
C INTERCHANGE NZ AND NY
        IF (NORN.EQ.0) THEN
          LENGTH=NX
          NT=NY
          NY=NZ
          NZ=NT
        ENDIF
        IF (NORN.NE.0) THEN
         STOP ' MAP FORMAT NOT SUPPORTED BY THIS PROGRAM '
        ENDIF
        NW=0
        J=0
        RMN=1000.0
        RMX=-1000.0
        RMEAN=0.0
        SR=0.0
 200    READ(INMAP,END=500) (IBUF(I),I=1,LENGTH)
        NW=NW+LENGTH
        J=J+1
C STORE ENTIRE MAP IN BUFFER BUFI
C CALCULATE MEAN AND DETERMINE EXTREMAS
          DO 300 I=1,LENGTH
            RHO=FLOAT(IBUF(I))
            IPS=(J-1)*LENGTH
            BUFI(IPS+I)=RHO
            RMEAN=RMEAN+RHO
            IF (RHO.LT.RMN) RMN=RHO
            IF (RHO.GT.RMX) RMX=RHO
 300      CONTINUE
        GOTO 200
 500    CONTINUE
        AMN=RMN
        AMX=RMX
        AMEAN=RMEAN/NW
C RUN AGAIN OVER THE MAP TO DETERMINE SIGMA (RMS)
        DO 600 I=1,NW
         SR=(BUFI(I)-AMEAN)**2+SR
 600    CONTINUE
C CALCULATE ROOT MEAN SQUARE
         ARMS=SQRT(SR/NW)
        WRITE(*,800) NORN,NX,NY,NZ,NW,AMN,AMX,AMEAN,ARMS
 800    FORMAT(' FSFOUR MAP FORMAT, MODE=',I1,', ONLY SUPPORTED ',/,
     *         ' GRID POINTS NX,NY,NZ                : ',3I8,/,
     *         ' NUMBER OF DATA POINTS READ          : ',I8,/,
     *         ' MIN, MAX, AVERAGE AND RMS RHO       : ',4F8.3)
        WRITE(*,900) CCELL,NNSYM
 900    FORMAT(' CELL CONSTANTS A B C ALFA BETA GAMMA: ',6F8.2,/,
     *         ' NUMBER OF SYMMETRY OPERATORS        : ',I8)
        RETURN
        END



        SUBROUTINE SCALMAP(RHOC,RHOO,NM)
C SCALE MAP TO ORIGINAL VALUE
C DETERMINE SCALE FROM 2 SIGMA FEATURES WITHIN SPHERE
C
C FILL ARRAY BUFI

       COMMON /MAPIO/ INMAP,IOMAP,NHDRS,CCELL,NNSYM,NX,NY,NZ,
     *                AMN,AMX,AMEAN,ARMS,BUFI
       DIMENSION CCELL(6),BUFI(20000000)

       COMMON /CORRECT/ CORRF(50),RLASER(50)

       DIMENSION RHOO(1),RHOC(1)

C OPEN AND CLOSE MAP BEFORE CALLING SCALMAP
       WRITE(*,*)

        AMEAN=0.0
        SMSQ=0.0 
        DRMIN=0.0
        DRMAX=0.0
        SSN=0.0
        SS=0.0
        RRN=0.0 
        RR=0.0 
        DO 900 I=1,NM
         AMEAN=RHOO(I)+AMEAN
 900    CONTINUE
         AMEAN=AMEAN/NM
        DO 1200 I=1,NM
          SMSQ=SMSQ+(RHOO(I)-AMEAN)**2
1200    CONTINUE
          SM=SQRT(SMSQ/NM)

        
C SCALE POSITIVE AND NEGATIVE SEPARATELY
        DO 1400 I=1,NM
            IF (RHOO(I).LT.0.0) THEN
             SSN=SSN+RHOO(I)
             RRN=RRN+RHOC(I)
            ELSE
             SS=SS+RHOO(I)
             RR=RR+RHOC(I)
            ENDIF
 1400   CONTINUE
        SCALP=RR/SS
        SCALN=RRN/SSN

        DO 1700 I=1,NM
          IF (RHOO(I).LT.0.0) RHOO(I)=RHOO(I)*SCALN
          IF (RHOO(I).GT.0.0) RHOO(I)=RHOO(I)*SCALP
          IF (RHOO(I).GT.DRMAX) DRMAX=RHOO(I)
          IF (RHOO(I).LT.DRMIN) DRMIN=RHOO(I)
 1700   CONTINUE
C COPY SM INTO ARMS  
        ARMS=SM
        WRITE(*,*)
        WRITE(*,*) 'SYNTHETIC MAP HAS BEEN SCALED TO ORIGINAL MAP: '
        WRITE(*,1900) ITP,DRMIN,DRMAX,AMEAN,SM,SCALP,SCALN
1900    FORMAT(' MAP FOR TIME POINT           :  ',I10,/,
     *         ' MIN  VALUE                   :  ',F10.3,/,
     *         ' MAX  VALUE                   :  ',F10.3,/,
     *         ' MEAN VALUE                   :  ',F10.3,/,
     *         ' STANDARD DEVIATION FROM MEAN :  ',F10.4,/,
     *         ' SCALE FACTOR FOR POSITIVE    :  ',F10.6,/,
     *         ' SCALE FACTOR FOR NEGATIVE    :  ',F10.6)
        WRITE(*,*)

         RETURN
         END


      SUBROUTINE SETMAT(CELL)
C
       COMMON /MATRIX/  MAT11,MAT12,MAT13,MAT22,MAT23,MAT33,
     *            IMAT11,IMAT12,IMAT13,IMAT22,IMAT23,IMAT33
       REAL*4  MAT11,MAT12,MAT13,MAT22,MAT23,MAT33
       REAL*4  IMAT11,IMAT12,IMAT13,IMAT22,IMAT23,IMAT33
C
       COMMON /METRIC/ G11,G12,G13,G22,G23,G33
       DIMENSION CELL(6)


C VARIABLES
       DIMENSION CABG(3),SABG(3)


C SET UP ORTHOGONALIZATION MATRIX AND INVERSE
C D=PI/180
       D=0.017453
C SET UP MATRIX, INVERSE MATRIX, METRIC TENSOR
       DO 900 I=1,3
       CABG(I)=COS(CELL(I+3)*D)
       SABG(I)=SIN(CELL(I+3)*D)
       IF (CELL(I+3).EQ.90.0) THEN
          CABG(I)=0.
          SABG(I)=1.
       ENDIF
 900   CONTINUE
       CABGS = (CABG(2)*CABG(3)-CABG(1))/(SABG(2)*SABG(3))
       SABGS = SQRT(1.0-CABGS*CABGS)
       MAT11 = CELL(1)
       MAT12 = CELL(2)*CABG(3)
       MAT13 = CELL(3)*CABG(2)
       MAT22 = CELL(2)*SABG(3)
       MAT23 = -CELL(3)* SABG(2) *CABGS
       MAT33 =  CELL(3)* SABG(2)* SABGS
C SET UP INVERSE MATRIX
       IMAT11 = 1/MAT11
       IMAT12 = -MAT12/(MAT11*MAT22)
       IMAT13 = (MAT12*MAT23-MAT13*MAT22)/(MAT11*MAT22*MAT33)
       IMAT22 = 1/MAT22
       IMAT23 = - MAT23/(MAT22*MAT33)
       IMAT33 = 1/MAT33
C SET UP METRIC TENSOR
       G11=MAT11*MAT11
       G12=2*MAT11*MAT12
       G13=2*MAT11*MAT13
       G22=MAT12*MAT12 + MAT22*MAT22
       G23=2*MAT12*MAT13 + 2*MAT22*MAT23
       G33=MAT13*MAT13+MAT23*MAT23+MAT33*MAT33
       WRITE(*,*) ' ----------------------------------- '
       WRITE(*,*) 'ORTHOGONALIZATION MATRIX '
       WRITE(*,920) MAT11, MAT12, MAT13
       WRITE(*,920) 0.0, MAT22, MAT23
       WRITE(*,920) 0.0, 0.0, MAT33
 920   FORMAT(3F10.5)
       WRITE(*,*) 'INVERSE OF ORTHOGONALIZATION MATRIX '
       WRITE(*,920) IMAT11, IMAT12, IMAT13
       WRITE(*,920) 0.0, IMAT22, IMAT23
       WRITE(*,920) 0.0, 0.0, IMAT33
       WRITE(*,*) ' ----------------------------------- '
       RETURN
       END


      FUNCTION MATSYM(S,TEXT,ICOL)
C
C A FORTRAN FUNCTION SUBPROGRAM TO SCAN A SYMMETRY CARD AND BUILD
C THE CORRESPONDING SYMMETRY-OPERATION MATRIX.  THE CONTENTS OF THE
C CARD AND ERRORS ENCOUNTERED ARE WRITTEN OFF-LINE IN THE CALLING
C PROGRAM.  THE FUNCTIONAL VALUE IS NORMALLY ZERO, WHEN AN ERROR HAS
C BEEN DETECTED THE NUMBERS 1-4 ARE GIVEN BACK:
C ERROR-NUMBER 1:  INVALID CHARACTER AT POSITION ....
C              2:  SYNTAX ERROR AT NONBLANK POSITION ....
C              3:  BAD COMMAS
C              4:  DETERMINANT OF ROTATION MATRIX NOT +1 OR -1
C
C EXPLANATION OF ARGUMENTS
C S IS THE 1ST ELEMENT OF THE 3X4 ARRAY WHERE THE SYM. OP. IS TO BE
C STORED.
C TEXT  IS THE ARRAY OF THE TEXTRECORD WHICH IS TO BE SCANNED  (LENGTH:
C 36 CHARACTERS, CONTIGUOUSLY)
C ICOL POINTS - IN CASE OF ERRORS - TO THE POSITION OF AN INVALID
C CHARACTER OR AN SYNTAX ERROR WITHIN THE SYMMETRY CARD
C
C     MODIFIED FOR PDP-11 06/JAN/78 S.J. REMINGTON
C ***** LAST UPDATE 07/10/76   MRS                WRS:PR2.MATSYM
C ***** PREVIOUS UPDATES                              07/07/75  06/11/72
C
C
      DIMENSION S(3,4), NCHAR(36)
C      LOGICAL*1 TEXT(36),LHELP(4)
      CHARACTER*1 TEXT(36)
C CTEXT(36) unnoetig
      CHARACTER*1 BCHAR,VALID(14),BLANK
      EQUIVALENCE (BLANK,VALID(14))
C      EQUIVALENCE (IHELP,LHELP(1))
      SAVE
      DATA VALID/'1','2','3','4','5','6','X','Y','Z','-','+','/',',',
     * ' '/
C      DATA LHELP /4*Z'00'/
C     DATA VALID/ZF1,ZF2,ZF3,ZF4,ZF5,ZF6,ZE7,ZE8,ZE9,Z60,Z4E,Z61,Z6B,
C    * Z20/
C
C
C ==== unnoetig ==
C     KONVERSION LOGICAL IN CHARACTER
C
C      DO 1 I=1,36
C      LHELP(4)=TEXT(I)
C 1    CTEXT(I)=CHAR(IHELP)
C
C =====
C----INITIALIZE SIGNALS
      ICOL = 0
      IFIELD = 0
C----CLEAR SYMOP ARRAY
      DO 4 J=1,4
      DO 4 I=1,3
 4    S(I,J) = 0.0
C
C----TEST THE SYMMETRY TEXT (TEXT) FOR ILLEGAL CHARACTERS
C
C      THE STATEMENT IS SCANNED AND ARRAY NCHAR IS FILLED WITH THE INDICES
C      OF EACH ELEMENT OF TEXT INTO THE ARRAY 'VALID' (I.E. IF THE SEVENTH
C      CHAR OF 'TEXT' -IGNORING BLANKS- IS 'Y', NCHAR(7)=8)
C
      ICOLMX = 0
      DO 20 I=1,36
C MAR      BCHAR = CTEXT(I)
      BCHAR = TEXT(I)
      IF(BCHAR .EQ. BLANK) GO TO 20
      ICOLMX = ICOLMX + 1
      DO 10 J=1,13
      IF( VALID(J) .NE. BCHAR) GO TO 10
      NCHAR(ICOLMX) = J
      GO TO 20
   10 CONTINUE
C--IF GOT TO HERE, THE CHAR ISN'T IN 'VALID'
      JTXTSC = I
      GO TO 9975
   20 CONTINUE
C
C----BEGIN FIELD LOOP
C
 101  IFIELD = IFIELD + 1
      IF(IFIELD-3) 104,104,103
C  HAVE ALL CHARACTERS  BEEN ANALYSED IN 3 FIELDS?
 103  IF(ICOL-ICOLMX) 9987,1000,1000
C---NO MORE THAN THREE FIELDS PERMITTED
 104  SIGN = 1.0
      ICOL = ICOL+1
C----MARCH ON, FIND WHATS NEXT
      IFNUM=NCHAR(ICOL)
      IF (11-IFNUM) 9980,110,110
C----TEST FOR SIGNS
 110  IF (10-IFNUM) 118,115,112
C----TEST TO DISTINGUTSH BETWEEN NUMBERS AND LETTERS
 112  IF (6-IFNUM) 125,130,130
C----FOUND A SIGN
C     COME HERE FOR MINUS
 115  SIGN = -1.0
C     COME HERE FOR PLUS
 118  ICOL = ICOL + 1
C----NEXT CHARACTER MUST BE A NUMBER OR LETTER
      IFNUM=NCHAR(ICOL)
      IF (IFNUM-9) 122,122,9980
 122  IF (IFNUM-6) 130,130,125
C----A LETTER
 125  IFNUM = IFNUM - 6
      S(IFIELD,IFNUM) = SIGN
      GO TO 150
C----A NUMBER, FLOAT IT INTO DIGIT
 130  DIGIT = IFNUM
      ICOL = ICOL + 1
C----IS NEXT CHARACTER A SLASH
      IF(NCHAR(ICOL).EQ.12)  GO TO 135
C----NO SLASH, TRANSLATION TERM COMPLETE
      ICOL=ICOL-1
      GO TO  140
C----A SLASH IS NEXT, IS THERE A NUMBER AFTER IT
 135  ICOL = ICOL + 1
      IFNUM=NCHAR(ICOL)
      IF (IFNUM-6) 138,138,9980
C----MAKE FRACTION;   '5' NOT ALLOWED IN DENOMINATOR
  138 IF(IFNUM.EQ.5) GO TO 9980
      DIGIT = DIGIT/FLOAT(IFNUM)
C----ACCUMULATE THE VECTOR COMPONENT
 140  S(IFIELD,4) = S(IFIELD,4) + SIGN*DIGIT
C----TEST TO SEE IF THERE ARE MORE CHARACTERS IN THIS SUBFIELD
C    OR A NEW SUBFIELD
 150  ICOL = ICOL + 1
      SIGN = 1.0
C----TEST IF ALL DONE
      IF(ICOL - ICOLMX) 151,151,1000
 151  CONTINUE
C----A SUBFIELD BEGINS WITH A PLUS OR MINUS
      IF(NCHAR(ICOL).EQ.11)  GO TO 118
      IF(NCHAR(ICOL).EQ.10)  GO TO 115
C----A COMMA MUST BE NEXT UNLESS ICOL IS ICOLMX+1 WHICH MEANS THE END
      IF(NCHAR(ICOL).EQ.13)   GO TO 101
 163  IF (ICOLMX+1-ICOL) 9980,1000,9980
C----EVERYTHING SEEMS OK SEE IF DETERMINATE IS A NICE + OR - 1.
 1000 CONTINUE
      D=S(1,1)*S(2,2)*S(3,3)
     $ -S(1,2)*S(2,1)*S(3,3)
     $ -S(1,1)*S(2,3)*S(3,2)
     $ -S(1,3)*S(2,2)*S(3,1)
     $ +S(1,2)*S(2,3)*S(3,1)
     $ +S(1,3)*S(2,1)*S(3,2)
      IF(ABS(ABS(D) - 1.0) -.0001) 1001,9985,9985
 1001 CONTINUE
      IF(IFIELD - 3) 9987,1002,9987
 1002 CONTINUE
C----LEGAL RETURN
      MATSYM = 0
 2005 RETURN
C
C
C----ILLEGAL CHARACTER ON SYMMETRY CARD
 9975 MATSYM = 1
      ICOL = JTXTSC
      GO TO 2005
C
C----SYNTAX ERROR AT NONBLANK CHARACTER ICOL
 9980 MATSYM = 2
      GO TO 2005
C
C----DETERMINANT IS NOT + OR - 1.
 9985 MATSYM = 4
      GO TO 2005
C
C----INCORRECT NUMBER OF COMMAS
 9987 MATSYM = 3
      GO TO 2005
      END

