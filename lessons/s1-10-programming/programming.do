/***
#### PURPOSE

Stata programming will save you time, energy, and frustration. Investing the
time now into learning how to program will certainly pay off. It may
seem easy enough now to just copy code 10 times if you need to complete
an operation 10 times, but force yourself to use your programming
skills. By Maymester, you will thank yourself.

<br>


Tools you already have
----------------------

Programming is more than just knowing the most convenient commands to
shorten the time you spend on menial tasks. It involves thinking about
how the commands you do can be combined to make a more efficient,
readable do-file for you and anyone else who will look at it in the
future.

The following points are good places to start when you are trying to
make your program file more efficient.

-   Previous code: You may have already encountered this strategy in the
    work that you have done thus far for the class. Snippets of code
    that you have already toiled over can be used again and again. The
    following tips might come in handy.
    -   Save your do-files  
    -   Label them well  
    -   Re-use old code, copy-paste  
    -   Make templates if you use a certain piece of code often  
    -   Create files to include or do (e.g., "programs" you can
        immediately run for things like dealing with missing data)  
-   Programming: When you approach your Stata script as a programmer,
    you have a different perspective, a certain general approach on how
    to put these pieces together. The following points are questions you
    might ask yourself in going through the general process for
    your program.
    -   What is the overall task I am trying to accomplish?  
    -   How are the variables structured? Which variables go together?  
    -   What tasks need to be repeated?  
    -   What procedures may stay the same, though the numerical values
        may change?

		
Remember, The three virtues of a computer programmer are laziness, impatience, and hubris. 

*Laziness* The programmer wants to write as little code as is humanly possible.

*Impatience* The programmer does not have the patience to undertake a tedious task.

*Hubris* The programmer is proud enough to believe that she can
  make the computer accomplish seemingly impossible tasks. 		
<br>


***/

version 16
capture log close
log using "programming.log",replace

/* PhD Practicum */
/* Some simple demonstrations of macros and loops, good programming principles */
/* Will Doyle*/
/* LAST: 2021-11-10 */

clear

/***
Organizing your do file
-----------------------

As your do files increase in length, you will want some type of
organizational structure. A table of contents at the top of the script
can be very helpful. You certainly don't have to do it the way the way
shown below, but you should have something that makes sense to you and
will be clear to others who may read your script.

    . // TABLE OF CONTENTS
    . // 0.0 Set preferences/globals
    . // 1.0 Recoding /*KW: Bart */
	.//  2.0 Descriptives /*KW: Lisa */
	.//  3.0 Analysis /* KW: Homer */
	.//  4.0 Graphics /* KW: Marge */
	
<br>

***/

************************************
/* TOC */

/* Section 0: Setup and declarations*/

/* Section 1: Recoding KW: Bart*/

local recoding=1

/* Section 2: Analysis KW: Lisa*/

local analysis=0

************************************

************************************
/* Declare Macros */
// set plot and table types
global gtype png
global ttype rtf
************************************

clear matrix

use ../../data/plans2

svyset psu [pw=bystuwt], strat(strat_id) singleunit(scaled)

/***

Macros
--------

What's a macro? A way of storing information in Stata. 

Why? Simplification. Lots of times we use lists of things. Say we need
to use a list of terms that would influence college choice. This could
be financial, academic, and family influences. We choose indicators to
represent variables in each of these areas. What if we change one of
these? We could change it each and every time, or if we had it stored
in a macro we change it just once. 

Macros are also used so that commands don't need to be repeated again
and again, and instead can be written just once. This cuts down on
mistakes and allows the analyst to focus on the analysis. The whole
goal here is to get the computer to do the boring (repetitive) tasks,
while the analyst does the interesting (analytical and interpretive)
tasks. 

There are two types of macros in Stata, local and global macros. Global
macros should basically never be used. Global macros are persistent across "sessions" meaning they can be accessed as long as Stata is open. The problem here is that you might run different do files for different projects in the same session. 

A local macro is "forgotten" by Stata as soon as the code stops running. This is much safer, in that it will only be in use when expected, and will not persist when new do files are being called. 

So, let's do a macro: this macro will contain two variables from the
plans dataset, math and reading test scores
***/


/*Generating macros*/

local tests bynels2m bynels2r 

/***
What can we do now that we have a macro? Any command that can be run
on the object can now be run on the macro. However, the macro must be
referenced corectly. Referring to the macro without quotes will
result in an error:
***/

//summarize tests /* Won't work */


/***
Why didn't this work? Without proper specification, a macro can not be
accessed. The macro must be *dereferenced*. For STATA to know
it's dealing with a macro, you must put it in single quotes, meaning
that you start with the left tick (`) and close with the apostrophe (').
Most of the curse words directed at STATA have come about as a result
of this syntax. To use our macro, we would do the following:
***/

summarize `tests' /*Will work */

local ses byses1 byses2

summarize `ses'

exit 

/***

*Quick Exercise*

Create a macro that contains two variables. Run a summarize command on
the macro.

***/

/***
A Note on Local vs. Global macros

When you run a do file with a local macro, Stata will hold that local macro in
memory only while the do file is running. After it stops, the macro is
dropped. This is important. Say you had a do file with a local named
`family`, because it contained variables relating to a
student's family. After running your do file, you'd like to summarize
the family variables. 


`  . sum `family' `

You'll get back an error message because the `family` macro is
no longer held in memory. For this reason, when using macros, it's a
good idea to run the do file as a whole each time, instead of just
running pieces of it. 
***/


/***
 Programming Concepts
------------------------ 

<br>

Scalars

In the language of matrix algebra, a scalar is a single number. In
STATA a scalar is a value that can only hold one value at a time. The
value can be numeric or a character.

To define a scalar, use the following syntax:


`scalar pi=3.14159`

More usefully we can define scalars to take on the value of a
result. For instance, to calculate a standardized transformation of
the variable `income' we could do the following:

`summarize income'

`scalar mean_income=r(mean)`

`scalar sd_income=r(sd)`

`gen stand_income = (income-mean_income)/sd_income`

Scalars are also quite useful if you have a constant in a do file that
you may wish to change. For instance, if you'd like to limit your
analysis to a certain age group, but you might change that age group
as you go through different iterations. 

Quick Exercise
---------------

Generate scalars for a binary or continuous variable's sum and a variable's total number of units from the plans dataset. Divide the sum by the total number of units to obtain the mean. 


The `varlist` Concept
-----------------------

A varlist is a list of variables (of all things). Say for instance you
wanted a local that was equal to just data elements that were in the
base year. We know from NCES nomenclature that all base year data
elements in ELS are preceded by ``by''. We can use this, plus the wild
card operator *, to create a varlist in the following way: 

local bydata by*

This tells STATA to include every variable in the local bydata that
begins with by. 

Say you wanted to create a local that included the first five
variables in the dataset. This can be done using the - as part of the
command:

`local first_five stu_id-f1sch_id`

If you wanted every variable that had ses, and you knew that variables
could only have one letter or number at the end, you could do
something like this:

`local myses *ses?`

*Quick Exercise*

Generate a varlist that contains only nels related variables, without
naming the variables themselves. 

The `numlist` concept
----------------------

A numlist is a way of constructing a pattern of numbers. Stata
recognizes several types of patterns for numlists, including a list like 
0 1 2, a sequence like 0/2 and a sequence with steps like 0(1)2.  
 

Loops
-----------

A loop construct is the basic stepping stone to a life of laziness,
impatience and hubris. 

All loop constructs follow the same basic format: 

`(A pattern goes here){`
`(A series of commands for each step in the pattern goes here)` 
}` 

Note the braces: these always denote the beginning and end of a
loop. The brace must follow the pattern command, and must always be
closed after the body of the loop is complete. 

With a loop construct, if you can figure out the underlying set of
commands that you'd like to repeat, and if you can figure out the
pattern that you'd like to apply them, you can simplify some pretty
daunting tasks down to something rather simple. There are three basic
ways to run loops in STATA: the `forvalues`, `foreach` and
`while` commands.

Here's an example: Missing data, as you probably know, are a hassle
when working with NCES datasets. They can be listed as -4, -8, or -9.
Replacing this for every single variable in your dataset with a .
would be time consuming and error prone. The following loop structure
(which I will explain later) can accomplish it for you in just a few
lines of code.


***/



/*************************/
/* Recoding Section Begin*/
/*************************/



if `recoding'==1{
/* Difference between globals and locals */

foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */
              foreach i of numlist -4 -8 -9 { /* Start inner loop */
                     replace `myvar'=. if `myvar'== `i'
                                            }  /* End inner loop */
                                          } /* End loop over variables */

  
 /*
foreach myvar of varlist stu_id-f1psepln{ /* Start outer loop */             
                     replace `myvar'=. if `myvar'== -4| `myvar'==-8 | `myvar'==-9                            
                                          } /* End loop over variables */
 */
  
  
local race_names amind asian black hispanic multiracial white

drop `race_names'

//Extend macro function
local race_var_label: label byrace2 1

di "`race_var_label'"

tab(byrace2), gen(race_)

local i=1 // initialize counter
foreach race_name of local race_names{	 // loop over each of the elements in race_names identified above
	rename race_`i' `race_name' // rename each variable generated by tab as equiv name
	local race_var_label: label byrace2 `i' // grab value label for the that level
	label var `race_name' "`race_var_label'" // make the value label the variable level
	local ++i //iterate counter by 1, equivalent to: local i=`i'+1
}


save plans_b, replace
}/*end recoding section conditional*/

else{
use plans_b, clear
}/* end else */

/**********************/
/* Recoding Section End */
/**********************/



/**********************/
/* Analysis Section */
/**********************/
if `analysis'==1{

//listing analysis variables in locals

local y bynels2m bynels2r

local demog amind asian black hispanic white bysex

local pared bypared bymothed

bysort `demog': sum `y' 
bysort `pared': sum `y'


 /* Scalar commands*/
scalar pi=3.14159
 display "`pi'"

summarize bynels2m

scalar mean_math=r(mean)

scalar sd_math=r(sd)

scalar sum_math=r(sum)

scalar units_math=r(N)

scalar math_mean=sum_math/units_math

gen stand_math= (bynels2m-mean_math)/(2*sd_math)

/*Varlist  commands*/

local bydata by*

local first_five stu_id-f1sch_id

local myses *ses?

sum *ed

sum by*ed


/* Number List */
				
				
/***

The forvalues structure
-------------------------

The `forvalue` command tells STATA to execute the series of
commands within the braces in a numerical format defined by a
numlist. 

The general structure of a forvalues command is:


`  foreach [local_name] of [number pattern] {
    (run the following commands on [local\_name]) 
    }`

***/				
				
*Simple forvalues command

forvalues i= 1/10{
 di "This is number `i'"
}

/***

In the example above, I defined the placeholder macro i to be equal to
the numlist 1-10, starting at 1 and moving up by one for each run
through the loop. The braces define the body of the loop. The command
is a simple print command, asking STATA to display the text and the
value of the placeholder macro i. 

<br>
A more complex example is to convert the date of birth variable into
an age, and then convert the result into a series of binary variables for  14, 15, 16, 17 or 18 years old(you'll need to download and install the nsplit command).
***/


*Use nsplit command to separate out birth year and day

nsplit bydob_p, digits (4 2) gen (newdobyr newdobm)

gen myage= 2002-newdobyr

forvalues i = 14/18{
gen age`i'=0
replace age`i'=1 if myage==`i'
replace age`i'=. if myage==.
}

/***
Foreach
----------

The foreach structure is a more general version of the fovralues
command. The general pattern for a foreach structure is: 


` foreach [local\_name] of [varlist, local numlist, etc] {`
    `(run the following commands on [local\_name]) `
    `}`


In the example on missing data, I used a foreach command to recode the
variables. Let's use one now to standardize two test variables by
subtracting the mean and dividing by 2 times their standard deviation
(which is recommended by many statisticians).

***/


*Simple foreach command

local mytest *nels*

foreach test of local mytest {
  sum `test'
}



*Standardizing continous variables by 2 sd
foreach test of varlist *nels*{
 sum `test'
 gen stand_`test'=(`test'-r(mean))/(2*r(sd))
}


/*
// NO
foreach test of local mytest { sum `test'
}


// NO
foreach test of local mytest { 
sum `test'}

//NO
foreach test of local mytest { sum `test'}

*/

/***
*Quick Exercise*

Create a macro that contains only base year variables, with the
exception of the two test variables (bynels2m and bynels2r). Write a loop
that tabulates every variable in this macro. 
***/

forvalues i =1(3)100{
di "I can count by threes, look! `i' "
}

/***
\subsection{The while command}

The while command is a little outdated. It used to be the main way to
construct loops in Stata, but the forvalues and foreach command have
since superseded it i in most cases. However, it can still be useful,
mainly when you're running complex code that you want to stop if
something bad happens. 

The general format of the while command is:


`  while (a condition is true) {`
`		(run these commands) `
`}`

So, we can repeat the counting program from above, but use the while
command:
***/

*The while command
local i = 1
while `i' < 10 {
    di "I have not yet reached 10, instead the counter is now `i' "
    local i=`i'+1
  }
   
  // Foreach
  
  foreach i of numlist 1/10{
 di "Foreach can count too, look: `i'"
  }
  
  

local by_select bysex byrace bypared-byincome bystexp

foreach myvar of local by_select{
tab1 `myvar'
}

foreach myvar in `by_select'{
tab1 `myvar'
}

foreach myvar of varlist bysex-byincome{
tab `myvar'
}

/***
Nested Loops
------------

You can run loops within loops, which is actually a very powerful
function. Here's a simple example:

\texttt{forvalues i = 1/10 \{\\
          for values j =1/10 \{\\ 
        di ``This is outer loop, inner loop `i'''
        \} \\
        \} \\
         }

The motivating example on missing data uses a nested loop
structure. The outer loop consists of all of the variables, while the
inner loop iterates over the possible missing value codes (-4,-8,-9). 
***/


*Nested loops
forvalues i =1/10 { /* Start outer loop */
  forvalues j = 1/10 { /* Start inner loop */
    di "This is outer loop `i', inner loop `j'"
                      } /* End inner loop */
                    } /* End outer loop */
/* Extended Example */
use plans2, clear

svyset psu [pw=bystuwt], strat(strat_id) singleunit(scaled)

// next new recoded student expectations
recode f1psepln (1/2 = 1) (3/4 = 2) (5 = 3) (6 = .) (. = .), gen(newpln)
label var newpln "PS Plans"
label define newpln 1 "No plans" 2 "VoTech/CC" 3 "4 yr"
label values newpln newpln

// first new recoded parental education level
recode bypared (1/2 = 1) (3/5 = 2) (6 = 3) (7/8 = 4) (. = .), gen(newpared)
label var newpared "Parental Education"
label define newpared 1 "HS or Less" 2 "Less than 4yr" 3 "4 yr" 4 "Advanced"
label values newpared newpared

local ivars byrace2 newpared

erase plan_tab.$ttype // Delete the table (can't append and replace)

//  cross table of categorical
foreach ivar of local ivars{
	estpost svy: tabulate `ivar' newpln, row percent se
	eststo desc_`ivar'

	
esttab desc_`ivar' using plan_tab.$ttype, ///
    nostar ///
    nostar ///
    unstack ///
    nonotes ///
    varlabels(`e(labels)') ///
    eqlabels(`e(eqlabels)') ///
	nomtitles ///
	nonumbers ///
	append
	
	} // end loop over variables 
	
					
}/* End analysis section */
else{
di "Did not run analysis"
}
 
/***

Your best friend here is `set trace=on`. Also, I've found
STATA's foreach, forvalues commands to be really tricky. If you know
that your ``core'' code is running fine, the main problem with loops
is probably going to be in the syntax for your forvalues or foreach
command. 

It's also a really good idea to build in sanity checks if you're
running complex programs. Small mistakes can really compound when
you're using these powerful tools. 

***/ 
  
  
/***

In Class Exercise
-----------------

Use the plans dataset. Create an algorithm that will convert a continous variable into a series of binary variables, one dummy variable for each quintile.
Make sure the resulting binary variables are properly labeled.

Now, run this for every continuous variable in the dataset, using a loop
structure.

Bonus challenge: can you identify continuous variables programmatically? 

***/  
  
exit


