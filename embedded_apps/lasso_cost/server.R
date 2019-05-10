
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
selected_features<- c('Single','Graduate','Female','Naturalized Citzens','Home Value','White',"Foreign Born",'Married')

shinyServer(function(input, output) {
  
  output$sliders1 <- renderUI({
    
  lapply(selected_features[5:8], function(i) {
    sliderInput(inputId = paste0("cost", i), label = paste0('Cost to Measure "', i,'"'),
                min = 0, max = 10, value = 5, step = 1)
    })
  })
  output$sliders2 <- renderUI({
    
    lapply(selected_features[1:4], function(i) {
      sliderInput(inputId = paste0("cost", i), label = paste0('Cost to Measure "', i,'"'),
                  min = 0, max = 10, value = 5, step = 1)
    })
  })
  
  
  output$lasso <- renderPlot({
    costs <- sapply(feature_names, function(i){
      if (any(i == selected_features)){
        costs[i] <- input[[paste0("cost", i)]]
      } else {
        costs[i] <- 5
      }
    })
    
    valueCalculator(0.015, costs)
    


  })
})
