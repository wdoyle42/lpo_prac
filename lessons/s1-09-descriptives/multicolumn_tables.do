


// set link for data, plot, and table directories
global datadir "../data/"
global plotdir "../plots/"
global tabsdir "../tables/"

// set plot and table types
global gtype png
global ttype rtf

// theme for graphics
set scheme s1color

// open up modified plans data
use plans2, clear

				
// use svyset to account for survey design
svyset psu [pw = f1pnlwt], strat(strat_id) singleunit(scaled)


// get mean estimates using svy
svy: mean bynels2m bynels2r byses1 byses2 amind asian black hispanic white female

// Store it
estimates store my_mean_total


// get mean estimates using svy
svy: mean bynels2m bynels2r byses1 byses2 amind asian black hispanic white female ///
if bypared==2


// Store it
estimates store my_mean_hs


// get mean estimates using svy
svy: mean bynels2m bynels2r byses1 byses2 amind asian black hispanic white female ///
if bypared==6

// Store it
estimates store my_mean_college


// store the estimates in a nice table using esttab
esttab my_mean_* using means_se.$ttype, ///    // . means all in current memory
    not ///                              // do not include t-tests 
    replace ///                          // replace if it exists
    nostar ///                           // no significance tests 
    label ///                            // use variable labels 
    main(b) ///                          // main = means 
    aux(se) ///                          // aux = standard errors 
    nonotes ///                          // no standard table notes 
    nonumbers ///                        // no column/model numbers
	mtitles("Full Sample" "HS Educ Parents" "College Educ Parents") ///
    addnotes("Linearized estimates of standard errors in parentheses")
