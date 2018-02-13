// # Assignment 5

// Using your own dataset, or one of the example datasets, complete the following steps. Use a continuous dependent variable.

use ../../data/plans2.dta

//1. Create a basic model with four or five key covariates, including continuous, at least two categorical variables and binary variables.

svyset psu [pw=f1pnlwt],strat(strat_id)

eststo basic: svy: reg bynels2m byses1 i.byrace2 i.bypared noplan


//1. Create a properly formatted table based on these results.
//Later


// 1. Run another model that interacts one categorical variable with one binary variable.
eststo interact: svy: reg  bynels2m byses1 i.byrace2 i.bypared i.noplan#i.bypared

//1. Create a properly formatted table based on these results.

esttab basic interact using assign5_table.rtf, ///
 refcat(2.bypared "Parental Education, Reference=LT HS" 1.noplan#1b.bypared "Interaction of Plans with Parental Education", nolabel) ///
 interaction(" X ") ///
   label ///
                   nomtitles ///
                       nobaselevels ///
               nodepvars              ///
                b(3)                   ///
                se(3)                     ///       
               r2 (2)                    ///
               ar2 (2)                   ///
               scalar(F  "df_m DF model"  "df_r DF residual" N)   ///
               sfmt (2 0 0 0)               ///
               replace               

//1. Run the margins comand to generate predictions from the interacted model, with everything held constant except the two variables used for interaction.

estimates restore interact


// Margins to figure out what's going on
eststo marg_predict: margins, predict(xb) at((mean)  bypared=(2 6 8) noplan=(0 1)) post

                        

//1. Create a table based on the results of the margins command.

esttab marg_predict using margins.rtf , margin label nostar ci ///
  varlabels(1._at "College Plans, Parental Ed=HS" ///
                  2._at "No College Planns, Parental Ed=Hs" ///
                      3._at "College Plans, Parental Ed=College" ///
                          4._at "No College Plans, Parental Ed=College" ///
                              5._at "College Plans, Parental Ed=Graduate" ///
                                  6._at "No College Plans, Parental Ed=Graduate" ) ///                                                                
        replace                      


//1. Create a figure based on the results of the margins command. 
marginsplot, recast(scatter) ciopts(recast(rspike))
