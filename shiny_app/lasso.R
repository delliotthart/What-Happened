require('ggplot2')
require(dplyr)
require(tibble)
require(HDCI)

getwd()
setwd("/Users/Jack/Dropbox/Senior\ Year/Big\ Data/Final\ Project")

demog <- read.csv(file="./merged_final.csv", header=TRUE, sep=",")
demog = as_tibble(demog)

demShare <- select(demog, dem_share_total)
demog <- select(demog, naturalized:med_hh_val)

lassoGivenAlpha <- function(alpha) {
  results <- Lasso(as.matrix(demog), as.matrix(demShare), alpha)
  coefs <- data.frame(traits = c(colnames(demog)), beta= c(results[["beta"]]))
  coefs <- coefs %>% arrange(-beta) %>% filter(beta != 0)
  level_order <- as.character(coefs$traits)
  ggplot(coefs, aes(x = factor(traits, level = level_order), y = beta)) + 
    geom_col(fill="blue") + labs(x = "Traits", y = "Lasso Coefficient")
}

#example for a single alpha:
lassoGivenAlpha(0.017)




