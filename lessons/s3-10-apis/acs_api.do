cap prog drop apicheck

cap rm "webfile.txt"

/*
https://www.census.gov/programs-surveys/acs/technical-documentation/summary-file-documentation.html

https://www.socialexplorer.com/data/ACS2007/metadata/?ds=ACS07&table=C15002

https://api.census.gov/data.html

&for=county:*&in=state:01

*/


program apicheck
    tempfile webfile
    copy "https://api.census.gov/data/2013/acs/acs1?get=NAME,C15002_001E,C15002_008E,C15002_016E&for=county:*&in=state:47" "webfile.txt"
    import delimited "webfile.txt", clear varnames(1) stripquotes(yes)
end

apicheck

replace name=substr(name,2,.)

