library(shiny)
library(dplyr)
library(tidyr)
library(readxl)
library(plotly)
library(sf)
library(tmap)
library(leaflet)
library(shinydashboard)


source('global.R', local = T)

ui2 <- dashboardPage(
  dashboardHeader(title = "Market Research Yogyakarta's HMOs",
                  titleWidth = 400),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Product", tabName = "product", icon = icon("home")),
      menuItem("Price", tabName = "price", icon = icon("dollar-sign")),
      menuItem("Place", tabName = "place", icon = icon("location-dot")),
      menuItem("Promotion", tabName = "promotion", icon = icon("rectangle-ad")),
      menuItem("About Me", tabName = "about-me", icon = icon("user"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    tabItems(
      tabItem(
        tabName = "product",
        includeMarkdown("www/ff.Rmd"),
        includeMarkdown("www/facilities.Rmd"),
        sidebarLayout(
          sidebarPanel(
            selectInput("facilchoice", "Facilities", choices = names_facil, multiple = T, selected = c("AC", "Fan", "WiFi", "Inside Bathrooms")),
            actionButton("btn","Click!"),
            HTML("<div class:note> <b>Note:</b> You can ommit any facilities by clicking the facilities and pressing <b>Backspace</b></div>")
          ),
          mainPanel(plotlyOutput("facilmean"))
        ),
        includeMarkdown("www/amenities.Rmd"),
        plotlyOutput("corr"),
        tags$br(),
        tags$p(tags$b("The next analysis will be done on the pricing of HMOs, click the price panel to continue the analysis"))
      ),
      tabItem(
        tabName = "price",
        includeMarkdown("www/characteristic_1.Rmd"),
        sidebarLayout(
          sidebarPanel(
            selectInput("chars", "Chose Charactersitics!", choices = chars, multiple = F)
          ),
          mainPanel(plotlyOutput("plotchars"))
        ),
        includeMarkdown("www/Characteristic_gender.Rmd"),
        includeMarkdown("www/characteristic_scatter.Rmd"),
        includeMarkdown("www/price_commitment.Rmd"),
        plotlyOutput("minmonth")
      ),
      tabItem(
        tabName = "place",
        includeMarkdown("www/place_opening.Rmd"),
        sidebarLayout(
          sidebarPanel(
            selectInput("near_uni", "Nearest Universities", choices = univs$`Nama PT`, multiple = T),
            selectInput("gender", "HMOs Gender", choices = as.factor(df$gender)%>% levels(), multiple = T),
            sliderInput("jarak", "Maximal distance from university (in metres)", min = 0, max = 5000, value = 1000),
            actionButton("button","Click!")
          ),
          mainPanel(tmapOutput("maps", width = "100%"))
        ),
        includeMarkdown("www/place_disttouni.Rmd"),
        sidebarLayout(
          sidebarPanel(
            selectInput("near_uni2","Nearest Universities", choices = univs$`Nama PT`, multiple = T, selected = univs$`Nama PT`),
            actionButton("btn2","click")
          ),
          mainPanel(plotlyOutput("scatterDist"))
        ),
        includeMarkdown("www/place_mvanalysis.Rmd")
      ),
      tabItem(
        tabName = "promotion",
        includeMarkdown("www/promotion_price.Rmd"),
        fluidRow(tags$image(class = "img-responsive center-block", src = "mamikos.png", style = "max-width: 600px;height:auto;")), 
        includeMarkdown("www/promotion_price2.Rmd"),
        plotlyOutput("scatterView"),
        includeMarkdown("www/promotion_facilities.Rmd"),
        plotlyOutput("vc"),
        includeMarkdown("www/promotion_limitation.Rmd")
      ),
      tabItem(
        tabName = "about-me",
        fluidRow(
          box(title = "About Me",
              status = "danger",
              width = "6 col-lg-4",
            tags$image(src = "aim.png", class = "center-block", style = "max-width: 250px;"),
            includeMarkdown("www/about_me.Rmd"),
            tags$div(
              icon("linkedin"),tags$a(href = "https://www.linkedin.com/in/wan-hasjim-53b623145", "LinkedIn" )
            ),
            tags$div(
              icon("github"), tags$a(href = "https://github.com/AimHasjim", "GitHub")
            )
          )
        )
      )
    )
  )
)



