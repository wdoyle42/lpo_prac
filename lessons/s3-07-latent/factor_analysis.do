version 15 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */
log using "factor.log",replace /*Open up new log */

/* Factor Analysis */
/* Factor analysis and postsestimation via various techniques*/
/* Will Doyle */
/* 180509 */
/* Practicum Folder */  

clear

clear mata /* Clears any fluff that might be in mata */

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */

/* Load in public opininon data */

use hed, clear

renvars *, lower

/* Q35-42, students */
/* 35 How important is the following in terms of what students should get: a sense of maturity */

/* 36 Citizenship */

/* 37 Specific expertise in career */

/* 38  An ability to get along with different people */

/* 39  Top notch writing and speaking */

/* 40 Problem solving */

/* 41 Exposure to great writers and thinkers */

/* 42 High tech skills */



/* Q 44-54 Admins */


/* 44 Diverse students */

/* 45 Control costs */

/* 46 Control behavior of students */

/* 47 Lower dropouts */

/* 48 Ensure students work hard */

/* 49 Attract best professors */

/* 50 Keep tuition down */

/* 51 Find ways to help K-12 */

/* 52 Provide career counseling */

/* 53 Support extra currricular activities */

/* 54 Provide extra help for students who fall behind */


    

/* Recoding */


  
foreach myvar of varlist q35-q42{
  replace `myvar'=. if `myvar'>3
}


foreach myvar of varlist q44-q57{
  replace `myvar'=. if `myvar'>4
         }


tab qs2, gen(race_)

rename race_1 hispanic

rename race_2 white

rename race_3 black

rename race_4 asian

rename race_5 other

rename race_6 native_am



tab q116, gen(inc_)

rename inc_1 inc_lt15
rename inc_2 inc_1525
rename inc_3 inc_2535
rename inc_4 inc_3550
rename inc_5 inc_5075
rename inc_6 inc75p


tab q103, gen(educ_)

rename educ_1 lths
rename educ_2 hs
rename educ_3 trade
rename educ_4 somecoll
rename educ_5 aa
rename educ_6 college
rename educ_7 grad

tab sex, gen(sex_)

rename sex_1 male
rename sex_2 female

tab q112, gen(party_)

rename party_2 democrat

local students q35-q42

local admins q44-q54


/*Correlations */

corr `students'

corr `admins'

/* Scales */

alpha `students' , item gen(student_scale)

alpha `admins', item gen(admin_scale)


/*Factor analysis*/

/*Iterated principal factors*/

factor `students', ipf factor(3)

eststo student_ipf

rotate, orthogonal

rotate, promax(3)

factor `admins', ipf factor(3)

eststo admin_ipf

rotate, orthogonal

rotate, promax(3)

/*Principal components */

factor `students', pcf factor(3)

eststo student_pcf

rotate, orthogonal

rotate, promax(3)

factor `admins', pcf factor(3)

eststo admin_pcf

rotate, orthogonal

rotate, promax(3)

/*Via maximum likelihood */  

  factor `students', ml factor(3)

eststo student_ml

  factor `admins', ml factor(3)

eststo admin_ml

/*Cluster Analysis */

cluster kmeans `students', k(2)


tab _clus_1 college

graph hbar college female democrat , over(_clus_1) asyvars

cluster kmeans `admins', k(2)

tab _clus_2 college

graph hbar college female democrat , over(_clus_2) asyvars

exit 

/*Postestimation*/


estimates restore student_ml

estat structure

estimates restore admin_ml

estat structure

 /*Graphics*/  

estimates restore student_ml

loadingplot

loadingplot, factors(3)

estimates restore admin_ml

loadingplot

loadingplot, factors(3)

/*Generate New Variables */

estimates restore student_ml

predict studt_*, bartlett

estimates restore admin_ml

predict admin_*, bartlett

corr studt_1 studt_2 studt_3 college white black hispanic democrat male

corr admin_1-admin_3 college white black hispanic democrat male

/*Using factors */

reg  studt_1  college female democrat whitedum blackdum hispdum

reg  studt_2  college female democrat whitedum blackdum hispdum

reg  studt_3  college female democrat whitedum blackdum hispdum

