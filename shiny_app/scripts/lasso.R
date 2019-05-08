library('ggplot2')
library('dplyr')
library('tibble')
library('HDCI')

getwd()
#setwd("/Users/Jack/Dropbox/Senior\ Year/Big\ Data/Final\ Project")

demog <- read.csv(file="../data/merged_final.csv", header=TRUE, sep=",")
demog = as_tibble(demog)

demShare <- select(demog, dem_share_total)
demog <- select(demog, feature_list)

lassoGivenAlpha <- function(alpha) {
  results <- Lasso(as.matrix(demog), as.matrix(demShare), alpha)
  coefs <- data.frame(traits = c(colnames(demog)), beta= c(results[["beta"]]))
  coefs <- coefs %>% arrange(-beta) %>% filter(beta != 0)
  level_order <- as.character(coefs$traits)
  plot <- ggplot(coefs, aes(x = factor(traits, level = level_order), y = beta )) + 
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
  #print(plot)
  plot
}

#example for a single alpha:
#lassoGivenAlpha(.075)
#c(colnames(demog))



