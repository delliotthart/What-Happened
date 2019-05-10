
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
source('KNN.R')
source('lasso.R')
source('valueCalculator.R')



shinyUI( 
  fluidPage(
    titlePanel('How expensive is it to collect data on... '),
  sidebarPanel(
    uiOutput("sliders1"), width = 2
  ),
  sidebarPanel(
    uiOutput("sliders2"), width = 2
  ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("lasso"), height = '100%'
    )
  
)
)


