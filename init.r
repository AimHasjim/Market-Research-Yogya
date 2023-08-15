my_packages <- c("tidyverse", "readxl","plotly","sf","shiny","shinydashboard","tmap","leaflet")

install_if_missing <- function(p){
  if (p %in% rownmes(installed.packages()) == F) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))