capture log close                       // closes any logs, should they be open
log using "programming.log", replace    // open new log

// NAME: Introduction to programming
// FILE: lecture6_programming.do
// AUTH: Benjamin Skinner
// REVS: Will Doyle
// INIT: 2 October 2013
// LAST: 1 October 2016
    
// h/t to Justin Shepherd

// TABLE OF CONTENTS

// 0.0 Set preferences/globals
// 1.0 Describing
// 2.0 Scalars
//   2.1 return
//   2.2 ereturn
//   2.3 scalar
// 3.0 Estimates
//   3.1 estimates store
//   3.2 estimates restore
// 4.0 Shortcuts
//   4.1 numlists
//   4.2 varlists
// 5.0 Macros
//   5.1 globals
//   5.2 numerical locals
//   5.3 varlist locals
//   5.4 nested locals
// 6.0 Matrices
// 7.0 Switches
// 8.0 Loops
//   8.1 if / else
//   8.2 foreach
//   8.3 forvalues
//   8.4 while
// 9.0 Nests

//  0.0 Set preferences/globals/load data
   
clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

use loondata, clear

//  1.0 Describing

// sum with if statement
sum flock1 if loon == 0
sum flock1 if loon == 1

// tab loon with summarize
tab loon, summarize(flock1)

// summarize with bysort
bysort loon: sum flock1

// summarize multiple variables with bysort
bysort loon: sum flock1 flock2 flock3

//  2.0 Scalars

//  2.1 return command

sum shells1
return list
di r(mean)

di r(sd)

//  2.2 ereturn command

mean shells1
ereturn list
di e(N)

//  2.3 scalar command

sum shells1
scalar mean_shells1 = r(mean)
sum feathers1
di mean_shells1

//  3.0 Estimates

//  3.1 estimates store command

mean ideas1
estimates store m_ideas1
   
//  3.2 estimates restore command

mean eggs1
estimates store m_eggs1
estimates restore m_ideas1
estimates replay
estimates clear

//  4.0 Shortcuts

//  4.1 numlist commands

sort shells1

list id shells1 loon upper in 1/10
list id shells1 loon upper in -10/l

gsort -ideas1

list id ideas1 loon upper in 1/10
list id ideas1 loon upper in -10/l
    
//  4.2 varlist commands 

sum shells1-flock3, sep(3)

sum flock*

//  5.0 Macros

//  5.1 global macros

global repstr "Long string I will use a lot and don't want to retype"

macro list

di "$repstr"

macro drop repstr

macro list

//  5.2 numerical local commands

local i 1
di `i'

local j = 2
di `j'

local k = `i'+`j'
di `k'

sum ideas1
local mean_ideas1 = r(mean)
di `mean_ideas1'
    
//  5.3 varlist local commands

local contributions ideas1 ideas2 ideas3 eggs1 eggs2 eggs3
sum `contributions', sep(3)

// 5.4 nested local commands

local whoareyou loon upper seasons
local wholeshebang `contributions' `whoareyou'
sum `wholeshebang', sep(3)

// 6.0 Matrix

mean ideas1 ideas2 ideas3

// return list to show r(table)
return list
matrix list r(table)

// store r(table)
matrix meanse = r(table)
matrix list meanse

// subset matrix
matrix meanse = meanse[1..2,1...]
matrix list meanse

// transpose matrix
matrix tmeanse = meanse'
matrix list tmeanse

// init blank 5 X 2 matrix
matrix blank = J(5,2,.)

// add to first row and show matrix
matrix blank[1,1] = 1
matrix blank[1,2] = 6
matrix list blank

//  7.0 Switch

// set switch
local graphs = 0

if `graphs' == 1 {
    scatter shells1 feathers1 if loon == 1
}

//  8.0 Loops

//  8.1 if/else command

local switch = 0    
    
if `switch' == 0 {
    sum loon if upper == 0
}
else {
    sum loon if upper == 1
}
  
//  8.2 foreach command

foreach var of varlist shells1-feathers3 {
    mean `var'
}

local memberships loon upper

foreach var of local memberships {
    mean `var'
}

foreach val in id {
    list `val' if eggs1 < 3
}

//  8.3 forvalues command

forvalues x = 1/10 {
    di `x'
}

forvalues y = 2(2)10 {
    di `y' 
}

forvalues z = 2 4 to 10 {
    di `z'
}

//  8.4 while command

local i = 1

while `i' < 11 {
    di `i'
    local i = `i' + 1
}

//  9.0 Nests

// set up locals for nest
local thoughts ideas1 ideas2 ideas3
    
forvalues i = 1/2 {
    if `i' == 1 {
        local type "Not a loon"
    }
    if `i' == 2 {
        local type "Loon"
    }
    foreach var of local thoughts {
        di "`i': `type'"
	sum `var' if loon == `i' - 1
    }
}

// end file     
log close
exit
