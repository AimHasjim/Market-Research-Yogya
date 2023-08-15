#### gatthering Data
setwd("E:/R/Rshiny/Proto")

######### Servers########

server2 <- function(input, output){
  #### Reactive 
  
  
  ### Product - Faclities
  plot_eks <- eventReactive(input$btn,{df %>% select(unlist(input$facilchoice), price_monthly) %>% pivot_longer(names_to = "Facilities", values_to = "Availability",cols = unlist(input$facilchoice)) %>% group_by(Facilities, Availability) %>% summarise(`Average Price` = mean(price_monthly)) })
  output$facilmean <- renderPlotly(plot_ly( plot_eks(), x = ~Facilities, y=~`Average Price`, color = ~Availability) %>% layout(title = "Comparisons of Average Prices Between Facilities", legend = list(title=list(text='Facility available?')))) 
  
  ### Product - Amenities
  output$corr <- plot_ly(data = cmdf, x = ~Amenities, y = ~Correlation, type = "bar") %>% layout(title = "Correlation Between Number of Amenities and Rent Price") %>% renderPlotly()
  
  ### Price - Characteristics
  plot_chars <- reactive({df %>% select(unlist(input$chars), price_monthly)})
  chars <- reactive({input$chars})
  preds_size <- reactive({data.frame(x = df['size'], y_hat = predict(lm(data = df, formula = price_monthly~size), df['size']))})
  preds_age <- reactive({data.frame(x = df['Building Age'], y_hat = predict(lm(data = df, formula = price_monthly~`Building Age`), df['Building Age']))})
  output$plotchars <- renderPlotly(
    if (chars() == "gender"){
      plot_ly(plot_chars(), x = ~gender, y = ~price_monthly, type = "box") %>% plotly::layout(title = "Distribution of Rent Price Based of Gender",yaxis = list(title = "Monthly Rent Price"))
    } else if (chars() == "Building Age") {
      plot_ly(plot_chars(), x = ~`Building Age`, y = ~price_monthly, type = "scatter", name = "Scatter Plot") %>% add_trace(data = preds_age(), x = ~`Building.Age`, y = ~y_hat, mode = "lines", name = "Trendline") %>% layout(title = "Relatioship Between Age and Rent",yaxis = list(title = "Monthly Rent Price"))
    } else{
      plot_ly(plot_chars(), x = ~size, y = ~price_monthly, type = "scatter", name = "Scatter Plot") %>% add_trace(data = preds_size(), x = ~size, y = ~y_hat, mode = "lines", name = "Trendline") %>% layout(title = "Relationship Between Room Size and Rent",yaxis = list(title = "Monthly Rent Price"))
    }

  )
  
  ### Price- Commitment Pricing
  committed <- reactive(df %>% select(min_month, price_monthly) %>% group_by(min_month) %>% summarise(`Average Price` = mean(price_monthly)))
  output$minmonth <- renderPlotly(plot_ly(committed(),x = ~min_month, y = ~`Average Price`, type = "bar") %>% layout(title = "Comparison of The Average Rent by Time Commitment",xaxis = list(title = "Minimum Time Commitment"),
                                                                                                                      yaxis = list(title = "Average Monthly Rent")))  
  
  ### Place - Map
  maps <- eventReactive(input$button,{df  %>% filter(nearest_univ %in% input$near_uni & gender %in% input$gender & min_dist_univ < input$jarak) %>%select(latitude, longitude, name_slug, nearest_univ, price_monthly, gender, min_dist_univ, cruc_facil) %>% st_as_sf( 
    coords = c('longitude', 'latitude'),
    crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")
  })
  univ <- eventReactive(input$button, univs %>% filter(`Nama PT` %in% input$near_uni ) %>% select(`Nama PT`, latitude, longitude) %>%st_as_sf(coords = c('longitude', 'latitude'),crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
  output$maps <- renderTmap(tm_shape(yogya_peta)+ tm_borders()+ tm_shape(maps()) + tm_symbols(col = 'nearest_univ', legend.col.show = F ,scale = .05, popup.vars = c("Nearest university " = "nearest_univ", 
                                                                                                                                                                     "Monthly rent" = "price_monthly",
                                                                                                                                                                     "HMO gender" = "gender",
                                                                                                                                                                     "distance to university (m)" = "min_dist_univ",
                                                                                                                                                                     "Facilities" = "cruc_facil"), popup.format = list(min_dist_univ = list(digits = 0))) +tm_shape(univ())+ tm_symbols(col = 'Nama PT', scale = .2))
  ### Place - Distance to University
  univ_dist <- eventReactive(input$btn2,{df %>% filter(nearest_univ %in% unlist(input$near_uni2) & min_dist_univ<15000)})
  preds_dist <- eventReactive(input$btn2, {
    df1 <- df %>% filter(nearest_univ %in% unlist(input$near_uni2) & min_dist_univ<15000)
    data.frame(x = df1['min_dist_univ'], y_hat = predict(lm(data = df1, formula = price_monthly~min_dist_univ), df1['min_dist_univ']))
  })
  output$scatterDist <- renderPlotly(plot_ly(univ_dist(), x = ~min_dist_univ, y=~price_monthly, type = "scatter", name = "Scatterplot") %>% 
                                       add_trace(data = preds_dist(), x = ~min_dist_univ, y = ~y_hat, mode = "lines", name = "Trendline")%>% layout(title = "Relationship Between Distance and Rent",
                                                                                                                                                    xaxis = list(title = "Distance to Nearest University (Metres)"),
                                                                                                                                                      yaxis = list(title = "Monthly Rent Price"))) 
  
  ### Promotion - Price
  vc <- reactive(df %>% select(view_count, price_monthly, all_of(char_vc)))
  vc2 <- reactive({vc() %>% pivot_longer(names_to = "Facilities", values_to = "Availability", cols = char_vc) %>% 
      group_by(Facilities, Availability) %>% summarise(`Average Views` = mean(view_count, na.rm = T))})
  output$scatterView <- renderPlotly(plot_ly(vc(),y=~view_count, x=~price_monthly, type = "scatter")%>% layout(title = "Relationship Between View Count and Price",xaxis = list(title = "Monthly Rent Price"),
                                                                                                                 yaxis = list(title = "View Count"))) 

  ### Promotion - Facilities
  output$vc <- renderPlotly(plot_ly(vc2(), x=~Facilities, y=~`Average Views`, color = ~Availability, type = "bar") %>% layout(title = "Comparison of View Counts by The Availability of Facilities"))
  
  }


