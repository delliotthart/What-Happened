ds <county>,not
collapse (mean) `r(varlist)', by(<county>)
