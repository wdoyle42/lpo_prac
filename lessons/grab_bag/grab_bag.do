// Grab Bag
// Au: Will Doyle
// Rev: 11/28/17


// Acad presentation



// Tables, tables tables


clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// set link for data, plot, and table directories
global datadir "../data/"
global plotdir "../plots/"
global tabsdir "../tables/"

// set plot and table types
global gtype eps
global ttype html

// theme for graphics
set scheme s1color

// open up modified plans data
use plans2, clear

exit 

// use svyset to account for survey design
svyset psu [pw = f1pnlwt], strat(strat_id) singleunit(scaled)

//  cross table of categorical
estpost svy: tabulate byrace2 newpln, row percent se

eststo racetab

esttab racetab using race_tab.$ttype, ///
    replace ///
    nostar ///
    nostar ///
    unstack ///
    nonotes ///
    varlabels(`e(labels)') ///
    eqlabels(`e(eqlabels)')




// Exporting graphics


// What's a codebook? I want one . . .



