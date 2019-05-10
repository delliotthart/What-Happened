
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
source('lasso.R')

shinyUI(fluidPage(

  # Application title
  # Sidebar with a slider input for number of bins
      sliderInput('alpha',
                  'How agressively should we penalize the magnitude of coefficients?',
                  min = 0, max = 100, step = 1, value = 0,width= '100%'),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("lasso"), width = 'auto', height = 450
    )
))
