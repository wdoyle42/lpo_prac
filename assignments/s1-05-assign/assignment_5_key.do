capture log close

log using "05-assignment_followup.log", replace

// Asignment 5 followup
// Complex data and merges
// AU: Will Doyle
// INIT: 2018-10-03

macro drop _all

global workdir `c(pwd)'

global ddir "../../data/"

//unzip and open spi data

cd $ddir
unzipfile ca1.zip
insheet using "CA1_1969_2016__ALL_AREAS.csv", clear
cd $workdir

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

keep  c_totpop   state   stcnty   cntlnum dfnlwgt

gen geofips=string(stcnty, "%05.0f")

save "${ddir}sass.dta", replace


// Many to one match merge on geofips
merge m:1 geofips using "${ddir}percapinc.dta"



log close
exit
