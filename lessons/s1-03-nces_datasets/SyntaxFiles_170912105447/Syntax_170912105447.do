/************************************************************************
*** You may need to edit this code.                                  ***
***                                                                  ***
*** Please check all CD statements and USE statements before         ***
*** running this code.                                               ***
***                                                                  ***
*** You may have selected variables that contain missing data or     ***
*** valid skips. You may wish to recode one or both of these special ***
*** values. You need to consult the Variable Description to see if   ***
*** these special codes apply to your extracted variables. You can   ***
*** recode these special values to missing using the following       ***
*** sample code:                                                     ***
***                                                                  ***
*** replace {variable name} = . if {variable name} = {value};        ***
***                                                                  ***
*** Replace {variable name} above with the name of the variable you  ***
*** wish to recode. Replace {value} with the special value you wish  ***
*** to recode to missing.                                            ***
***                                                                  ***
*** It is important to retain full sample weights, replicate         ***
*** weights, and identification numbers as appropriate.              ***
************************************************************************/

/* Change delimiter to a semi-colon */
#delimit;

/* Change working directory */
cd "C:\EDAT\ELS\";

/* Increase memory size to allow for dataset */
set memory 300m;

/* Clear everything */
clear;

/* Open Stata dataset */
use "els_02_12_byf3pststu_v1_0";

/* Keep only selected variables */
keep
   BYS20B
   STU_ID
   SCH_ID
   STRAT_ID
   PSU
   F1SCH_ID
   F1UNIV1
   F1UNIV2A
   F1UNIV2B
   F2UNIV1
   F2UNIV_P
   F3UNIV
   F3UNIVG10
   F3UNIVG12
   G10COHRT
   G12COHRT
   BYSTUWT
   BYEXPWT
   F1QWT
   F1PNLWT
   F1EXPWT
   F1XPNLWT
   F1TRSCWT
   F2QTSCWT
   F2QWT
   F2F1WT
   F2BYWT
   F3QWT
   F3BYPNLWT
   F3F1PNLWT
   F3QTSCWT
   F3BYTSCWT
   F3F1TSCWT
   F3QTSCWT_O
   F3BYTSCWT_O
   F3F1TSCWT_O
   PSWT
   F3BYPNLPSWT
   F3BYTSCPSWT
   F3F1PNLPSWT
   F3F1TSCPSWT
   F3QPSWT
   F3QTSCPSWT
   PSTSCWT
   ;

/* Compress the data to save space */
compress;

/* Save dataset */
save "els_02_12_byf3pststu_v1_0_170912105447", replace;

/* Display frequencies for the categorical variables */
tabulate BYS20B;
/* Display descriptives for the continuous variables */
summarize
      STU_ID
      SCH_ID
      STRAT_ID
      F1SCH_ID
      ;

