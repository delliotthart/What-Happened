#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
source('KNN.R')

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  inputPanel(
    selectInput("features",
                "Select Features",
                choices = feature_names,
                selected = 'College Degree', multiple = TRUE),
    sliderInput('K',"Number of Neighbors",
                min = 5, max = 100, value = 20, step = 1)
  ),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("KNN"), width = 'auto', height= 450
    )
  )
)
