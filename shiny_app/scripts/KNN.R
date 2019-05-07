library(FNN)
library(ggplot2)
library(readr)
display_KNN <- function(K, features, county_fips){
  
  election_data <- read_csv("../data/merged_final.csv")
  
  Training_X <- election_data[election_data$year != 2016,c(features)]
  #print(head(Training_X))
  Training_Y <- election_data[election_data$year != 2016,ncol(election_data)]
  #print(head(Training_Y))
  to_predict <- election_data[election_data$year == 2016,c(features)]
  #print(typeof(to_predict))
  eval_y <- election_data[election_data$year == 2016,ncol(election_data)]
  #print(head(eval_y))
  #head(to_predict)
  
  model <- knn.reg(data.frame(Training_X), test = data.frame(to_predict),
                   y= data.frame(Training_Y),k=K)
  
  fig <- qplot(eval_y$dem_two_party, model$pred) + geom_smooth() +theme_classic() + geom_abline(slope =1, intercept =0)
  #ggsave(filename="../output/r_test.png",plot = fig)
  
  fig
}


features <- c('med_hh_val','med_age')
K <- 5
county_fips <- 1003

display_KNN(K,features,county_fips)

