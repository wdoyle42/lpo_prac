capture log close

// Assignment 2 followup
// Working with MROZ data
// Will Doyle
// 2020-01-23


use mroz, clear

//Create a macro called y, and assign its value to the variable hours

local depvars hours wage

foreach y of local depvars {

//Create three other macros, named family, husband, and qualifcations. 
//Place in each macro a set of variables related to family characteristics, 
//husband’s labor force characteristics, and the woman’s labor force qualifications.


local family kidslt6 kidsge6

local husband husage huseduc

local qualifications educ exper 


//Create a summary table of all of the variables from above, including both means and standard deviations.


tabstat `y' `family' `husband' `qualifications', stat(mean sd)



//Run a total of four regressions. The first three should have y as the dependent variable and each “cluster” 
//of variables represented by a macro as the sole set of independent variables. 
//The last should have all of the independent variables on the right hand side.

reg `y' `family'

reg `y' `husband'

reg `y' `qualifications'

reg `y' `family' `husband' `qualifications'


//Repeat the above step, but reassign the macro y to an alternative labor force 
//outcome for the woman (your choice).

} // End loop over depvars 


//In a single paragraph (no more than 150 words), comment on the results of your estimation. 
//This should be a comment in the do file.
