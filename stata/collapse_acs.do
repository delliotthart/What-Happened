use "/Users/Dylan/Desktop/acs_00001.dta", clear

tostring countyfip, replace
tostring statefip, replace

egen county = concat(statefip countyfip)
// county = statefip + countyfip 
drop if county == 0					// keep only 
drop if age < 18					// adults
//drop if citizen == 5				// who are citizens

gen naturalized = (citizen == 2) 	// dummy for naturalized citizens
replace naturalized = . if citizen == . | if citizen == 0

gen non_citizen = (citizen > 2)
replace non_citizen = . if citizen == . | if citizen == 0

gen female = sex - 1
replace female = . if sex == . 


gen foodstamp = foodstmp - 1
replace foodstamp =. if foodstmp == . | foodstmp == 0


gen white = racwht - 1
gen black = racblk - 1
gen asian_pac_islander = racasian > 1 | racpacis > 1
gen indig = racamind - 1

gen multi_racial = racother - (white | black | asian_pac_islander | indig)

gen hispanic = (hispan > 0)
replace hispanic = . if hispan > 5

gen married = inlist(marst,1,2,3)
gen single = (marst == 6)

foreach v of varlist married single {
replace `v' = . if marst == .
}

gen foreign_born = (bpl <= 120)
replace foreign_born = . if bpl == . | bpl > 900 | bpl == 0

gen foreign_parent = (mbpl != 9900 | fbpl != 9900)
replace foreign_parent = . if (mbpl == .  | mbpl > 900 | mbpl == 0) ///
 & (fbpl == . | fbpl > 900 | fbpl == 0)

gen student = (school == 2) 
replace student = . if school == 0 | school > 2

//****************** DOUBLE CHECK THIS 
gen poverty = offpov == 1
replace poverty = . if offpov == . 
//****************** DOUBLE CHECK THIS 

gen veteran =  vetstat - 1
replace veteran = . if vetstat < 1 | vetstat > 2

gen unemp = empstat == 2
replace unemp = . if unemp == 0 | unemp == .

gen moved_last_year = migrate1 =! 1
replace moved_last_year = . if migrate1 == 0 | migrate1 == 9

gen indig_land = homeland - 1

replace farm = farm - 1
replace farm = . if farm == -1

gen multigen_hh = (multgen == 2 | multgen==3)
replace multigen_hh = . if multgen == 0 | multgen == .

gen col_degree = educd > 81 & educd != 90 & educd != 100
replace col_degree = . if educd == . | educd == 999 | educd < 001

gen less_than_hs = educd < 62
replace less_than_hs = . if educd == . | educd == 999 | educd < 001

gen grad = educd > 101
replace grad = . if educd == . | educd == 999 | educd < 001


di "DONE WITH MAKING VARIABLES"
 
collapse (mean) naturalized non_citizen female ///
	public_housing foodstamp age ///
	white black asian_pac_islander multi_racial indig hispanic ///
	married single ///
	foreign_born foreign_parent ///
	student veteran unemp moved_last_year ///
	col_degree less_than_hs grad ///
	indig_land farm grad ///
	(median) med_hhinc = hhincome med_age = age med_hh_val = valueh ///
[aw=wtfinl], ///
 by(year county)

export delimited using "/Users/Dylan/Desktop/county_data_alladults_ACS.csv", nolabel replace
