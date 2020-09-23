/***
LPO 9951: More Dataset Manipulation
===================================

<br>

#### PURPOSE

Today we'll continue to work on dataset manipulation. We'll focus on
more complicated merges as well as reshaping.

<br>

Downloading `ado` files, setting globals, and loading data
----------------------------------------------------------
***/



capture log close                       // closes any logs, should they be open
log using "more_dataset_manipulation.log", replace    // open new log



// NAME: More dataset manipulation
// FILE: lecture5_more_dataset_manipulation.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 17 September 2014
// LAST: 22 September 2020

clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// set globals for url data link and local data path
global urldata "https://stats.idre.ucla.edu/stat/stata/seminars/svy_stata_intro/apipop"


// required Ado Files: onewayplot, mdesc, mvpatterns
ssc install mdesc
ssc install onewayplot
net install dm91, from ("http://www.stata.com/stb/stb61")
   
   
    use $urldata, clear
	
	save api, replace
	
// create example datasets
preserve
collapse (mean) api99, by(cnum)
drawnorm county_inc, means(30) sds(5)
sort cnum
save county_data, replace
restore


preserve
collapse (mean) api99, by(dnum)
rename api99 api99c
gen edd = rbinomial(1,.3)
save district_data, replace
restore


/***
Many-to-one match merging
-------------------------

Many times we'd like to add information about a unit that is the same
across a grouping of units. For instance, we may want to add some county
data to our already existing school-level data. This really isn't much
different than the merging we've done before, except we need to make
certain that the variables are sorted correctly.

Let's say we have county level data that we'd like to import into our
school level dataset. Remember that we sorted the county data by the
county number (its unique id) when we created the dataset. We do the
same for the district data. Finally we merge the two together:
***/

// many-to-one match merging 

// sort to aid in merge
sort cnum

// merge many-to-one
merge m:1 cnum using county_data


// inspect many-to-one merge
tab _merge
list cnum api99 county_inc if _n < 10

// plot and save
onewayplot api99, by(county_inc) stack ms(oh) msize(*.1) width(1) name(api99_ow)
graph export ${plotdir}api99_ow.eps, name(api99_ow) replace


/***
#### Quick Exercise

Create a (fake) county level variable for average educational
spending. It should be normally distributed and have a mean of 8000
and a standard deviation of 1000. Add this variable to a county-level
dataset and merge this new dataset into the api dataset.
***/


/***

One-to-many match merging
-------------------------

One to many match merging is the reverse of many to one, and isn't
really recommended. If you have to, here's how to do it:

Let's say we have some district data on whether or not the principal has
an EdD. We can open this up and merge the api data with it, matching on
district number. It's generally better to have the *finer-grained*
dataset open in memory, and then to match the *coarser* data to that
one, doing a many-to-one match merge. But should you need to complete a
one-to-many match merge, here's an example:

***/

// one-to-many match merging: but why?

use api, clear

// sort to aid in merge
sort dnum

// save newly sorted dataset
save api, replace

// load example data
use district_data, clear

// sort to aid in merge
sort dnum

// merge one-to-many
merge 1:m dnum using api

// inspect one-to-many merge
tab _merge
list dnum api99 edd if _n < 10

/***
#### Quick Exercise

> Create a (fake) district level variable for average teacher salary. It
> should have a mean of 40 and a standard deviation of 5. Merge the api
> data into this dataset.

<br>
***/

/***

Many-to-many match merging
-------------------------

Nope.

***/

/***
Messy merge
-----------

Many merge procedures are quite messy. To simulate this, let's eliminate
a couple of variables from the `api` dataset and remove 10% of the
observations. We'll put this into a file we're pretending is the `api99`
file. Next, we'll drop some data from the `api00` file. Finally, we'll
merge the resulting two files together.
***/

// messy merge

use api, clear

preserve
drop api00 ell mobility
sample 90
save api_99, replace
restore

drop api99
sample 90
save api_00, replace

// merge datasets
merge snum using api_99, sort

// inspect messy merge
tab _merge

// code for looking at missing values, other patterns

// command: inspect
inspect api99
inspect api00

// command: mdesc
mdesc api99 api00

// command: mvpatterns
mvpatterns api99 api00 ell mobility

/***
These combined files are likely to have lots of missing data. Let's take
a look at some of the patterns of missing data. The first command to use
is called `inspect`. The results from the inspect command look like
this:
***/

/***
This gives you a nice quick glance at the variable in question. You can
also use the `mdesc` command, the output of which looks like this:
***/



/***

Why do we care so much about missing values? Because the missingness of
variable values is unlikely to be random across all observations.
Instead, observations with missing values for covariate *X* may have
different average values for covariate *Z* than those who don't have
missing values. These differences can greatly skew inferences we might
hope to make with our analyses, so it is important that we have an
understanding of the missingness of our data.

Later in the year we'll go over different approaches for dealing with missing data. For now it's important that we understand the prevalence of missing data and its relationship with other variables. 

Here is a graphical example of the differences in `api99` scores between
districts with `ell` data and those without:

***/


// create flag if missing ell
gen ell_flag = ell == .

// plot kernel density of api99 of observations missing ell
kdensity api99 if ell_flag == 1, ///
    name(api99_kdens) ///
    addplot(kdensity api99 if ell_flag == 0) ///
    legend(label(1 "Not Missing ELL")  label(2 "Missing ELL")) ///
    note("") ///
    title("")

graph export api99_kdens.eps, name(api99_kdens) replace

/***
#### Quick Exercise

> Create a new dataset by dropping the meals and emergency credentials
> variables. Eliminate half of the data. Next create another dataset,
> dropping the parental education variables, and again get rid of half
> of the data. Merge the remaining two datasets together, then describe
> the patterns of missing data.

<br>
***/

/***
Reshaping data
--------------

### Wide to long

The last major type of data manipulation is known as `reshaping`. Many
datasets have multiple observations per unit. One way to store this type
of data is in a wide format, meaning each additional observation is
another variable. Here's some data from the Bureau of Economic Analysis
on quarterly income growth that's in wide format:
***/

// reshaping: wide to long

// read in data and sort
insheet using income.csv, comma clear
sort fips

/***

We want to have this data in long format, meaning that there will be
multiple lines per unit, each one identifying a year and a quarter. The
command for this is `reshape long <stub>, i(<index>) j(<time var>)`. As
you can see after the command, each unit/year now has its own line, and
income is a single variable.


***/


// reshape long
reshape long inc_, i(fips) j(year_quarter, string)

// create date that stata understands
gen date = quarterly(year_quarter, "YQ")

// format date so we understand it
format date %tq

// list few rows
list if _n < 10

/***

We can now more easily set the date in a format Stata understands and
take advantage of graphing commands such as `xtline`:


***/


// organize data so we can graph it with xtline
xtset fips date, quarterly

// drop non-states
drop if fips < 1 | fips > 56

// graph
xtline inc_, i(areaname) t(date) name(xtline_fipsinc)
graph export ${plotdir}xtline_fipsinc.eps, name(xtline_fipsinc) replace


/***
### Long to wide

The reverse of the above is reshaping from long to wide. To shift the
above dataset back, use the same command, but substitute `wide` for
`long`:
***/

// reshaping: long to wide

// drop date that we added (no longer needed)
drop date

// long to wide
reshape wide inc_, i(fips) j(year_quarter, string)

// list first rows
list if _n < 4

/***
#### Quick Exercise

> Download data on personal per capita income from 1950 to the present for all
> 50 states from the [Bureau of Economic
> Analysis](http://www.bea.gov/regional/downloadzip.cfm). Create a plot
> using the `xtline` command.

<br> <br>
***/

// end file
log close                               // close log
exit                                    // exit script


