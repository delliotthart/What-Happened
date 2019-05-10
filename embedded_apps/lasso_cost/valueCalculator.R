require('ggplot2')
require(dplyr)
require(tibble)
require(glmnet)


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
  fig3 <- ggplot(plotable, aes(x = factor(traits, level = level_order), y = beta )) + 
    geom_col(aes(fill=factor(traits, level = level_order))) + labs(x = "Traits", y = "Lasso Coefficient") +
    theme_minimal() + 
    guides(fill = guide_legend(title = 'Trait',
                               ncol =  4,
                               byrow = TRUE))+
    theme(text = element_text(size=20),
          axis.title.x=element_blank(),
          axis.text.x=element_blank(),
          axis.ticks.x=element_blank(),
          legend.position = 'bottom')
  print(fig3)
}

costs <- c(1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)
names(costs) <- feature_names
valueCalculator(0.017, costs)





