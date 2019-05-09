suppressWarnings(library(FNN))
suppressWarnings(library(ggplot2))
suppressWarnings(library(readr))
suppressWarnings(library(tidyverse))


feature_list <- c('naturalized', 'non_citizen', 'female', 'foodstamp',
                  'age', 'white', 'black', 'asian_pac_islander', 'multi_racial',
                  'indig', 'hispanic', 'married', 'single', 'foreign_born',
                  'student', 'veteran', 'moved_last_year', 'col_degree',
                  'less_than_hs', 'grad', 'indig_land', 'farm',
                  'med_hhinc', 'med_age', 'med_hh_val')

feature_names <- c('Naturalized Citizens', 'Non-Citizens',
                   'Female','Foodstamp','Age (Mean)', 'White', "Black",
                   'Asian-American/Pacific Islander','Multi-Racial','Indigenous',
                   'Hispanic','Married','Single','Foreign Born', 'Students',
                   'Veteran','Moved Last Year', 'College Degree',
                   'Less than High School','Graduate','Indigenous Sovereign Land',
                   'Farm Households','Income (Household)','Age (Median)','Home Value')
names(feature_list) <- feature_names



get_election_data <- function(){
  data <- read_csv("../data/merged_final.csv")
  outcomes <- data[,(ncol(data)-1):(ncol(data))]
  #print(outcomes)
  
  features <- data[,0:(ncol(data)-2)]
  #print(features)
  totals <- features %>%
    bind_rows(summarise_all(., funs(if(is.numeric(.)) sum(.) else "Total")))
  totals <<- (totals[nrow(totals),]
)
  
  data
}

display_KNN <- function(K, ft_names){
 
  
  features <- feature_list[c(ft_names)]
  print(features)
  Training_X <<- election_data[election_data$year != 2016,c(features)]
  #print(head(Training_X))
  Training_Y <<- election_data[election_data$year != 2016,ncol(election_data)]
  #print(head(Training_Y))
  to_predict <<- election_data[election_data$year == 2016,c(features)]
  #print(typeof(to_predict))
  eval_y <<- election_data[election_data$year == 2016,ncol(election_data)]
  #print(head(eval_y))
  #head(to_predict)
  
  model <- knn.reg(data.frame(Training_X), test = data.frame(to_predict),
                   y= data.frame(Training_Y),k=K)
  
  plot_data = data.frame('x'=eval_y$dem_two_party,'y'=model$pred)
  #print(plot_data)
  fig <- ggplot(plot_data,aes(x,y)) + geom_jitter(size = 2,alpha=.5) +
    geom_smooth() + xlab('Real Democratic Vote Share') + ylab('Predicted Democratic Vote Share') +
    theme_minimal() + theme(text = element_text(size=20)) +
    geom_abline(slope = 1,intercept = 0, 
                linetype='dashed', color = 'maroon', size = 1,aes(color='maroon',alpha='.4')) +
    ylim(low=0.125,high=1)

  ggsave(filename="../output/r_test.png",plot = fig)
  
  fig
}

display_neighbors_for_county <-function(K, ft_names, county_name, state_name, display_feature){
  #find the county of interest
  features <- feature_list[c(ft_names)]
  display_ft <- feature_list[display_feature]
  training_set <- election_data[election_data$year != 2016,c(features,'dem_two_party')]
  
  main_observation <<- election_data[election_data$year == 2016 &
                                     election_data$county == county_name &
                                     election_data$state == state_name,c(features,'dem_two_party')]
  neighbors <- get.knnx(data= training_set[,0:(ncol(training_set)-1)], k = K, query = main_observation[1,0:(ncol(main_observation)-1)])
  n_indices <- unlist(neighbors[1])
  
  model <- knn.reg(data.frame(training_set[,0:(ncol(training_set)-1)]), 
                   test = data.frame(main_observation[1,0:(ncol(main_observation)-1)]),
                   y= data.frame(training_set[,'dem_two_party'],k=K))
  plot_data <- data.frame('x'=training_set[n_indices,display_ft],'y'= training_set[n_indices,'dem_two_party'])
  #print(plot_data)
  fig2 <- ggplot(plot_data,aes(plot_data[[display_ft]],dem_two_party)) + geom_point(alpha=.7,size=2) +
    
    geom_point(aes(x= unlist(main_observation[1,display_ft]),
                   y= unlist(main_observation[1,'dem_two_party']),
                   color= "Real"),size = 2) +
    
    geom_point(aes(x= unlist(main_observation[1,display_ft]),
                   y= unlist(model$pred),
                   color= "Predicted"
                   ),size = 2,shape=17) +
                                               
    theme_minimal() + theme(text = element_text(size=20),
                            legend.position = 'bottom'
                            ) + 
    guides(size = FALSE,
           shape = FALSE,
           color=guide_legend(title=paste("Democratic Vote Share in", county_name))) +
  
    ylab('Democratic Vote Share') + xlab(display_feature)
  
  #ggsave(filename="../output/r_test.png",plot = fig2)
  fig2
}

get_counties_in_state <- function(state){
  counties = unique(election_data$county[election_data$year == 2016 & election_data$state == state])
  counties
}

suppressMessages(election_data <- get_election_data())
state_names <- unique(election_data$state[election_data$year == 2016])


#K <- 5
#county_fips <- 1003
#print(get_counties_in_state(state_name))
test_K <- 20
test_features <- c('Female','Age (Median)', 'Black')
test_state <- 'Alabama'
test_county <- 'Baldwin'
test_display <- 'Female'
#display_neighbors_for_county(test_K, test_features, test_county, test_state, test_display)
#is.numeric(unlist(election_data[1,1])[1])
#display_KNN(test_K,test_features)

