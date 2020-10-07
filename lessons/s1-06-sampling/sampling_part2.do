/***
Sampling II
================
LPO 9951 | Fall 2020

<br>

#### PURPOSE

In the last lecture, we discussed a number of ways to properly estimate the means and variances of complex survey designs. In this lecture, we'll discuss how to use Stata's internal `svy` commands and various variance estimation methods to more easily and correctly estimate what we want.

<br>

***/

capture log close                       // closes any logs, should they be open
set linesize 90
log using "sampling_part2.log", replace    // open new log

// NAME: Sampling: Part 2
// FILE: sampling_part2.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 18 October 2014
// LAST: 7 October 2020
 
 
/***

Complex survey designs: Cluster sampling and stratification
-----------------------------------------------------------

In the NCES surveys you'll be using this semester, the designers combined a design that includes multistage cluster sampling with stratification. In ECLS, for example, the designers designated counties as *PSUs*. They next stratified the sample by creating strata that combined census region with msa status, percent minority, and per capita income. They then randomly selected schools within each *PSU* (schools were the *SSUs*) and then randomly selected kindergarteners within each school (students were the *TSUs*). They then created two strata for each school with Asian and Pacific Islander students in one stratum and all other students in the other. Students were randomly sampled within this second stratum. The target number of children per school was 24.

Weights in complex survey designs such as the one employed with ECLS are calculated via the same that we discussed in the last lecture. Nothing changes except for the layers of complexity. The good news, however, is that we a researchers don't have to compute the weights ourselves. Instead, we can use information provided by the survey makers.

The *PSUs* that are provided by NCES are what is known as "analysis *PSUs*". They aren't the identifier for the actual school or student. Instead, they are allocated within strata (many times 2 *PSU* per strata). Strata themselves may be analysis strata, that is, not the same strata that were used to run the survey. Oftentimes, this is done in service of further protecting the anonimity of participants. As far your analyses go, the end result is the same, but sometimes this can be a source of confusion.

<br>

Variance estimation in complex survey designs
---------------------------------------------

There are four common options for estimating variance in complex survey designs:

1.  Taylor series linearized estimates
2.  Balanced repeated replication (BRR) estimates
3.  Jackknife estimates
4.  Bootstrap estimates

Remember that these are all estimates: you cannot directly compute the variance of quantities of interest from complex surveys. Instead, you must use one of these techniques, with trade-offs for each. We'll be using a couple of datasets for this lesson:

-   *nhanes*, which is a health survey conducted using a complex survey design that comes with a variety of weights
-   *nmihs\_bs*, which is a survey of births that comes with bootstrap replicate weights

Let's start with the *nhanes* dataset from which we'd like to get average height weight and age for the US population. First, let's get the naive estimate:


***/ 
  
clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// load data from web, nhanes2f
webuse nhanes2f, clear

preserve

keep sampl stratid psuid

save nhanes2f_s, replace

restore
// naive mean
mean age height weight

/***
<br>

We can also take a look at the sampling design, particularly the designation of strata and *PSUs*:

***/

// explore survey design
tab stratid psuid

/***
It's important to remember that these are *analysis* PSUs and strata, not the exact ones that were used in the survey design itself. Essentially the original 
strata are reassigned names that allow for deidintification, and then psus are assigned within the strata. 

<br>

We can use the weights supplied with *nhanes* to get accurate estimates of the means, but the variance estimates will be off:

***/

// mean with probability weights
mean age height weight [pw = finalwgt] 

/***
<br>

`svyset` and `svy: <command>`
-----------------------------

To aid in the analysis of complex survey data, Stata has incorporated the `svyset` command and the `svy:` prefix, with its suite of commands. With `svyset`, you can set the *PSU* (and *SSU* and *TSU* if applicable), the weights, and the type of variance estimation along with the variance weights (if applicable). Once set, most Stata estimation commands such as `mean` can be combined with `svy:` in order to produce correct estimates.

<br>


***/

/***

Variance estimators
-------------------

### Taylor series linearized estimates

Taylor series linearized estimates are based on the general strategy of Taylor series estimation, which is used to linearize a non-linear function in order to describe the function in question. In this case, a Taylor series is used to approximate the function, and the variance of the result is the estimate of the variance.

The basic intuition behind a linearized estimate is that the variance in a complex survey will be a nonlinear function of the set of variances calculated within each stratum. We can calculate these, then use the first derivative of the function that would calculate the actual variance as a first order approximation of the actual variance. This works well enough in practice. To do this, you absolutely must have multiple *PSUs* in each stratum so you can calculate variance within each stratum.

This is the most common method and is used as the default by Stata. You must, however, have within-stratum variance among *PSUs* for this to work, which means that you must have at least two *PSUs* per stratum. This lonely PSU problem is common and difficult to deal with. We'll return the lonely PSU later.

To set up a dataset to use linearized estimates in Stata, we use the `svyset` command:

***/


// TAYLOR SERIES LINEARIZED ESTIMATES

// set survey characteristics with svyset
svyset psuid [pweight = finalwgt], strata(stratid)

/***
<br>

Now that we've set the data, every time we want estimates that reflect the sampling design, we use the `svy: <command>` format:

***/

// compute mean using svy pre-command and taylor series estimates
svy: mean age height weight

/***
<br>

As you can see, the parameter estimates (means) are exactly the same as using the weighted sample, but the standard errors are quite different: nearly twice as large for age, but actually smaller for weight.

<br>


***/

/***

### Balanced repeated replication (BRR) estimates

In a balanced repeated replication (BRR) design, the quantity of interests is estimated repeatedly by using half the sample at a time. In a survey which is designed with BRR in mind, each sampling stratum contains two *PSUs*. BRR proceeds by estimating the quantity of interest from one of the *PSUs* within each stratum. For *H* strata, 2<sup>*H*</sup> replications are done, and the variance of the quantity of interest across these strata forms the basis for the estimate.

BRR weights are usually supplied with a survey. These weights result in appropriate half samples being formed across strata. BRR weights should generally be used when the sample was designed with them in mind, and not elsewhere. This can be a serious complication when survey data are subset.

To get variance estimates using BRR in Stata, you either need to have a set of replicate weights set up or you need to create a set of balanced replicates yourself. If the data has BRR weights estimates can be obtained as follows:


***/

// BRR ESTIMATES

// load data from web, nhanes2brr
webuse nhanes2brr, clear

// svyset 
svyset [pw=finalwgt], brrweight(brr*) vce(brr)

// compute mean using svy pre-command and brr weights
svy: mean age height weight





/***
The `brrweight` option specified which variables constitute the brr weights, while the `vce` option says that variance should be calculated using the balanced repeated replication approach. 

***/


/***

It's helpful to take a look at how BRR weights are related to PSUs and strata

***/
merge 1:1 sampl using nhanes2f_s

order sampl finalwgt psu stratid brr*

//browse sampl finalwgt psuid stratid brr*


/***
### Jackknife estimates

The Jackknife is a general strategy for variance estimation, so named by Tukey because of its general usefulness. The strategy for creating a jackknifed estimate is to delete every observation save one, then estimate the quantity of interest. This is repeated for every single observation in the dataset. The variance of every estimate computed provides an estimate of the variance for the quantity of interest.

In a complex sample, this is done by *PSUs*, deleting each *PSU* one at a time and re-weighting the observations within the stratum, then calculating the parameter of interest. The variance of these parameters estimates is the within-stratum variance estimate. The within stratum variances calculated this way are then averaged across strata to give the final variance estimate.

The jackknife is best used when Taylor series estimation cannot be done, for instance in the case of lonely *PSUs*.
***/



// JACKNIFE ESTIMATES

// load data from web, nhanes2jknife
webuse nhanes2jknife, clear


/***

In Stata, the command is:

***/


// set svyset using jackknife weigts
svyset [pweight = finalwgt], jkrweight(jkw_*) vce(jackknife)

/***

<br>

Now we can compare the naive estimates with the `svyset` estimates:

***/

// compute naive means without jackknife weights
mean age weight height

// compute mean with jackknife weights
svy: mean age weight height

merge 1:1 sampl using nhanes2f_s

order sampl finalwgt psu stratid jkw_*

browse sampl finalwgt psuid stratid jkw_*

/***

### Bootstrap estimates

The bootstrap is a more general method than the jackknife. Bootstrapping involves repeatedly resampling within the sample itself and generating estimates of the quantity of interest. The variance of these replications (usually many, many replications) provides an estimate of the total variance. In NCES surveys, within stratum bootstrapping can be used, with the sum of the variances obtained used as an estimate of the population variance. Bootstrapping is an accurate, but computationally intense method of variance estimation.

As with the jackknife, bootstrapping must be accomplished by deleting each *PSU* within the stratum one at a time, re-weighting, calculating the estimate, than calculating the bootstrap variance estimate from the compiled samples.

***/


// BOOTSTRAP ESTIMATES

// load data from web, nmihs_bs 
webuse nmihs_bs, clear

// svyset 
svyset idnum [pweight = finwgt], vce(bootstrap) bsrweight(bsrw*)

// convert birth weight grams to lbs for the Americans
gen birthwgtlbs = birthwgt * 0.0022046

// compute naive mean birthweight
mean birthwgtlbs

// compute mean with svy bootstrap
svy: mean birthwgtlbs

/***


<br>

Lonely *PSUs*
-------------

The most common problem that students have with complex surveys is what is known as "lonely *PSUs*." When you subset the data, you may very well end up with a sample that does not have mutliple *PSUs* per stratum. There are several options for what do in this case:

-   Eliminate the offending data by dropping strata with singleton *PSUs*. This is a terrible idea.
-   Reassign the *PSU* to a neighboring stratum. This is okay, but you must have a reason why you're doing this.
-   Assign a variance to the stratum with a singleton *PSU*. This could be the average of the variance across the other strata. This process is also known as "scaling" and generally is okat, but you should take a look at how different this stratum is from the others before proceeding.

The svyset command includes three possible options for dealing with loney *PSUs*. Based on the above, I recommend you use the `singleunit(scaled)` command, but with caution and full knowledge of the implications for your estimates.

<br> <br>

Design Effects
------------------

Design effects are pretty old-school and shouldn't be used. That said, you
will see these used in some older articles. These were used because most statistical programming languages weren't able to compute variance estimates 
from complex surveys up until about 2010. As a patchwork solution, the 
survey provider would calculate standard errors for some commonly used estimates from some common variables and look at how much bigger they were than 
naive estimates. The ratio between these would be averaged and called a design effect. For instance, if standard errors from a Taylor series linearized estimate were on average 1.3 times as big as naive standard errors then the 
design effect was 1.3. Do not use this approach, for hopefully obvious reasons. 

***/

/***

## Using variance estimation from different surveys

***/

// Using ECLS



// Using ELS

use ../../data/plans.dta, clear

/* TS estimation */ 

svyset psu [pw=f1pnlwt],strata(strat_id)

mean bynels2m, over(byrace)

svy: mean bynels2m, over(byrace) 

use ../../data/plans.dta, clear

sample 50

svyset psu [pw=f1pnlwt],strata(strat_id)

svydes 

/* BRR estimates from HSLS*/

use ../../data/hsls_belong.dta, clear

renvars *, lower

svyset [pw=w1parent], brr(w1parent???) vce(brr)

prop x3hscompstat

svy: prop x3hscompstat

/* NHES */



// end file     
log close
exit

//ECLS Manual p. 7-11, 9-12, exhibit 9-2

// ELS Manual p. 81, 87 (BRR), https://nces.ed.gov/pubs2014/2014364.pdf

// HSLS Manual  https://nces.ed.gov/pubs2018/2018140.pdf 
