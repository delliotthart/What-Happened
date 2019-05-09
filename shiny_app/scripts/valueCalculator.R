require('ggplot2')
require(dplyr)
require(tibble)
require(glmnet)

setwd("/Users/Jack/Dropbox/Senior\ Year/Big\ Data/Final\ Project")

demog <- read.csv(file="./merged_final.csv", header=TRUE, sep=",")
demog = as_tibble(demog)

demShare <- select(demog, dem_share_total)
demog <- select(demog, naturalized:med_hh_val)

valueCalculator <- function(alph, costlist) {
  #internal <- cv.glmnet(as.matrix(demog), as.matrix(demShare), 
  #               penalty.factor = costlist, family="gaussian")
  lasso <- cv.glmnet(as.matrix(demog), as.matrix(demShare), 
                   penalty.factor = costlist, lambda = c(0, alph), family="gaussian")
  betas <-as_tibble(as.data.frame(t(as.matrix(lasso[["glmnet.fit"]][["beta"]]))))
  betas <- betas[1,]
  names <- names(betas)
  betas <- as.data.frame(t(betas))
  plotable <-data.frame(traits = names, beta= betas$V1)
  plotable <- plotable %>% arrange(-beta) %>% filter(beta != 0)
  level_order <- as.character(plotable$traits)
  ggplot(plotable, aes(x = factor(traits, level = level_order), y = beta)) + 
    geom_col(fill="blue") + labs(x = "Traits", y = "Lasso Coefficient")
}

costs <- c(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)

valueCalculator(0.017, costs)





