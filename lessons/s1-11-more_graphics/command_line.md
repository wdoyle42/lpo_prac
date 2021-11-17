## Working with the command line: helpful bash and github commands


## Bash

Bash is a command line interface to your computer's operating system. It's available in os X as terminal, and in windows as powershell. Working with the CLI can be MUCH faster than with the GUI in certain circumstances. Here are some basic commands I use all the time

*Change Directory*

`cd `

This works on the same principle we discussed at the beginning of the year, with one directory up being `cd ../` and the current directory being `cd ./` and going into a current directory, say `data` being `cd ./data/`

*List files*

`ls `

I use `ls` in combination with the string matching function `grep` all the time. Let's say I want to find all the do files in a directory. I'll combine ls with grep using the pipe `|`:

`ls | grep do`

*Delete files *

`rm`

`rm` can be used in combination with wildcards, so let's say I want to remove all csv files:

`rm *.csv`

Be careful! Command lines come with fewer guardrails

*Move files*

`mv`

*Copy files*

`cp`

## Git commands

When in a git directory, I use the following commands all the time:

`git add <newfile>` : This "stages" the file I want to push to github

`git add .` This adds every file in the current directory to the list of files staged

`git commit -m "<git> commit message"` This commits the changes made to the file or files just added

`git pull` This pulls down any changes from the repository. I always run this before a push.

`git push` This pushes my changes to the online repository

Less commonly, I'll need to use the following commands:

`git clone <url>` clones the repo from github to my local directory

`git status .` Gives me the status of files in the current directory

`git stash` Stashes changes I've made (but not committed), ususally because of a conflict with files I'm pulling

`git revert HEAD-1` Goes back one commit, losing changes I made in the most recent commit. Again used when I might have some conflicts with pulled files

`git rm` remove a file from staging

I'll also edit the `.gitignore` file, which accepts bash style wildcards. For example, I might create a `.gitignore` file that doesn't track csv files

`
*.csv
`

