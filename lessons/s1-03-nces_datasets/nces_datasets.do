/***
Working with NCES Datasets
=====

Will Doyle
=====

2021-09-08
=====

Intro
------

In this lesson we'll go over how to access and work with various NCES datasets 
in Stata. I diverge from the intended use from NCES, as there's a simpler 
way to get access to the data than the one that they lay out. 

***/
capture log close

log using "nces_datasets.log", replace


/***
Directory Structure
-----------

Data files (particularly large ones) should be stored in their own 
subdirectories. While it's possible to simply dump everything in one 
big directory, you may find that over time, as the folder grows, 
it becomes very difficult to find what you need and almost impossible 
to share your work with others. Yes, your computer can search really well. 
An organized directory structure is for you, the human. 
Get into the habit now, and you'll be thankful later.
***/


/***
Creating Directory Structures
---------------

In programming, we many times need to move around in directories on a
computer. Sometimes we use fixed paths, which specify exactly where something is
on the computer, other times we use relative paths. An example of a fixed path 
would be something like:

___`/Users/doylewr/lpo_prac/lessons/s1-03-nces_datasets`___

That path specifies the exact directory on my computer. In general, you really
should avoid fixed paths, because everyone's computer is different. However,
you might have something like a clone of a GitHub repository on your computer. 
Within that repository, you can specify relative paths to clarify where you
want the program to look. A standard directory structure for a statistical
programming project is something like this:

___`project_directory/

		----data/
		
			-----source/
			
			-----analysis/
			
		----scripts/
		
		----output/
		
			-----tables/
			
			-----graphics/
			
		----paper`___

Since our code exists in the ./scripts directory, to access the source 
data names source_data.dta we would need to go up one level to the main 
project directory and then down into the source data directory. 
The command for this in Stata would be: 

___`use ../data/source/source_data.dta`___		

The ___`../`___ means to go up one level. Using ___`./`___ means to go into a subdirectory, 
or down one level. 

In my github repository, I store large data files in the data directory. To
access that directory from the current lesson 
I need to go up two levels and then into the data directory, so the relative
path is: ___`../../data/`___. 


***/



/***
Working with globals
---------------
We're going to set the structure for ourselves using global macros. In Stata,
a macro is a variable that can be set to some value. There are two types of 
macros in Stata-- global and local. A global macro is persistent during a 
session (when Stata is open). A local macro is forgotten as soon as a script
(do file) is run. In general, I will encourage you to use local macros, as their
use enables better programming practices and replication. However, using 
global macros is a good idea for data management. 

First we tell Stata what a macro will represent:

***/

global ddir "../../data/"

/***
What the above means is that every time I call that macro, Stata will know I
means the directory in question. We can test this by asking Stata to display the
global ...
***/

display "$ddir"

exit 


/***
... and there you have it. 

One big takeaway from all of this is that you should *never* include a `cd` statement in
a do file that references a specific spot on your computer. Either don't include a cd command at all, 
or include a cd command that makes use of a relative directory strucure. The easiest (but not necessarialy the best) way to do this is to assume that the do file and the data file are in the same directory. 

I'm also going to get the information for my current directory so I can easily return to it.

***/

global cdir `c(pwd)'

di "$cdir"


/***
Working with HSLS

The high school longitudinal study of 2009 tracks a set of students who began 
high school in 2009. It has been updated in 2012 and again in 2016.  It's a 
great source of information about how students navigate high school and make 
the transition to college or the workforce (and in many cases both).

HSLS can be accessed using the nces electronic codebook: 
https://nces.ed.gov/OnlineCodebook Once variables 
have been selected from the codebook, they can be accessed using the
 ___`use`___ . . .___`using`___
approach below:
***/

use  ///
	STU_ID ///
	X1SES ///
	using "${ddir}hsls_17_student_pets_sr_v1_0.dta", ///
	clear

save "${ddir}hsls_analysis.dta",replace

/***
Working with NHES
------------------
The National Household Education Survey collects data on the education 
activities of children and adults in the United States. The NHES has varying 
emphases in different years. 

Because of the different emphases, NHES will include different data files in 
each year. It's important to know which data file a given variable comes from.
Below, I open up the early childhood program data file and extract a few 
variables regarding the child's participation in early childhood programs. 

***/

use ///
BASMID ///
CPNNOWX ///
CPTYPE ///
CPHRS ///
using "${ddir}nhes_16_ecpp_v1_0.dta", clear 

renvars *, lower

save "${ddir}nhes_analsyis.dta", replace


/***
Working with ECLS 2011
-------------------

[ECLS 2011](https://nces.ed.gov/ecls/kindergarten2011.asp) uses a nationally represntative sample of students 
that were in kindergarten as of 2011. This study is excellent for tracking younger students as they progress through
early grades. 

ECLS is a bit different in that NCES doesn't have any equivalent of the online codebook for it. Instead we have to navigate it using some other tools. 

NCES provides a do file, a dictionary file, and a data file (zipped) for ECLS 2011. The code below assumes that you have downloaded the zip file `ChildK5p.zip` from [the ECLS data products website](https://nces.ed.gov/ecls/dataproducts.asp). 




***/

clear

// Look to see if file exists
capture confirm file "${ddir}ChildK5p.zip"
//If it doesn't then go ahead and download it a
if _rc==601 {
	copy https://nces.ed.gov/ecls/data/2019/ChildK5p.zip "${ddir}ChildK5p.zip"
}

capture confirm file "${ddir}childK5p.dat"
//If it doesn't then go ahead and download it a
if _rc==601 {
	unzipfile ChildK5p.zip
}

	

// Check for ancillary files locally

//Do file

capture confirm file "${ddir}ECLSK2011_K5PUF.do"
//If it doesn't then go ahead and download it. 
if _rc==601 {
	copy https://nces.ed.gov/ecls/data/2019/ECLSK2011_K5PUF.do ${ddir}ECLSK2011_K5PUF.do
}

// Dictionary file: located in same directory as data


capture confirm file "${ddir}ECLSK2011_K5PUF.dct"
//If it doesn't then go ahead and download it. 
if _rc==601 {
	copy https://nces.ed.gov/ecls/data/2019/ECLSK2011_K5PUF.do "${ddir}ECLSK2011_K5PUF.dct"
}

//Check for stata data file if it doesn't exist use the two do fies to create it. 
// THE DO FILE MUST BE ADJUSTED FOR THE DIRECTORY STRUCTURE USED. 

//set maxvar 32767 , permanently /* Stata SE max */

capture confirm file "${ddir}ECLSK2011_K5PUF.dta"
if _rc==601{
cd $ddir
do ECLSK2011_K5PUF.do
cd $cdir
}

use   ///
 CHILDID ///
 X9SESL_I ///
 X9INCCAT_I ///
 using "${ddir}ECLSK2011_K5PUF.dta", clear
 
renvars *, lower


save "${ddir}ecls_analsyis.dta", replace


exit 

/*** 
PISA Datasets
-------------

The program for international assessment of student learning includes teacher 
and student questionnaires, as well as school-level data. It includes data 
from a large number of countries, many times with regional data broken down 
as well. The data is only available in SAS and SPSS format. Below I show how to
access an SPSS file. Here I'm accessing math reading and science scores from the
 cognitive file, just for three countries: USA, Japan, France

***/

import spss ///	
CNT ///
PV1MATH ///
PV1SCIE ///
PV1READ ///
if CNT=="JPN" | CNT=="FRA" | CNT=="USA" ///
using "${ddir}CY07_MSU_STU_QQQ.sav", ///
case(lower) clear

save "${ddir}pisa_analysis.dta", replace

/***
In-Class Work
--------------

Using the online codebook, download the ELS student data and create an
analysis dataset that includes variables for student SES, Race, parental 
education and cumulative educational attainment (from the 3rd follow 
up).

If you have time, calculate the average SES of students by educational attainment in the third followup. Then calculate the proportion of students whose parents have at least a bachelor's degree at each level of educational attainment. 

See if you can create a bar graph that summarizes
the patterns you observe. 

***/




exit

