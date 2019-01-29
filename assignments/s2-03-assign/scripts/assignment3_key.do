
capture log close

/* Assignment 3 Followup */
/* AU: Will Doyle */
/* Init: 1/29/19 */
/* Rev: NA */

/*1. Create a series of macros, one for each of the following characteristics 
of schools: parents, teachers and student.*/

global outdir "../output/"

global ddir "../data/"

local y api00

local parents hsg some_col col_grad grad_sch

local teachers emer

local students meals ell 

local tab_type rtf

local school_types full elem high_school middle

/* Open Data */

use "${ddir}api.dta", clear


/* Recoding */


sum emer, detail 
  
gen emer_level=emer<=r(p25)

replace emer_level=2 if emer>r(p25)&emer<=r(p75)

replace emer_level=3 if emer>r(p75)

replace emer_level=. if emer==.

/*Labeling */

label define emer_levels  ///
1 "Lowest Percent Emergency Credential" ///
 2 "Middle Range Emergency Credential" ///
 3 "Highest Percent Emergency Credential"

label values emer_level emer_levels

la var api00 "Academic Performance Index 2000"

la var emer "Pct of Teachers w/ Emergency Credentials"

/* Start loop over results */

/* Start index for school type 1,2,3*/
local i=0

foreach school_type of local school_types{

preserve 

if `i'==0{
di "********Estimating results for full sample*********"
//capture system("mkdir `school_type'")

}
else{
keep if stype==`i'
di "*********Estimating results for `school_type'*******"
}

/*2. Create a table of descriptive statistics for these variables
 using the esttab command. Make sure it is clearly labeled.*/

 /* Setting up and outputting descriptive stats */

eststo descriptives: estpost tabstat /// 
	`y' `students' `teachers' `parents'  , ///
    statistics(mean sd) ///
    columns(statistics) 
   
esttab descriptives using ///
"${outdir}esttab_means_`school_type'.`tab_type'" , ///
    main(mean) ///
    aux(sd) ///
    nostar ///
    nonote ///
    label ///
    nonumber ///
    replace 

 
/*3. Generate a table of conditional means of api00 as a
 function of other interesting independent variables.*/

/*Summary table */

eststo descriptives_emer: estpost tabstat `y' ///
`students' `teachers' `parents' , ///
    by(emer_level) ///
    statistics(mean sd) ///
    columns(statistics) ///
    listwise 

esttab descriptives_emer using ///
 "${outdir}esttab_means_emer_`school_type'.`tab_type'", ///
    main(mean) ///
    aux(sd) ///
    nostar ///
    nonote ///
    label ///
    unstack ///
    nonumbers ///
    nomtitles ///
	collabels(none) ///
    replace 

 
/*4. Create a scatterplot or scatterplots that display 
some of the key relationships in the data. Clearly label 
this scatterplot.*/


graph twoway scatter `y' emer , ///
	msize(tiny) 
	
graph export "${outdir}scatter_`school_type'.png", replace
	
/*5. Run a series of regressions, one for each “set” of 
characteristics and one fully specified model, with api00 
as the dependent variable.*/

quietly eststo teacher_model,title("Teacher Model"): ///
reg `y' `teachers' 

quietly eststo student_model,title("Student Model"): ///
reg `y' `students' 

quietly eststo parent_model,title("Parent Model"): ///
reg `y' `parents' 

quietly eststo full_model,title("Full Model"): ///
reg `y' `teachers' `students' `parents' 


/*6. Report the results of your regression in a
 beautifully formatted table.*/

 
#delimit;

esttab *_model using "${outdir}`y'_model_`school_type'.`tab_type'",     /* estout command: * indicates all estimates in memory. rtf specifies rich text, best for word */
               label                          /*Use labels for models and variables */
               nodepvars                      /* Use my model titles */
               b(2)                           /* b= coefficients , this gives two sig digits */
               se(2)                         /* I do want standard errors */
               r2 (2)                      /* R squared */
               ar2 (2)                     /* Adj R squared */
               scalar(F  "df_m DF model"  "df_r DF residual" N)   /* select stats from the ereturn (list) */
               sfmt (2 0 0 0)                /* format for scalar stats*/
               replace                   /* replace existing file */
               ;

#delimit cr


 
/*7. Create a graphic the shows the impact of 
the various independent variables on the outcome variable.
 Clearly label and describe this graphic.*/

estimates restore full_model

#delimit;
plotbeta hsg |some_col |col_grad |grad_sch |emer| meals |ell  , /*Variables in regression to report */
          labels                              /*Use Variable Labels*/
          xtitle (Parameters)                 /*Label of x axis*/
          subtitle ("From OLS regression. Dep Var= Acad Perf Index") /*Description */
          xline(0,lp(dash)) /* Line at 0: if 95% ci crosses, not stat sig */
		  ;

#delimit cr

graph export "${outdir}plotbeta_`school_type'.png", replace


restore
local i=`i'+1
}/* End loop over school types */

 
exit
