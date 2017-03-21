

set more off

infile treat age education black hispanic married nodegree re75 re78 using "http://users.nber.org/~rdehejia/data/nsw_treated.txt",   clear

save treated, replace


local dataset nsw_control

infile treat age education black hispanic married nodegree re75 re78 using "http://users.nber.org/~rdehejia/data/nsw_control.txt",   clear

save "`dataset'", replace


/* *************************************************************************************** */
/* *This function inputs all datasets, drops 74 earnings and saves them in STATA format* */
/* *************************************************************************************** */

 #delim ; 
 local datasets  
 psid_controls 
 psid2_controls 
 psid3_controls 
 cps_controls 
 cps2_controls 
 cps3_controls; 

 #delim cr 


 foreach dataset of local datasets{ 
   infile treat age education black hispanic married nodegree re74 re75 re78 using "http://users.nber.org/~rdehejia/data/`dataset'.txt",   clear 

   drop re74 
  
 save "`dataset'", replace 

 } 

local dataset nsw_control


/*Initialize the matrix for table 3 */

local count  1,2,3,4,5,6,7,8

matrix table3mat= (`count' \ `count' \ `count' \ `count' \ `count' )

local i=1 /* This counts columns for us */

use treated, clear

append using "`dataset'"


/*Table 3 commands */

/* Column 1, treated */


  local k=1 /* Tracks rows */

foreach earn of varlist re75 re78{ /* Begin row loop */
  
tabstat `earn' if treat==1, stat(mean) save /* Average earnings */

mat mystat=r(StatTotal)
  
mat table3mat[`k',`i']  = mystat[1,1]

local k=`k'+1 /*Next row */  

tabstat `earn' if treat==1, stat(semean) save /* Now with standard error of the mean */

mat mystat=r(StatTotal)

mat table3mat[`k',`i']  = mystat[1,1]

local k=`k'+1 /*Next row */    

} /*End row loop */

tabstat re75 if treat==1, stat(n) save /* Count the number of obs*/

mat mystat=r(StatTotal)

mat table3mat[5,`i']=mystat[1,1]


local i=`i' +1 /* On to column 2 */

/*Columns 2-8 */

  #delim ;
local datasets
nsw_control
psid_controls
psid2_controls
psid3_controls
cps_controls
cps2_controls
cps3_controls;

#delim cr
  
foreach dataset of local datasets{

use treated, clear
append using "`dataset'"

  local k=1 /* Tracks rows */

foreach earn of varlist re75 re78{ /* Begin row loop */
  
tabstat `earn' if treat==0, stat(mean) save /* Average earnings */

mat mystat=r(StatTotal)
  
mat table3mat[`k',`i']  = mystat[1,1]

local k=`k'+1 /*Next row */  

tabstat `earn' if treat==0, stat(semean) save /* Now with standard error of the mean */

mat mystat=r(StatTotal)

mat table3mat[`k',`i']  = mystat[1,1]

local k=`k'+1 /*Next row */    

} /*End row loop */

tabstat re75 if treat==0, stat(n) save /* Count the number of obs*/

mat mystat=r(StatTotal)

mat table3mat[5,`i']=mystat[1,1]

local i = `i' +1 /*On to next column */
}

matrix rownames table3mat= "Earnings, 1975", "Earnings 1978", "N"

matrix colnames table3mat= "Treatment"  "Control"  "PSID"  "PSID2" "PSID3" "CPS" "CPS2" "CPS3"


estout matrix(table3mat , fmt( "%9.2f "(" %9.2f ")" "   )) using "table3.txt", replace 

mat2txt ,matrix(table3mat) format (%9.2f) saving("table3.csv") replace




/*Initialize 14 x9 the matrix for table 5 */
*  14x9

local count  1,2,3,4,5,6,7,8,9

#delim ;
matrix table5mat= (`count' \
                   `count' \
                   `count' \
                   `count' \
                   `count'  \
                   `count' \
                   `count' \
                   `count' \
                   `count' \
                   `count' \
                   `count' \
                   `count' \
                   `count' \
                   `count');

#delim cr

local i =1 /*This will be our column counter */


  
/*Table 5 commands */  
foreach dataset of local datasets{
  
use treated, clear
append using "`dataset'"

gen agesq=age*age

local controls age agesq educ nodegree black hispanic

/*Earnings Difference*, column 1*/

  gen earndiff= re78-re75

tabstat earndiff if treat==0, stat(mean) save

mat mystat=r(StatTotal)

mat table5mat[`i',1]=mystat[1,1]

tabstat earndiff if treat==0, stat(semean) save

mat mystat=r(StatTotal)

local j= `i'+1 /* Se needs to be one row down */

mat table5mat[`j',1]=mystat[1,1]

/* Column 2 */

reg re75 treat


mat  mybeta=e(b)

mat table5mat[`i',2]= mybeta[1,1]

mat myvar=e(V)


mat table5mat[`j',2]=sqrt(myvar[1,1])

/* Column 3 */

reg re75 treat `controls'


mat  mybeta=e(b)

mat table5mat[`i',3]= mybeta[1,1]

mat myvar=e(V)


mat table5mat[`j',3]=sqrt(myvar[1,1])

/* Column 4 */

reg re78 treat

mat  mybeta=e(b)

mat table5mat[`i',4]= mybeta[1,1]

mat myvar=e(V)


mat table5mat[`j',4]=sqrt(myvar[1,1])
/* Column 5 */

reg re78 treat `controls'


mat  mybeta=e(b)

mat table5mat[`i',5]= mybeta[1,1]

mat myvar=e(V)

local j=`i'+1
mat table5mat[`j',5]=sqrt(myvar[1,1])
/* Column 6 */

reg earndiff treat


mat  mybeta=e(b)

mat table5mat[`i',6]= mybeta[1,1]

mat myvar=e(V)


mat table5mat[`j',6]=sqrt(myvar[1,1])

/* Column 7 */

reg earndiff treat age agesq


mat  mybeta=e(b)

mat table5mat[`i',7]= mybeta[1,1]

mat myvar=e(V)


mat table5mat[`j',7]=sqrt(myvar[1,1])

/* Column 8 */

reg earndiff treat re75


mat  mybeta=e(b)

mat table5mat[`i',8]= mybeta[1,1]

mat myvar=e(V)


mat table5mat[`j',8]=sqrt(myvar[1,1])

/* Column 9 */

reg earndiff treat re75 `controls'


mat  mybeta=e(b)

mat table5mat[`i',9]= mybeta[1,1]

mat myvar=e(V)


mat table5mat[`j',9]=sqrt(myvar[1,1])


local i =`i'+2

  
} /*End dataset loop */

matrix rownames table5mat = "Control" "SE"  "PSID" "SE"  "PSID2" "SE" "PSID3" "SE" "CPS" "SE" "CPS2" "SE" "CPS3" "SE"

estout matrix(table5mat  , fmt( "%9.2f "(" %9.2f ")" "   )) using "table5.txt", replace 

mat2txt ,matrix(table5mat) format (%9.2f) saving("table5.csv") replace

exit


