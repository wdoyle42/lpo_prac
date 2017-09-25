capture log close                       // closes any logs, should they be open
log using "more_dataset_manipulation.log", replace    // open new log

// NAME: More dataset manipulation
// FILE: lecture5_more_dataset_manipulation.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 17 September 2014
// LAST: 25 September 2017

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// set globals for url data link and local data path
global urldata "https://stats.idre.ucla.edu/stat/stata/seminars/svy_stata_intro/apipop"


// required Ado Files: onewayplot, mdesc, mvpatterns
ssc install mdesc
ssc install onewayplot
net install dm91, from ("http://www.stata.com/stb/stb61")
   
   
    use $urldata, clear
	
	save api, replace
	
// create example datasets
preserve
collapse (mean) api99, by(cnum)
drawnorm county_inc, means(30) sds(5)
sort cnum
save county_data, replace
restore

preserve
collapse (mean) api99, by(dnum)
rename api99 api99c
gen edd = rbinomial(1,.3)
save district_data, replace
restore

// many-to-one match merging 

// sort to aid in merge
sort cnum

// merge many-to-one
merge m:1 cnum using county_data

// inspect many-to-one merge
tab _merge
list cnum api99 county_inc if _n < 10

// plot and save
onewayplot api99, by(county_inc) stack ms(oh) msize(*.1) width(1) name(api99_ow)
graph export ${plotdir}api99_ow.eps, name(api99_ow) replace

// one-to-many match merging: but why?

use api, clear

// sort to aid in merge
sort dnum

// save newly sorted dataset
save api, replace

// load example data
use district_data, clear

// sort to aid in merge
sort dnum

// merge one-to-many
merge 1:m dnum using api

// inspect one-to-many merge
tab _merge
list dnum api99 edd if _n < 10

// messy merge

use api, clear

preserve
drop api00 ell mobility
sample 90
save api_99, replace
restore

drop api99
sample 90
save api_00, replace

// merge datasets
merge snum using api_99, sort

// inspect messy merge
tab _merge

// code for looking at missing values, other patterns

// command: inspect
inspect api99
inspect api00

// command: mdesc
mdesc api99 api00 

// command: mvpatterns
mvpatterns api99 api00 ell mobility

// create flag if missing ell
gen ell_flag = ell == .

// plot kernel density of api99 of observations missing ell
kdensity api99 if ell_flag == 1, ///
    name(api99_kdens) ///
    addplot(kdensity api99 if ell_flag == 0) ///
    legend(label(1 "Not Missing ELL")  label(2 "Missing ELL")) ///
    note("") ///
    title("")

graph export api99_kdens.eps, name(api99_kdens) replace

// reshaping: wide to long

// read in data and sort
insheet using income.csv, comma clear
sort fips

// reshape long
reshape long inc_, i(fips) j(year_quarter, string)

// create date that stata understands
gen date = quarterly(year_quarter, "YQ")

// format date so we understand it
format date %tq

// list few rows
list if _n < 10

// organize data so we can graph it with xtline
xtset fips date, quarterly

// drop non-states
drop if fips < 1 | fips > 56

// graph
xtline inc_, i(areaname) t(date) name(xtline_fipsinc)
graph export ${plotdir}xtline_fipsinc.eps, name(xtline_fipsinc) replace

// reshaping: long to wide

// drop date that we added (no longer needed)
drop date

// long to wide
reshape wide inc_, i(fips) j(year_quarter, string)

// list first rows
list if _n < 4

// end file
log close                               // close log
exit                                    // exit script
