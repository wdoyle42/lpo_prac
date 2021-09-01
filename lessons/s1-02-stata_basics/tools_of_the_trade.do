capture log close

// Working with Git/Github, markdoc and pandoc
// Will Doyle
// 2021-09-01



/***
## Intro

This week we're going to get started with severa of the tools of the trade that we'll be using all year. The ideas I'm implementing here have been used by many analysts in the social sciences, but were captured best by Gentzkow and Shapiro in [Code and Data for the Social Sciences: A Practitioner's Guide'](https://web.stanford.edu/~gentzkow/research/CodeAndData.pdf). If you want to know why we're doing what we're doing this is an excellent resource. 


***/



/***

## Command Line

Having access to command line tools is very important when doing any kind of development. If you're on a Mac, the `terminal` program is used for command line interface with the computer. The best tool for a Windows computer is powershell. We'll start out by making sure everyone has these. 


***/

/***
## Version Control

Version control is the general term for software that tracks changes in code (or other documents) and has resources for reverting or merging in changes. One of the most popular forms of version control is Git. We're going to start by using Github Desktop, but later we'll switch to interfacing with git and github via the command line. 

You'll need to sign up for a github account at (https://github.com/). 

Then you'll want to [download github desktop](https://desktop.github.com/).

The first thing I want you to do is to create a clone of our class directory. Go to (https://github.com/wdoyle42/lpo_prac), copy the url, then  go to File--> Clone directory, then click the "URL" tab, and paste in the URL. 

At a minimum, before every class you'll want to sync your directory with my changes. 

Next, I want you to create a private repository that contains your work for this class. To do this, start in github by creating a repository, and in the repository, create a brief readme that states that this is the working directory for your practicum course. Next, add me (wdoyle42) as a collaborator on this repostiory. Clone this repostiory to your computer, create a directory for assignments, and then create a do file in the assignments directory named 02-assignment.do. Commit and push this empty do file to the repository. I'll double check that I have access to it. 
 

***/



/***
## Markdoc

Markdoc is a literate programming package for Stata. [Literate programming](http://www.literateprogramming.com/) is a (pretty old) idea that has been VERY slow to catch on among social scientists, but means combining our writing and our code into a single document.

To install markdoc, go to Stata and first install the `github` package:

net install github, from("https://haghish.github.io/github/")

Next, install the markdoc package:

`github install haghish/markdoc, stable`
  
***/


/***

## Pandoc

To take full advantage of markdoc, we need two additional tools: pandoc, and a Latex installation. Pandoc is a univeral document translator. Download it here: (https://github.com/jgm/pandoc/releases/tag/2.14.2). Once you've downloaded it and installed it, you can check on the installation in your terminal using

`pandoc --version`

***/


/***

## Latex

Latex is a typesetting program that has a huge number of useful features for technical writing. We won't author documents in latex for this class, but we will use its functionality. To download Latex, go here: (https://www.latex-project.org/get/)


***/

/***
## Helpful template and workfolow ideas

[From Matt Ingram](http://mattingram.net/teaching/workshops/workflowstata/mytemplatelatexmacros.pdf)

***/


/***
##  Running your first markdoc documents

Create another directory for lessons in your github repository. Copy today's lesson into that directory. In Stata, run 

`markdoc tools_of_the_trade.do, export(md)`

This will create a markdown document. [Markdown](https://daringfireball.net/projects/markdown/) is a simple syntax for generating html, and it serves as a great "source" language for a variety of typesetting programs, including Latex and Word. 

***/ 



clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

log using "tools_of_the_trade.log", replace
  
// downloading ado files

net search renvars 

// load in school vote data 

webuse school, clear

save school, replace

// outsheet dataset

outsheet using "school_data.csv", comma replace

// insheet dataset

insheet using "school_data.csv", comma clear

// describe data

//Save as tab delimited

outsheet using "school_data.tsv", replace

//Open up tab delimited file

insheet using "school_data.tsv", clear

describe

// labeling data 

label data "Voting on school expenditures"

// labeling variables 

label variable loginc "Log of income"

label variable vote "Voted for public school funding"

// describe again

describe
 
// labeling values within variables 

tab vote

label define voteopts 0 "no" 1 "yes"

label values vote voteopts

tab vote

// transforming variables 

gen inc = exp(loginc)

sum loginc inc

// recoding variables
sum inc

gen inc_bin = 0

replace inc_bin = 1 if inc > r(mean)

egen inc_q = cut(inc), group(4)

recode inc_q (0 = 1 "First Quartile") ///
    (1 = 2 "2nd Quartile") ///
    (2 = 3 "3rd Quartile") ///
    (3 = 4 "4th Quartile"), gen(new_inc_q)
	
	
// compute new variable

gen ptax = exp(logptax)

gen taxrate = ptax / inc

// end file
log close                               // close log
exit                                    // exit script
