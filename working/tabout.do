

use ../data/plans_b, clear

svyset psu [pw=bystuwt], strat(strat_id)

// Conditional means
tabout bystexp using table1.xls, ///
	c(mean bynels2m se) sum svy replace ///

// crosstab	
	
tabout bysex bystexp using table2.xls, ///
 c(row) svy replace	
 
