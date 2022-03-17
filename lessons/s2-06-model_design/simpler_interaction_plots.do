// Simpler Interaction Plots
// Will Doyle
// 2022-03-17 
// Examples of how to use margins and marginsplot to understand interactions

set scheme s1color

use ../../data/plans2.dta

local y bynels2m

local controls byses1 i.bypared


// Binary to binary interactions

// Interact fouryr with female 

reg `y' i.female##i.fouryr `controls'

margins, predict(xb) at((mean) _continuous ///
							(base) _factor ///
							female=(0 1) ///
							fouryr=(0 1))
marginsplot

marginsplot, recast(scatter) ///
			ytitle("Predicted Math Test Scores") ///
			legend(order(3 "Does Not Plan to Go to a Four Year" ///
						4 "Plans to Go to a Four Year")) ///
						title("")


exit 
