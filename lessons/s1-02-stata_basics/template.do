capture log close                           // closes any logs, should they be open
log using "<name_of_log_file>.log", replace // open new log

// NAME: <human readable title>
// FILE: <actual_file_name.do>
// AUTH: <author of file>
// INIT: <date file created>
// LAST: <date of last change>

clear all                      // clear memory
set more off                   // turn off annoying "__more__" feature

// CONTENT...











// end file
log close                               // close log
exit                                    // exit script
