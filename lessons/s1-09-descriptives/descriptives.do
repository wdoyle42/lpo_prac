/***
Descriptives
================
LPO 9951 | Fall 2021

#### PURPOSE

Describing the data in your sample is one of the most important steps in reporting on your research. A reader that has a clear understanding of the patterns in your data will be able to readily understand your more complex analyses.

The key to descriptive statistics turns out to be the humble conditional mean: the mean of the dependent variable at various levels of the independent variable. Master the conditional mean and how to display it, and everyone will always remember your papers and presentations.

<br>

***/


capture log close                       // closes any logs, should they be open
set linesize 90
log using "descriptives.log", replace    // open new log

// NAME: Data cleaning
// FILE: lecture11_descriptives.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 6 November 2013
// LAST: 3 November 2021

clear all                               // clear memory
graph drop _all

/***
#### HEADER

Incidental to the lesson today, but important to set up correctly is the header. Notice that the plot and table files types are saved in global macros. With a quick switch at the top of the file, you can change the file format of the plots and tables that Stata saves. Very handy.
***/


// You'll need betterbar, tabplot

//ssc install betterbar
//ssc install tabplot

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

// recode

recode bypared  (1=1 "Less than HS") ///
				(2=2 "HS") ///
				(3/5=3 "Some College or Associate") ///
				(6=4 "BA") ///
				(6/8=5 "Adv Degree") , gen(bypared2)
				
la var bypared2 "Parental Education"

// next new recoded student expectations
recode f1psepln (1/2 = 1 "No plans") /// 
				(3/4 = 2 "VoTech/CC") ///
				(5 = 3 "4 yr") ///
				(6 = .) ///
				(. = .), gen(newpln)
				
label var newpln "PS Plans"


				
// use svyset to account for survey design
svyset psu [pw = f1pnlwt], strat(strat_id) singleunit(scaled)

/***

Tables
------

Every manuscript should include a table of descriptive statistics, listing the mean and standard error or standard deviation of every variable to be used in the dataset. In addition, tables should be used to convey crosstabs of two categorical variables. Most of your papers will also eventually include tables for regression results. Tables should be used sparingly for describing data: your best bet is almost always graphics.

For many categorical variables, however, tables may be your only option. In that case you need to think hard about two things:

1.  How can I best show patterns in the conditional mean of my dependent variable at different levels of my independent variables?
2.  How can I best show relationships among key independent variables?


Principles for displaying data
------------------------------

Tufte (2001) lists the following principles for describing data using graphics. He says they should:

-   Show the data
-   Induce the viewer to think about the substance rather than about the methodology, graphic design, the technology production, or something else.
-   Avoid distorting what the data have to say.
-   Present many numbers in a small space.
-   Make large datasets coherent.
-   Encourage the eye to compare different pieces of data.
-   Reveal the data at several levels of detail, from a broad overview to fine structure.
-   Serve a reasonably clear purpose: description, exploration, tabulation, or decoration.
-   Be closely integrated with the statistical and verbal descriptions of a dataset.

Describing variation and central tendency in continuous variables
-----------------------------------------------------------------

### Plots

The two key tools for describing variation and central tendency in a continuous variable are the kernel density plot and the histogram. A histogram should be your first choice for most variables: the key decisions will be the number of bins or the frequency of the plot. Histograms can also be combined across levels using the onewayplot command.

The basic histogram is shown here.

***/


// DESCRIBE THE DEPENDENT VARIABLE

// histogram of base year math score
histogram bynels2m, name(hist_bynels2m, replace)  ///
    xtitle("NELS-1992 Scale-Equated Math Score") ///    
    bin(25) /// we can try different bin widths
    percent
		
graph export hist_bynels2m.$gtype, name(hist_bynels2m) replace



/***

At the extreme end of the histogram is the "spike" plot, which has a single line for every level of the underlying variable.

***/

// spikeplot of base year math score
spikeplot bynels2m, name(spike_bynels2m,replace) ///
    xtitle("NELS-1992 Scale-Equated Math Score") ///
	color(blue*.5%25) // First is intensity (*), second is opacity (%)
    
graph export spike_bynels2m.$gtype, name(spike_bynels2m) replace


/***

Kernel density plots are a key tool for describing a continuous variable. The density of the variable can be compared to standard densities for visual comparison, like in the first plot below. Kernel density plots can be particularly illuminating when displayed across multiple levels of a categorical variable, as in the second plot below.

***/

// kernel density plot of base year math score
kdensity bynels2m, name(kd_bynels2m, replace) ///
    xtitle("NELS Math Scores") ///
    n(100) ///
    bwidth(.025) ///
	color("98 47 117*.7%30") ///
	recast(area) ///
    normal /// 
	kernel(gaussian) ///
    normopts(lpattern(dash) color(black)) 

graph export kd_bynels2m.$gtype, name(kd_bynels2m) replace



// kernel density plot of base year reading  score
kdensity bynels2r, name(kd_bynels2r, replace) ///
    xtitle("NELS Reading Scores") ///
    n(100) ///
    bwidth(.025) ///
	color(bluishgray%75) ///
	recast(area) ///
	kernel(triangle) ///
	note("")

graph export kd_bynels2r.$gtype, name(kd_bynels2r) replace


// kernel density plots of base year math score across parental education
kdensity bynels2m if bypared == 2, name(kd_bynels2m_cond, replace) ///
    xtitle("NELS Math Scores") ///
    n(100) ///
    bwidth(.025) ///
	recast(area) ///
	color("216 171 76* .5%50") /// 
    addplot(kdensity bynels2m if bypared > 5, ///
            n(100) ///
            bwidth(.025) ///
            color("98 47 117*.7%50") ///
			recast(area)) ///
    legend(label(1 "Parent Ed=HS") label(2 "Parent Ed=BA+")) ///
    note("") ///
    title("")

graph export kd_bynels2m_cond.$gtype, name(kd_bynels2m_cond) replace


// CATEGORICAL DEPENDENT VARIABLE

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

// Similar, but using graph bar
graph bar ,over(bystexp, ///
			    sort(1) ///
				descending ///
				label(angle(45) labsize(small) ) ///
				) ///
	blabel(bar,format(%4.1f)) ///
	bar(1, color(blue*.5)) ///
	ytitle("")
	
	

// using hbar instead
graph hbar ,over(bystexp, ///
			    sort(1) ///
				descending ///
				label(labsize(small) ) ///
				) ///
	blabel(bar,format(%4.1f)) ///
	bar(1, color(blue*.5)) ///
	ytitle("")	
	
	
graph export bar_bystexp.$gtype, name(bar_bystexp) replace


/***

Pie Charts
----------

No. 

***/


// BASIC DESCRIPTIVE TABLE


/***
### Tables
For tables describing continuous variables, the industry standard is a table of means and standard errors or standard deviations. Below is a table of means and standard errors, nicely formatted.
***/

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

// use tabstat to make standard deviations for table
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

/***


You can condition on another variable in order to add another level to your scatter plot. This can be done both with use of `if` statements, as in the first plot below, and `by` statements, as in the second plot.


***/

// conditional scatterplot with 25 percent sample of data
preserve                                // preserve data
sample 25                               // sample random 25%

graph twoway (scatter bynels2m byses1 if urm == 0, ///
                  mcolor(blue*.5%25) ///
                  msize(tiny) ///
				  ) ///              
              || scatter bynels2m byses1 if urm == 1, ///
                  mcolor(orange*.5%25) ///
                  msize(tiny) ///
                  ytitle("NELS Math Scores") ///
                  xtitle("SES") ///
                  legend(order(1 "Non-Minority" 2 "Underrep Minority")) ///
                  name(sc_complex, replace)

graph export sc_complex.$gtype, name(sc_complex) replace

restore  



                               // restore data

// conditional scatterplot with by
graph twoway scatter bynels2m byses1, by(bystexp,note("")) ///
    msize(*.05) ///
	mcolor(dknavy) ///
    ytitle("NELS Math Scores") ///
    xtitle("SES") ///   
    note("") ///
    name(sc_cond, replace) 

	
graph twoway scatter bynels2m byses1, ///
			subtitle(, ring(0) pos(11) nobexpand fcolor(white%1) lstyle(none)) /// 
			by(bystexp, total note("")) ///
    msize(*.05) ///
	mcolor(dknavy) ///
    ytitle("NELS Math Scores") ///
    xtitle("SES") ///   
    note("") ///
    name(sc_cond2, replace) 	
	 	

graph export sc_cond2.$gtype, name(sc_cond2) replace

/***

You can also run a scatter plot across levels of a categorical variable if you suspect the underlying relationship may not be the same in each level of the categorical variable. The `matrix` plot helpfully with plot each combination of included varibles against each other to produe a sort of "small multiples" correlation plot. I mostly don't recommend running a matrix plot.

***/

// matrix plot:NO
graph matrix bynels2m bynels2r byses1 byses2, name(matrix_plot) msize(vtiny)
graph export matrix_plot.$gtype, name(matrix_plot) replace



/***
Scatterplot of proportions
-------------------------

If you have a binary dv, you can do a scatterplot. What you need to do is calculate the proportion of the sample in ranges of another continuous variable. A standard solution here is to use percentiles of another variable. Below I calculate the proportion of students who plan to go to college for each percentile of math scores, then plot the result. This can be a bit "too neat" so be careful.

***/

// Proportions plot trick

xtile pct_math = bynels2m, nq(100)

egen fouryr_avg= mean(fouryr) , by(pct_math)

graph twoway scatter fouryr_avg pct_math, ///
			xtitle("Math Score Pctile") ///
			ytitle("Pr(Plan to go to 4yr)") ///
			mcolor(blue*.5%50)
/***

Describing relationships between a categorical and a continuous variable
------------------------------------------------------------------------

### Plots

There are multiple options for plotting the relationship between a categorical and a continuous variable. A particularly useful option is to plot the continuous variable as a series of boxplots, one for each level of the categorical variable.

#### Boxplots

For boxplots to be effective, they should be sorted by the median of the dependent variable. This contrast is shown in the two figures below.

***/


// boxplot of math score over parental education
graph box bynels2m, over(bypared2, ///
                         label(alternate ///
                               labsize(tiny) ///
                               ) ///
                         ) ///
                    name(box1, replace)

graph export box1.$gtype, name(box1) replace

graph box bynels2m, over(bypared2, ///
                         label(alternate ///
                               labsize(tiny) ///
                               ) ///
                         sort(1) ///
                         ) ///
                    name(box2)

graph export box2.$gtype, name(box2) replace


/***
Bar Plots
------------
Bar plots are always a great option, particularly for policy audiences. Below I go over some options when using bar plots. 

***/

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
	
//Better bar for nice CIs	
betterbarci bynels2m bynels2r [pw=bystuwt], ///
			over(bypared2)  
					

// Statplot: ssc install statplot
statplot bynels2m bynels2r, over(bystexp,sort(1) descending) over(bysex)  name(statplot)
	
	
/***

#### Dot plots

Dot plots can also be useful for plotting the measure of central tendency across groups. In this case, we'll produce two plots, one each for reading and math scores, and then combine them into a single graphic.

***/	
	
// dot plots of continuous against categorical
graph dot bynels2m, over(bypared2, ///
                         label(alternate ///
                               labsize(tiny) ///
                               ) ///
                         ) ///
                    ytick(0(.10).80) ///
                    ylabel(0(.1).8) ///
                    ytitle("Math Scores") ///
                    marker(1, msymbol(O) mcolor(dknavy)) ///
                    name(dot_math,replace)

graph save dot_math.gph, replace

graph dot bynels2r, over(bypared2, ///
                         label(alternate ///
                               labsize(tiny) ///
                               ) ///
                         ) ///
                    ytick(0(.10).80) ///
                    ylabel(0(.1).8) ///
                    ytitle("Reading Scores") ///
                    marker(1, msymbol(O) mcolor(orange*.5)) ///
                    name(dot_read,replace)

graph save dot_read.gph, replace

// combine graphs into one plot
graph combine dot_math.gph dot_read.gph, ///
    name(dot_both, replace) ///
	cols(1)


// export combined graphics
graph export dot_both.$gtype, name(dot_both) replace


/***

Describing relationships between two categorical variables
----------------------------------------------------------

### Plots

The basic tool for comparing two categorical variables is the crosstabulation. In a crosstabulation we take a look at counts of the sample that are identified by their presence in cells created by the two categorical variables. There are several tools for plotting categorical variables, including tabplots, jittered plots, and heatmaps.


#### Using Catplot


***/

catplot  newpln bypared2 , ///
percent(bypared2) ///
var1opts(label(labsize(small))) ///
var2opts(label(labsize(small)) relabel(`r(relabel)')) ///
ytitle("Percent of Respondents by Parental Education", size(small)) ///
blabel(bar, format(%4.1f) size(vsmall)) ///
intensity(25) ///
asyvars ///
legend(rows(1))

/***
#### Tabplots

Below are examples of a tabplot, with both two and three dimensions.


***/


// TABPLOT

// tabplot of parental education against student plans
tabplot bypared2 newpln, name(tabplot1, replace) ///
    percent(bypared2) ///
    showval ///
    subtitle("") 

graph export tabplot1.$gtype, name(tabplot1) replace

// tabplot again, but with new dimension
tabplot bypared2 newpln, by(bysex) ///
    percent(bypared2) ///
    showval ///
    subtitle("") ///
    name(tabplot2, replace)

graph export tabplot2.$gtype, name(tabplot2) replace

// jitter categorical against categorical
graph twoway scatter f1psepln bypared, name(jitterplot) ///
    jitter(5) ///
    msize(vtiny) ///
	mcolor(dknavy)

graph export jitterplot.$gtype, name(jitterplot) replace

// heatmap of base year student plans and parental education
tddens bypared f1psepln, title("") ///
    xtitle("Parent's Level of Education") ///
    ytitle("PS PLans")
    
graph export heatmap.$gtype, replace

/***

When checking crosstabulations, we can produce two-way tables that include survey weights in the command itself.


***/

// table using weights directly
table byrace2 f1psepln [pw = bystuwt], by(bysex) contents(freq) row 


/***

Of course, if we want to use a table in a paper, we should use `esttab`.

***/

//  cross table of categorical
estpost svy: tabulate byrace2 newpln, row percent se

eststo racetab

esttab racetab using race_tab.$ttype, ///
    replace ///
    nostar ///
    nostar ///
    unstack ///
    nonotes ///
	nomtitles ///
	nonumbers ///
    varlabels(`e(labels)') ///
    eqlabels(`e(eqlabels)')

// end file     
log close
exit
