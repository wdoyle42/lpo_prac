// Assignment three followup
// Will Doyle
// 2019-01-30

estimates clear

use api, clear

//complete the following steps for three different sizes of schools: 
//small (less than 25th percentile in enrollment), middle (middle two quartiles), 
//large (above or equal to 75th percentile). 
//Do this by creating a loop structure around the following steps.

local size small

local tab_type rtf
//Create a series of macros, one for each of the following characteristics of schools: 
//finance, teachers, parents

local y api00

local finance meals 

local teachers emer

local parents col_grad



/* Three groups: small enrollment, moderate enrollment, high enrollment */

sum enroll, detail 
  
gen enroll_level=enroll<=r(p25)

replace enroll_level=2 if enroll>r(p25)&enroll<=r(p75)

replace enroll_level=3 if enroll>r(p75)

replace enroll_level=. if enroll==.

label define sizes 1 "Low enrollment" 2 "Middle enrollment"  3 "High enrollment"

label drop sizes

local sizes small medium large

gen small=enroll_level==1

gen medium=enroll_level==2

gen large=enroll_level==3

foreach size of local sizes{

preserve

keep if `size'==1


//Create a table of descriptive statistics for these variables using the esttab command.
// Make sure it is clearly labeled.

eststo descriptives: estpost tabstat `y' `teachers' `finance' `parents', ///
    statistics(mean sd N) ///
    columns(statistics) ///
    listwise 
 
 
esttab descriptives using esttab_means_`size'.`tab_type' , ///
    main(mean) ///
    aux(sd) ///
    nostar ///
    nonote ///
    label ///
    nonumber ///
    replace 



//Generate a table of conditional means of api00 as a function of other 
//interesting independent variables.


/* Three groups: small class size, middle, and large */
sum emer, detail 
  
gen emer_level=emer<=r(p25)

replace emer_level=2 if emer>r(p25)&emer<=r(p75)

replace emer_level=3 if emer>r(p75)

replace emer_level=. if emer==.

label define sizes 1 "Low percent emergency" 2 "Middle percent emergency"  3 "High level emergency"

label values emer_level sizes


eststo descriptives_emer_`size': estpost tabstat `y' `teachers' `finance' `parents', ///
    by(emer_level) ///
    statistics(mean sd N) ///
    columns(statistics) ///
    listwise 

esttab descriptives_emer_`size' using esttab_means_emer_`size'.`tab_type', ///
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
 

//Create a scatterplot or scatterplots that display some of the key 
//relationships in the data. Clearly label this scatterplot.

graph twoway (scatter api00 emer, msize(tiny) ) ///
			 (lfit api00 emer) 	
			 
graph export "api_emer_`size'.png", replace



//Run a series of regressions, one for each “set” of characteristics and 
//one fully specified model, with api00 as the dependent variable.


/* Estimate Models */
	
quietly reg `y' `teachers'
estimates store tch_model_`size', title ("Model 1")                                

quietly reg `y'  `teacher' `parents'
estimates store tch_pt_model_`size', title ("Model 2")

quietly reg `y'  `teachers' `parents' `finance'
estimates store tch_pt_fin_model_`size', title ("Model 3")



#delimit;

esttab *_model_`size' using `y'_models_`size'.`tab_type',     /* estout command: * indicates all estimates in memory. rtf specifies rich text, best for word */
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





//Create a graphic the shows the impact of the various independent variables 
//on the outcome variable. Clearly label and describe this graphic.

estimates restore tch_pt_fin_model_`size'

#delimit;
plotbeta emer|col_grad|meals,
          labels
          xtitle (Parameters)
          title ("Full Model")
          subtitle ("From OLS regression. Dep Var= `y', School Size=`size'")
          xline(0,lp(dash))
		  ;

graph save model_`size',replace;

#delimit cr

restore

} // End loop over school sizes 

exit 

// s2_03_assignment_<lastname>.do
