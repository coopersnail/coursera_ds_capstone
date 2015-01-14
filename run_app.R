library(shiny)

# set working directory
# working directory should contain predict.R, server.R, and ui.R

runApp(display.mode='showcase')

# deploy app on RStudio ShinyApps.io
# devtools::install_github('rstudio/shinyapps')
library(shinyapps)
deployApp()
