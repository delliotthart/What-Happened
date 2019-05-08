#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title

  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    fluidPage(  
      inputPanel(selectInput("state",
                  "Select State",
                  choices = state_names,
                  multiple = FALSE)
    
)),
    
    
    # Show a plot of the generated distribution
    mainPanel(print('Hi')
     #  plotOutput("neighbors")
    )
  )
))
