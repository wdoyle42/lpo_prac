capture log close

log using "04-assignment_followup.log", replace

// Asignment 4 followup
// Complex data and merges
// AU: Will Doyle
// INIT: 2018-10-03
// REV: 2020-09-29

macro drop _all

global workdir `c(pwd)'

global ddir "../../data/"

//unzip and open spi data

cd $ddir
unzipfile ca1.zip
insheet using "CA1_1969_2016__ALL_AREAS.csv", clear
cd $workdir

exit 

keep if linecode==3

keep geofips geoname v37

rename v37 percapinc

save "${ddir}percapinc.dta", replace

// Unzip and open SASS data

cd $ddir
unzipfile "SASS_1999-00_TFS_2000-01_v1_0_CSV_Datasets.zip"

#delim ;

insheet using "SASS_99_00_S1A_v1_0.csv",   clear;

#delim cr

cd $workdir

keep  c_totpop c_curppe   state   stcnty   cntlnum dfnlwgt  

gen geofips=string(stcnty, "%05.0f")

save "${ddir}sass.dta", replace

// Many to one match merge on geofips
merge m:1 geofips using "${ddir}percapinc.dta"

destring percapinc, gen(percapinc_n) force

/*create a percap income at the state level and assign that value to all counties in that state*/
gen last_three_fips= substr(geofips,3,5)
gen state_bin = 1 if last_three_fips=="000"

gen state_percap_inc = percapinc_n if state_bin==1
bysort state: replace state_percap_inc=state_percap_inc[1]

graph twoway scatter c_curppe percapinc_n, msize(tiny) mcolor(black%20) name(county)


graph twoway scatter c_curppe state_percap_inc, msize(tiny) mcolor(black%20) name(state)


log close
exit
