version 12 /* Can set version here, use the most recent as default */
capture log close /* Closes any logs, should they be open */

log using "sampling_part1.log",replace /*Open up new log */

/* Sampling */
/* Working with sampling designs */
/* Will Doyle */
/* 141001 */
/* Practicum Folder */

clear

clear mata /* Clears any fluff that might be in mata */

estimates clear /* Clears any estimates hanging around */

/*set memory 800m  Set memory size, default is only good for small datasets */

set more off /*Get rid of annoying "more" feature */ 

set scheme s1mono /* My  preferred graphics scheme */

graph set print logo off /*No Stata logo on graphics */

/* Following : http://www.ats.ucla.edu/stat/Stata/seminars/svy_stata_8/Stata_svy_seminar_sampling.htm */   	 	 	 	 	

local input=0

if `input'==1{
use http://www.ats.ucla.edu/stat/stata/seminars/svy_stata_intro/apipop, clear
save apipop, replace
}

else{
  use apipop
}

count

mean api99

matrix bpop=e(b)
matrix vpop=e(V)

scalar api99_pop_mean=bpop[1,1]

scalar api99_pop_var=vpop[1,1]

scalar pop_size=_N

set seed 091006
sample 5
count

/*Create Pweights*/

scalar simple_sample_size=_N

gen pw = pop_size/simple_sample_size


/*Because we are sampling a rather large percentage of our population, we need to set the fpc.  Stata will calculate the actual fpc for us; we just need to specify the population total.*/

gen fpc = 6194

recode awards (1=0) (2=1)

/*Using svydes */

svyset [pweight=pw], fpc(fpc)

svydes 

svy: mean api99

mat bsimple=e(b)

mat vsimple=e(V)

scalar api99_simple_mean=bsimple[1,1]

scalar api99_simple_var=vsimple[1,1]

scalar api99_simple_se=sqrt(api99_simple_var)

mean api99

/*Simple random samples are self-weighting */

/*Frequency Weighting */

use http://www.ats.ucla.edu/stat/data/hsb2_fw, clear

sum read

sum read [fw=fw]

tab schtyp

prop schtyp [fw=fw]


/*Stratified random sampling in Stata*/

use apipop, clear
 
encode cname, gen(county_strat)

sort county_strat

by county_strat: count

collapse (count) county_total=snum, by(county_strat) /*Gives me a dataset with total number of schools in each county, id=county_strat */

save county_totals, replace

set seed  091006

use apipop, clear

encode cname, gen(county_strat)

sort county_strat

by county_strat: sample 10 /*10% of schools in each county */

sort county_strat

by county_strat: count

merge m:1 county_strat using county_totals /*Bring back in pop totals */

egen sample_total=count(snum), by(county_strat) /*Sample totals */

gen pw=county_total/sample_total /*Inverse of probability of selection */ 



/*Set FPC by strata */

gen fpc = county_total

svyset, clear
svyset [pweight = pw], strata(county_strat) fpc(fpc) singleunit(scaled)
svydes


svy: mean api99


mat bstrat=e(b)

mat vstrat=e(V)

scalar api99_strat_mean=bstrat[1,1]

scalar api99_strat_var=vstrat[1,1]

scalar api99_strat_se=sqrt(api99_strat_var)

mean api99


/*stratify the sample on school type (100 of each)  and report results */

use apipop, clear
 
gen stype_strat=stype

sort stype_strat

by stype_strat: count

collapse (count) stype_total=snum, by(stype_strat) /*Gives me a dataset with total number of schools in each county, id=county_strat */

save stype_totals, replace

set seed  091006

use apipop, clear

gen stype_strat=stype

sort stype_strat

by stype_strat: sample 100,count /*100  schools in each county */

sort stype_strat

by stype_strat: count

merge m:1 stype_strat using stype_totals /*Bring back in pop totals */

egen sample_total=count(snum), by(stype_strat) /*Sample totals */

gen pw=stype_total/sample_total /*Inverse of probability of selection */ 


gen fpc = stype_total

svyset, clear
svyset [pweight = pw], strata(stype_strat) fpc(fpc) singleunit(scaled)
svydes

svy: mean api99

mat bstrat=e(b)

mat vstrat=e(V)

scalar api99_strat_mean=bstrat[1,1]

scalar api99_strat_var=vstrat[1,1]

scalar api99_strat_se=sqrt(api99_strat_var)

mean api99


/*Systematic sampling*/


set seed 37
di int(uniform()*13)+1

use apipop, clear

sort snum
drop if _n < 4 /* drop first three schools */
gen newsno = _n - 1 
gen y = mod(newsno,13) /* Count by thirteens */
drop if y != 0
count

di 6194/13

/*Generate Pweights*/

gen pw = 6194/477
gen fpc = 6194

svyset [pweight = pw], fpc(fpc)

svydes

svy: mean api99

mat bsystem=e(b)

mat vsystem=e(V)

scalar api99_system_mean=bsystem[1,1]

scalar api99_system_var=vsystem[1,1]

scalar api99_system_se=sqrt(api99_system_var)

mean api99

/*Systematically sample every 20th school */

/*One-stage cluster sampling*/


use apipop, clear


contract dnum
count

scalar total_districts=_N

set seed 1002
sample 25
count

sort dnum
keep dnum
save "district_id.dta", replace

scalar sample_districts=_N


use apipop, clear
sort dnum
merge dnum using "district_id.dta"
drop if _merge != 3
count

gen pw = (total_districts/sample_districts)
gen fpc = total_districts

svyset, clear
svyset [pweight = pw], fpc(fpc) psu(dnum)
svydes

svy:mean api99

mat bcluster=e(b)

mat vcluster=e(V)

scalar api99_cluster_mean=bcluster[1,1]

scalar api99_cluster_var=vcluster[1,1]

scalar api99_cluster_se=sqrt(api99_cluster_var)

mean api99


/*Two stage cluster sampling: county then school */

use apipop, clear

contract cnum
count

scalar total_counties=_N

set seed 1002
sample 10, count
count

sort cnum
keep cnum
save "county_id.dta", replace

scalar sample_counties=_N

use apipop, clear
sort cnum
merge cnum using "county_id.dta"
drop if _merge != 3
count

sort cnum 

by cnum: sample 10


gen pw = 1/((sample_counties/total_counties)*.1)
gen fpc = total_counties

svyset, clear
svyset [pweight = pw], fpc(fpc) psu(cnum)
svydes

svy:mean api99

mat bcluster=e(b)

mat vcluster=e(V)

scalar api99_cluster_mean=bcluster[1,1]

scalar api99_cluster_var=vcluster[1,1]

scalar api99_cluster_se=sqrt(api99_cluster_var)

mean api99


exit


/*Two-stage cluster sampling with stratification*/


* determining the cutpoint between the 2 strata
use apipop, clear 
egen mean = mean(api99), by(dnum)
contract dnum mean
sum mean
* 650
histogram mean, xline(650) normal xlabel(350(50)950) freq




* creating the data file for strata 1
use apipop, clear
egen mean = mean(api99), by(dnum)
gen strata = 1
replace strata = 2 if mean > 650
drop if strata == 2
save apipops1.dta, replace

* creating the data file for strata 2
use apipop, clear 
egen mean = mean(api99), by(dnum)
gen strata = 1
replace strata = 2 if mean > 650
drop if strata == 1
save apipops2.dta, replace



/*Stratum 1 */

* working in strata 1
use apipops1.dta, clear
count
* 3644 cases
codebook dnum
* 377 clusters
sort dnum
by dnum: gen n = _n
summ n
* 1 to 552

contract dnum
count
* 377
sample 25
count
* 94 school districts
sort dnum
save oscss1.dta, replace
use apipops1.dta, clear
sort dnum


merge m:1 dnum using oscss1.dta
drop if _merge != 3
count
* 837 schools 
sort dnum
by dnum: gen n = _n
summ n
* 1 to 100


by dnum: gen xx = uniform()
sort dnum xx
by dnum: gen number = _n
by dnum: gen N = _N
drop if number > 3
count
* 227 schools sampled
sort dnum number
by dnum: gen nn = _N

gen p1 = 377/94 /* inv. Prob that your school districut was selected */
gen p2 = N/nn /*inv. Probability that your school was selected from within the sampled district*/
gen pwt = p1*p2
gen fpc = 377
save strata1.dta, replace

/*Stratum 2 */

* working in strata 2
use apipops2.dta, clear
count
* 2550 cases
codebook dnum
* 380 clusters
sort dnum
by dnum: gen n = _n
summ n
* 1 to 142

* selecting clusters
contract dnum
count
*380
sample 25
count
*95 school districts
sort dnum
save oscss2.dta, replace
use apipops2.dta, clear
sort dnum
merge m:1 dnum using oscss2.dta
drop if _merge != 3
count
* 669 schools 
sort dnum
by dnum: gen n = _n
summ n
* 1 to 72

* selecting schools within districts
by dnum: gen xx = uniform()
sort dnum xx
by dnum: gen number = _n
by dnum: gen N = _N
drop if number > 3
count
* 239 schools sampled
sort dnum number
by dnum: gen nn = _N
* creating the pweights and fpc
gen p1 = 380/95
gen p2 = N/nn
gen pwt = p1*p2
gen fpc = 380
save strata2.dta, replace

/*Put data back together */

append using strata1.dta
count
* 466
gen comp_imp1 = comp_imp - 1
recode awards (1 = 0) ( 2= 1)
gen meals3 = 2
replace meals3 = 1 if meals <= 33
replace meals3 = 3 if meals > 67
save strataboth.dta, replace


svyset [pweight = pwt], fpc(fpc) psu(dnum) strata(strata)

svydes

svy:mean api99

mat bcomplex=e(b)

mat vcomplex=e(V)

scalar api99_complex_mean=bcomplex[1,1]

scalar api99_complex_var=vcomplex[1,1]

scalar list

mean api99

log close

exit

