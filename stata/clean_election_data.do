**********
// Clean county-level election data
**********

clear all
set more off

import delimited "./countypres_2000-2016.csv", encoding(ISO-8859-1)

drop if totalvotes == "NA"
drop if candidatevotes == "NA"
destring candidatevotes, replace force
destring totalvotes , replace force
drop if fips == "NA"
drop version

gen dem_share_total = candidatevotes / totalvotes if party == "democrat"
gen dem_temp = candidatevotes if party == "democrat"
gen rep_temp = candidatevotes if party == "republican"
bys fips year: egen dem_votes = max(dem_temp)
bys fips year: egen rep_votes =  max(rep_temp)
drop *temp

gen two_party_votes = dem_votes + rep_votes
gen dem_two_party = candidatevotes / two_party_votes if party == "democrat"

drop if party != "democrat"
keep year fips dem_share_total dem_two_party totalvotes state county

replace fips = "0" + fips

export delimited using "election_data_clean.csv", replace
