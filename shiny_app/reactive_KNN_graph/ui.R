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
      inputPanel(
        sliderInput('K',"Number of Neighbors",
                             min = 5, max = 100, value = 20, step = 1),
        selectInput("state",
                  "Select State",
                  choices = state_names,
                  multiple = FALSE),
      uiOutput('county_selector'),
      selectInput("features",
                  "Select Features",
                  choices = feature_names,
                  selected = 'College Degree', multiple = TRUE),
      uiOutput('display_feature_selector')
      
      )),
    
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("neighbors"),  titlePanel("How Well Do These Features Do Across All Counties?"), 
       #textOutput('message'),
plotOutput("full_model") , width = "auto", height = 900
     )
  )
  ))

