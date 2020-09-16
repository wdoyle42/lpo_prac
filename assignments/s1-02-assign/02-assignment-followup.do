capture log close

// Assignment 2 follouwp
// creating analysis dataset from NCES data
// Will Doyle
// 2020-09-16

global ddir "../../data/"

/*
Using your research question from the first assignment describe briefly 10 variables that you think might be relevant to this study.

Using the dataset that you’d like to work with, find indicators to match the variables you’re looking for.

Generate code to subset your chosen variables from the full dataset.

Describe the data you’ve selected. Include the following information in your description of each continuous indicator:

Mean

Standard error of the mean

Median

Number missing

For categorical indicators, I need a tabulation across the levels of the indicator, including a category for missing data.

NB: Skip weights, etc, and focus on your variables of interest.

For this assignment, you should submit a .do file that subsets the variables you want from the full dataset and generates the proper descriptive statistics. Save the resulting file as your analysis file.

*/



// Does the source file exist?

capture confirm file ${ddir}"hsls_17_student_pets_sr_v1_0.dta"

di _rc

if _rc==0 {
	di "File hsls_17_student_pets_sr_v1_0.dta required from NCES codebook"
} 
else {

use  ///
	STU_ID ///
	X1SES ///
	X1RACE ///
	X1SEX ///
	X3TXSATMATH ///
	using "${ddir}hsls_17_student_pets_sr_v1_0.dta", ///
	clear
}	
		
renvars *, lower	

save "${ddir}hsls_analysis.dta",replace

di _N

replace x1ses=. if inlist(x1ses, -9,-8,-7,-4,-3)

tabstat x1ses, stat(mean)

tabstat x1ses, stat(semean)

tabstat x1ses, stat(median)

tabstat x1ses, stat(n)

inspect x1ses

//ssc install nmissing

nmissing x1ses

replace x1sex=. if inlist(x1sex,-9,-8,-7,-4,-3)

tab x1sex if x1sex==.

exit 
