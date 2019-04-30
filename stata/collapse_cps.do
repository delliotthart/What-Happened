use "/Users/Dylan/Desktop/cps_00012.dta", clear
drop if county == 0					// keep only 
drop if age < 18					// adults
//drop if citizen == 5				// who are citizens

gen naturalized = (citizen == 4) 	// dummy for naturalized citizens
replace naturalized = . if citizen == . 

gen non_citizen = (citizen == 5)
replace non_citizen = . if citizen == . 

gen female = sex - 1
replace female = . if sex == . 

gen public_housing = pubhous - 1
replace public_housing = . if pubhous == 0

gen foodstamp = foodstmp - 1
replace foodstamp =. if foodstmp == .

gen bank_acct = (bunbanked == 1) 
replace bank_acct = . if bunbanked > 90


gen white = (race == 100) 
gen black = (race == 200) 
gen asian_pac_islander = (inlist(race,650,651,652)) 
gen multi_racial = 1-(inlist(race,100,200,300,651,652))

foreach v of varlist white black asian_pac_islander multi_racial {
replace `v' = . if race == .
}


gen hispanic = (hispan != 0)
replace hispanic = . if hispan > 900

gen married = inlist(marst,1,2,3)
gen single = (marst == 6)

foreach v of varlist married single {
replace `v' = . if marst == .
}

gen foreign_born = (bpl != 9900)
replace foreign_born = . if bpl == .

gen foreign_parent = (mbpl != 9900 | fbpl != 9900)
replace foreign_parent = . if mbpl == . & fbpl == .

gen student = (schlcoll < 5 | edatt == 1 |  edpupr < 900 | edfull < 99) 
replace student = . if schlcoll == 0 

gen poverty = offpov == 1
replace poverty = . if offpov == . 

gen medicare_aid = himcaid * himcare
replace medicare_aid = (medicare_aid > 1)
replace medicare_aid = . if himcaid == . & himcaid == .

gen veteran =  vetlast != 1
replace veteran = . if vetlast == 0 | vetlast == .

replace gotwic = gotwic - 1
replace gotwic = . if gotwic < 0

gen boycott =  ceboycott == 2
replace boycott = . if ceboycott > 2 | ceboycott == .

gen relig_org =  ceorgrelig == 2
replace relig_org = . if ceorgrelig > 2 | ceorgrelig == .

gen fam_din_daily = cefamdinnr == 6
replace fam_din_daily = . if cefamdinnr > 90 | cefamdinnr == .

gen internet_in_home = cinethh - 1
replace internet_in_home = . if cinethh > 90

di "DONE WITH MAKING VARIABLES"
 
collapse (mean) naturalized non_citizen female ///
	public_housing foodstamp bank_acct age ///
	white black asian_pac_islander multi_racial hispanic ///
	married single ///
	foreign_born foreign_parent ///
	student poverty medicare_aid gotwic ///
	boycott relig_org fam_din_daily ///
	(median) med_hhinc = hhincome med_age = age ///
[aw=wtfinl], ///
 by(year county)

export delimited using "/Users/Dylan/Desktop/county_data_alladults.csv", nolabel replace
