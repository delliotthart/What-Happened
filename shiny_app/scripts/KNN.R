suppressWarnings(library(FNN))
suppressWarnings(library(ggplot2))
suppressWarnings(library(readr))

feature_list <- c('naturalized', 'non_citizen', 'female', 'foodstamp',
                  'age', 'white', 'black', 'asian_pac_islander', 'multi_racial',
                  'indig', 'hispanic', 'married', 'single', 'foreign_born',
                  'student', 'veteran', 'moved_last_year', 'col_degree',
                  'less_than_hs', 'grad', 'indig_land', 'farm',
                  'med_hhinc', 'med_age', 'med_hh_val')

feature_names <- c('Naturalized Citizens', 'Non-Citizens',
                   'Female','Foodstamp','Age (Mean)', 'White', "Black",
                   'Asian-American/Pacific Islander','Multi_Racial','Indigenous',
                   'Hispanic','Married','Single','Foreign Born', 'Students',
                   'Veteran','Moved Last Year', 'College Degree',
                   'Less than High School','Graduate','Indigenous Sovereign Land',
                   'Farm Households','Income (Household)','Age (Median)','Home Value')

get_election_data <- function(){
  data <- read_csv("../data/merged_final.csv")
  data
}

display_KNN <- function(K, ft_names){
 
  names(feature_list) <- feature_names
  
  features <- feature_list[c(ft_names)]
  print(features)
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
  plot_data = data.frame('x'=eval_y$dem_two_party,'y'=model$pred)
  #print(plot_data)
  fig <- ggplot(plot_data,aes(x,y)) + geom_jitter(size = 2,alpha=.5) +
    geom_smooth() + xlab('Real Democratic Vote Share') + ylab('Predicted Democratic Vote Share') +
    theme_minimal() + theme(text = element_text(size=20))
    geom_abline(slope = 1,intercept = 0, linetype='dashed', color = 'maroon', size = 1,aes(color='maroon',alpha='.4'))

  #ggsave(filename="../output/r_test.png",plot = fig)
  
  fig
}

display_neighbors_for_county <-function(K, ft_names, county_name, state_name){
  #find the county of interest
}

get_counties_in_state <- function(state){
  counties = unique(election_data$county[election_data$year == 2016 & election_data$state == state])
  counties
}

suppressMessages(election_data <- get_election_data())
state_names <- unique(election_data$state[election_data$year == 2016])


#features <- c('Home Value','Age (Median)')
#K <- 5
#county_fips <- 1003
test_state <- 'Alabama'
#print(get_counties_in_state(state_name))
#display_KNN(election_data_full,K,features)
