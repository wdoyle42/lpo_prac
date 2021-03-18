clear 

/*
drawnorm x , n(10000)

drawnorm e 

gen y=1+2*x+e

postfile buffer beta_0 beta_1 using reg_1, replace

forvalues i=1/1000{

preserve

quietly sample 100, count

quietly reg y x

post buffer (_b[_cons]) (_b[x])

restore
}

postclose buffer

use reg_1, clear

kdensity beta_1, xline(2)
*/

clear

drawnorm x1 x2 , corr(1,-.8\-.8,1) n(10000)

drawnorm e

gen y=1+2*x1 +3*x2+e

reg y x1 x2

postfile buffer beta_1 using reg_2, replace 

forvalues i=1/1000{

preserve

qui sample 100, count

qui reg y x1

post buffer (_b[x1])

restore
}

postclose buffer

kdensity beta_1, xline(2)








