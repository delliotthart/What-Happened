#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
function(input, output) {
  
  output$county_selector <- renderUI({
    counties <- get_counties_in_state(input$state)
    selectInput("county",
                "Select county",
                choices = counties,
                multiple = FALSE)
  })
  
  output$display_feature_selector <- renderUI({
    ft_options <- input$features
    selectInput("display_feature",
                "Select Feature to Display",
                choices = ft_options,
                multiple = FALSE)
  })

  output$neighbors <- renderPlot({
    display_neighbors_for_county(input$K,input$features,input$county, input$state, input$display_feature)
    })
  
  output$full_model <- renderPlot({
    display_KNN(input$K,input$features)
  })
  
  output$message <- renderText({
    attributes_used <- c()
    for (i in 1:length(input$features)){
      attributes_used <- c(attributes_used,input$features[i])
      if (i < length(input$features)){
        attributes_used <- c(attributes_used,', and')
      }
    }
    attributes_used <- paste0(attributes_used)
    attributes_used <- str_c(attributes_used)
    
    print(attributes_used)
    paste('Modeling the 2016 Election by looking at the ', input$K, 
          " counties most similar in terms of ", attributes_used)
  })
}
  
