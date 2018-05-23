// Assume that b1-b5 are estimates from 5 multiply imputed datasets
// se1-se5 are se's from these same 5
local k=1
//make up some estimates
foreach i of numlist .1(.1).5 {
scalar b`k'=2+`i'
scalar se`k'=.02+`i'
local k=`k'+1
}

// Set number of imputations
scalar k=5

// Mean estimate from 5 multiple imputed datasets
scalar mean_est=(b1+b2+b3+b4+b5)/k

// Between variance estimates from the 5 coefficients: 1/n*(sum(x-xbar)^2)
scalar bt_est_var= ((b1-mean_est)^2+ ///
			(b2-mean_est)^2+ ///
			(b3-mean_est)^2+ ///
			(b4-mean_est)^2+ ///
			(b5-mean_est)^2)/k

// Mean of variances from 5 standard errors 
scalar mean_var= (se1^2+se2^2+se3^2+se4^2+se5^2)/k

// multiple imputation variance= mean variance plus between estimate variance
scalar mi_var= mean_var+bt_est_var
// standard error is square roort of variance
scalar mi_se=sqrt(mi_var)			
