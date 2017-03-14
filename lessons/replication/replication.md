Vanderbilt University\
Leadership, Policy and Organizations\
Class Number 9952\
Spring 2017\

****

There is no single commonly accepted standard for creating a replication
file in the social sciences , although there are a variety of efforts
underway to create such a standard. To see the American Economic
Review’s standards, click [here](http://www.aeaweb.org/aer/data.phpl).
You can find a wide collection of replication papers
[here](http://replication.uni-goettingen.de/wiki/index.php/Main_Page).
For a more radical reconsideration of the way that science can be done,
check out the Open Science Framework [here](https://osf.io/).

In the absence of such a standard, I offer a set of guiding principles,
and a concrete description of a useful replication file.

Guiding Principles
------------------

My guiding principles for replication are the following:

-   Openness: All of the steps taken to get to the final result are
    detailed, without any omissions.

-   Transparency: Data are clearly labeled and it’s easy to translate
    from the results reported to the data itself. Assumptions, fudges,
    etc, are noted.

-   Ease of use: the person wishing to utilize the information does not
    have to go through a number of extra steps to replicate
    your results.

-   Progress-oriented: the goal should not be the protection of the
    individual’s results, the goal should be the progress of science.

Contents of a Replication Archive
---------------------------------

-   Every replication file should include a “readme” document, helpfully
    entitled “readme.” The document should be in a platform neutral
    format, such as plaintext or pdf. This should contain a description
    of all of the other files, including instructions on how to use the
    files included. For instance, if your do file was written in STATA
    or SAS or R,, this is the place to note that.

-   *All* of the data used to create the results reported in your
    analysis should be included. There are limits to this due to
    privacy considerations. In this case, you need to include a detailed
    description of how to obtain the data. If the data are proprietary
    or highly confidential, you must provide your standards for saying
    so here.

-   All of the programs used to analyze the data should be included. The
    syntax or programs used should include every step you took to get
    from the raw data to your results. These should be heavily
    annotated, and should note the places in the code that generate the
    results in your tables and figures. Better code will generate the
    tables exactly as they appear in the finished document—this has
    benefits beyond replication.

-   Any supplementary information mentioned but not reported in the
    paper should also be included in the archive. A better replication
    file includes nicely formatted tables and graphics that are easy
    to read.

-   You should also give some thought to where the archive file will
    be stored. Old-school single websites are giving way to
    comprehensive databases such as [dataverse](http://thedata.org/).

Today in class we’ll use a [replication
file](http://dvn.iq.harvard.edu/dvn/dv/JAngrist/faces/study/StudyPage.xhtml?studyId=23329&studyListingIndex=3_3c63cc35f4b84ab6961d972ebda5)
from Josh Angrist to get a sense of what’s most helpful in a replication
file.
