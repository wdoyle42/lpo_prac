use ../data/plans_b, clear

preserve

keep bystexp bynels2m bynels2r

bysort bystexp: outreg2 using table.doc, replace sum(log) eqkeep(mean) sideway

restore
