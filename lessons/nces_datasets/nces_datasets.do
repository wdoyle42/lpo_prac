capture log close                       // closes any logs, should they be open
log using "nces_datasets.log", replace    // open new log

// NAME: Working with NCES datasets
// FILE: nces_datasets.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 3 September 2014
// LAST: 12 Sep 2016

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// set globals for entire file
global workdir `c(pwd)'
global datadir "../../data/"
global auxdir "../../aux/"

// display globals
di "$workdir"
di "$datadir"

// Educational Longitudinal Study (ELS)

// set globals for ELS files
global els_zip "ELS_2002-12_PETS_v1_0_Student_Stata_Datasets.zip"
global els_dta "els_02_12_byf3pststu_v1_0.dta"
global elssave "els_reduced.dta"

// unzip ELS file
cd $datadir
unzipfile $els_zip, replace
cd $workdir

// change delimiter to a semi-colon -1-
#delimit ;

// keep only selected variables in ELS
use 
   STU_ID
   SCH_ID
   STRAT_ID
   PSU
   F1SCH_ID
   F1UNIV1
   F1UNIV2A
   F1UNIV2B
   F2UNIV_P
   BYSTUWT
   F1QWT
   F1PNLWT
   F1TRSCWT
   F2QTSCWT
   F2QWT
   F2F1WT
   F2BYWT
using $datadir$els_dta;

// change delimiter back to carriage return
#delimit cr

// lower all variable names using wildcard
renvars *, lower

// save reduced ELS dataset
save $datadir$elssave, replace

// Early Childhood Longitudinal Study - Kindergarten (ECLS-K)

cd $workdir

// set globals for ECLS-K files
global ecl_zip "ECLSK_1998-99_v1_0_Stata_Datasets.zip"
global ecl_dat "ECLSK_98_99_K8_CHILD_v1_0.dat"
global ecl_dct "nces_datasets_ecls.dct"
global eclsave "eclsk_reduced.dta"
    
// unzip ECLS file
cd $datadir
unzipfile $ecl_zip, replace
cd $workdir

// read in ECLS file
infile using $datadir$ecl_dct, using($datadir$ecl_dat) clear

// lower all variable names using wildcard
renvars *, lower

// save reduced ECLS-K dataset
save $datadir$eclsave, replace

// download dictionary file that we will need
capture log close

exit

// High School Longitudinal Study (HSLS)

// set globals for HSLS files
global hsls_zip "HSLS_2009_v2_0_Stata_Datasets.zip"
global hsls_dta "hsls_09_student_v2_0"
global hslssave "hsls_reduced.dta"

// unzip HSLS file
cd $datadir
unzipfile $datadir$hsls_zip, replace
cd $workdir

// change delimiter to a semi-colon -2-
#delimit ;

// keep only selected variables in HSLS
use 
   stu_id
   sch_id
   x1ncesid
   w1student
   w1parent
   w1mathtch
   w1scitch
   s1avid 
using $datadir$hsls_dta;

// change delimiter back to carriage return
#delimit cr

// lower all variable names using wildcard
renvars *, lower

// save reduced HSLS dataset
save $datadir$hslssave, replace


exit

// Programme for International Student Assessment (PISA)

// set globals for PISA files (note new baseurl)
global pisa_zip "INT_COG12_DEC03.zip"
global pisa_txt "INT_COG12_DEC03.txt"
global pisasave "pisa_reduced.dta"

// unzip PISA file
cd $datadir
unzipfile $datadir$pisa_zip, replace
cd $workdir

// store variables (and type if string) along with column
local vars str cnt 1-3 subnatio 4-10 stuid 32-36 ps527q03r 382-384

// read in variables
infix `vars' using $datadir$pisa_txt, clear

// save reduced PISA dataset
save $datadir$pisasave, replace

// end file
log close                               // close log
exit                                    // exit script
