capture log close

version 15 /* Can set version here, use version 13 as default */
capture log close /* Closes any logs, should they be open */

log using "report.log",replace /*Open up new log */ 

/* Literate Programming in Stata */ 
/* Provides a brief look at putdocx */
/* Will Doyle */
/* 8/29/18*/
/* Saved under in-class work */

clear

clear mata /* Clears any fluff that might be in mata */

estimates clear /* Clears any estimates hanging around */

set more off /*Get rid of annoying "more" feature */ 

set scheme s1mono /* My  preferred graphics scheme */

use census     /*filename of dataset */

putdocx clear // Close any existing documents
 
putdocx begin // Open new doc

putdocx paragraph // Start paragraph

putdocx text ("Literate Programming in Stata"),  bold

putdocx paragraph

putdocx text ("This is an example of literate programming. It includes both text and the output in the same file. As results are updated, there is no need to generate additional files.")

use census, clear

gen popurban_pc=popurban/pop*100

putdocx paragraph

// Create Table of Urbanicity by Region

putdocx text ("Urbanicity by Region"), bold

statsby Total=r(N) Average=r(mean) Max=r(max) Min=r(min), by(region) clear: summarize popurban_pc
rename region Region
putdocx table tbl1 = data("Region Total Average Max Min"), varnames ///
        border(start, nil) border(insideV, nil) border(end, nil)

putdocx save 01-report.docx, replace

log close
