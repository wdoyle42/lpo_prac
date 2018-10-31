capture log close                       // closes any logs, should they be open
set linesize 90
log using "descriptives.log", replace    // open new log

// NAME: Data cleaning
// FILE: lecture11_descriptives.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 6 November 2013
// LAST: 31 October 2018

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

// use svyset to account for survey design
svyset psu [pw = f1pnlwt], strat(strat_id) singleunit(scaled)

// DESCRIBE THE DEPENDENT VARIABLE

// histogram of base year math score
histogram bynels2m, name(hist_bynels2m)  ///
    xtitle("NELS-1992 Scale-Equated Math Score") ///    
    bin(25) /// we can try different bin widths
    percent
	
	
graph export hist_bynels2m.$gtype, name(hist_bynels2m) replace
    
// spikeplot of base year math score
spikeplot bynels2m, name(spike_bynels2m) ///
    xtitle("NELS-1992 Scale-Equated Math Score")
    
graph export spike_bynels2m.$gtype, name(spike_bynels2m) replace

// kernel density plot of base year math score
kdensity bynels2m, name(kd_bynels2m) ///
    xtitle("NELS Math Scores") ///
    n(100) ///
    bwidth(.025) ///
    normal /// 
	kernel(gaussian) ///
    normopts(lpattern(dash)) 
 	
graph export kd_bynels2m.$gtype, name(kd_bynels2m) replace

// kernel density plots of base year math score across gender
kdensity bynels2m if bysex == 1, name(kd_bynels2m_cond) ///
    xtitle("NELS Math Scores") ///
    n(100) ///
    bwidth(.025) ///
    addplot(kdensity bynels2m if bysex == 2, ///
            n(100) ///
            bwidth(.025) ///
            ) ///
    legend(label(1 "Males") label(2 "Females")) ///
    note("") ///
    title("")

graph export kd_bynels2m_cond.$gtype, name(kd_bynels2m_cond) replace


// BASIC DESCRIPTIVE TABLE

// get mean estimates using svy
svy: mean bynels2m bynels2r byses1 byses2 amind asian black hispanic white female

// Store it
estimates store my_mean

// store the estimates in a nice table using esttab
esttab my_mean using means_se.$ttype, ///    // . means all in current memory
    not ///                              // do not include t-tests 
    replace ///                          // replace if it exists
    nostar ///                           // no significance tests 
    label ///                            // use variable labels 
    main(b) ///                          // main = means 
    aux(se) ///                          // aux = standard errors 
    nonotes ///                          // no standard table notes 
    nonumbers ///                        // no column/model numbers
    addnotes("Linearized estimates of standard errors in parentheses")
	
//	("Balanced Repeated Replicate (BRR) estimates of standard errors in parenthesese)

// use tabstat to make table
tabstat bynels2m bynels2r byses1 byses2, stat(sd) save 

// grab matrix of sds and store in matrix
mat mysd = r(StatTotal)

// add to earlier results using estadd
estadd  matrix mysd: my_mean

// save new table, this time with sds instead of ses
esttab my_mean using means_sd.$ttype, ///
    not /// 
    replace ///
    nostar ///
    label ///
    main(b) ///
    aux(mysd) ///                        // NOTE: aux = standard deviations
    nonumbers ///
    nonotes ///
    addnotes("Standard deviations in parentheses")
 

// CATEGORICAL VARIABLE

// barchart of base year student expectations
histogram bystexp, name(bar_bystexp) ///
    percent ///
    addlabels ///
    xlabel(-1 1 2 3 4 5 6 7, ///
           value ///
           angle(45) ///
           labsize(vsmall) ///
           ) ///
    addlabopts(yvarformat(%4.1f)) ///
    xtitle("")

graph export bar_bystexp.$gtype, name(bar_bystexp) replace

// proportions table for base year student expectations 
estpost svy: tabulate bystexp

esttab . using proportions.$ttype, ///
    not /// 
    replace ///
    nostar ///
    label ///
    main(b) ///
    aux(se) ///
    nonotes ///
    nonumbers ///        
    addnotes("Linearized standard errors in parentheses")

// KEY DEPENDENT VARIABLE IN RELATION TO OTHER INDEPENDENT VARIABLES


// math against reading scores in scatterplot: please don't do this
graph twoway scatter bynels2m bynels2r, name(sc_math_read)
graph export sc_math_read.$gtype, name(sc_math_read) replace

//solutions

// scatterplot with 10 percent sample of data
preserve                                // preserve data
sample 10                               // sample random 10%

graph twoway scatter bynels2m bynels2r, name(sc_math_read_10) ///
  ytitle("NELS Math Scores") ///
  xtitle("NELS Reading Scores") ///
  msize(tiny)
graph export sc_math_read_10.$gtype, name(sc_math_read_10) replace

restore                                 // restore data

// conditional scatterplot with 25 percent sample of data
preserve                                // preserve data
sample 25                               // sample random 25%

graph twoway (scatter bynels2m byses1 if urm == 0, ///
                  mcolor(orange*.5) ///
                  msize(tiny) ///
              ) ///
              || scatter bynels2m byses1 if urm == 1, ///
                  mcolor(green*.5) ///
                  msize(tiny) ///
                  msymbol(triangle) ///
                  ytitle("NELS Math Scores") ///
                  xtitle("SES") ///
                  legend(order(1 "Non-Minority" 2 "Underrep Minority")) ///
                  name(sc_complex)

graph export sc_complex.$gtype, name(sc_complex) replace

restore                                 // restore data

// conditional scatterplot with by
graph twoway scatter bynels2m byses1, by(bystexp) ///
    msize(*.01) ///
    ytitle("NELS Math Scores") ///
    xtitle("SES") ///   
    note("") ///
    name(sc_cond) 

graph export sc_cond.$gtype, name(sc_cond) replace

// matrix plot:NO
graph matrix bynels2m bynels2r byses1 byses2, name(matrix_plot) msize(vtiny)
graph export matrix_plot.$gtype, name(matrix_plot) replace


// boxplot of math score over categories of race/ethnicity
graph box bynels2m, over(byrace2, ///
                         label(alternate ///
                               labsize(tiny) ///
                               ) ///
                         ) ///
                    name(box1)

graph export box1.$gtype, name(box1) replace

graph box bynels2m, over(byrace2, ///
                         label(alternate ///
                               labsize(tiny) ///
                               ) ///
                         sort(1) ///
                         ) ///
                    name(box2)

graph export box2.$gtype, name(box2) replace

// bar plots 

graph hbar bynels2m bynels2r [pw=bystuwt], ///
		over(bystexp, sort(bynels2m) descending) ///
		ytitle("Test Scores") ///
		legend(order(1 "Math Scores" 2 "Reading Scores"))  ///
		blabel(bar,format(%9.2f)) ///
		bar(1, color(orange*.5)) bar(2, color(blue*.5))

graph hbar bynels2m bynels2r [pw=bystuwt], ///
		over(bystexp, sort(bynels2m) descending) ///
		ytitle("Test Scores") ///
		legend(order(1 "Math Scores" 2 "Reading Scores"))  ///
		blabel(bar,format(%9.2f)) ///
		bar(1, color(orange*.5)) bar(2, color(blue*.5)) ///
		name(barplot1)

// Statplot: ssc install statplot
statplot bynels2m bynels2r, over(bystexp,sort(1) descending) over(bysex)  name(statplot)
		
		

// dot plots of continuous against categorical
graph dot bynels2m, over(bypared, ///
                         label(alternate ///
                               labsize(tiny) ///
                               ) ///
                         ) ///
                    ytick(0(.10).80) ///
                    ylabel(0(.1).8) ///
                    ytitle("Math Scores") ///
                    marker(1, msymbol(O)) ///
                    name(dot_math)

graph save dot_math.gph, replace

graph dot bynels2r, over(bypared, ///
                         label(alternate ///
                               labsize(tiny) ///
                               ) ///
                         ) ///
                    ytick(0(.10).80) ///
                    ylabel(0(.1).8) ///
                    ytitle("Reading Scores") ///
                    marker(1, msymbol(O)) ///
                    name(dot_read)

graph save dot_read.gph, replace

// combine graphs into one plot
graph combine dot_math.gph dot_read.gph, ///
    name(dot_both) ///
    colfirst

// export combined graphics
graph export dot_both.$gtype, name(dot_both) replace


// TABPLOT

// first new recoded parental education level
recode bypared (1/2 = 1) (3/5 = 2) (6 = 3) (7/8 = 4) (. = .), gen(newpared)
label var newpared "Parental Education"
label define newpared 1 "HS or Less" 2 "Less than 4yr" 3 "4 yr" 4 "Advanced"
label values newpared newpared

// next new recoded student expectations
recode f1psepln (1/2 = 1) (3/4 = 2) (5 = 3) (6 = .) (. = .), gen(newpln)
label var newpln "PS Plans"
label define newpln 1 "No plans" 2 "VoTech/CC" 3 "4 yr"
label values newpln newpln

// tabplot of parental education against student plans
tabplot newpared newpln, name(tabplot1) ///
    percent(newpared) ///
    showval ///
    subtitle("") 

graph export tabplot1.$gtype, name(tabplot1) replace

// tabplot again, but with new dimension
tabplot newpared newpln, by(bysex) ///
    percent(newpared) ///
    showval ///
    subtitle("") ///
    name(tabplot2)

graph export tabplot2.$gtype, name(tabplot2) replace

// jitter categorical against categorical
graph twoway scatter f1psepln bypared, name(jitterplot) ///
    jitter(5) ///
    msize(vtiny)

graph export jitterplot.$gtype, name(jitterplot) replace

// heatmap of base year student plans and parental education
tddens bypared f1psepln, title("") ///
    xtitle("Parent's Level of Education") ///
    ytitle("PS PLans")
    
graph export heatmap.$gtype, replace

// table using weights directly
table byrace2 f1psepln [pw = bystuwt], by(bysex) contents(freq) row 

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

// end file     
log close
exit
