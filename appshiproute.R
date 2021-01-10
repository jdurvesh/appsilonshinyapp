
library(data.table)
library(DT)
library(dplyr)
library(tidyverse)
library(shiny)
library(leaflet)



data<-fread("shiny_calc_F.csv")

# Define UI for application that renders a map 

ui <- fluidPage(h1("Ship Route App"),
  sidebarLayout(
    sidebarPanel(width =3,
                 selectInput("ship_type", "Ship_Type", choices = unique(data$ship_type)),
                 selectInput("SHIPNAME", "Ship_Name", choices = NULL),
                 selectInput("DESTINATION", "Destination", choices = NULL)
    ),
    mainPanel(
      br(),
      h3("Below is Table of the  Consecutive Observations where maximum distance was covered."),
      br(),
      
      dataTableOutput('table'),
      hr(),
      br(),
      textOutput("text"),
      hr(),
      br(),
      
      h3("Below is Plot of distance between two observations "),
      leafletOutput("mymap")
    )
  )
  
)
# Define server logic to update UI and create dependent dropdowns,fiter observations and plot a map 
server <- function(session,input, output) {
  
  ship_type_r <- reactive({
    filter(data, ship_type == input$ship_type)
  })
  observeEvent(ship_type_r(), {
    choices <- unique(ship_type_r()$SHIPNAME)
    updateSelectInput(session, "SHIPNAME", choices = choices) 
  }) 
  
  shipname_r <- reactive({
    req(input$SHIPNAME)
    filter(ship_type_r(), SHIPNAME == input$SHIPNAME)
  })
  observeEvent(shipname_r(), {
    choices <- unique(shipname_r()$DESTINATION)
    updateSelectInput(session, "DESTINATION", choices = choices)
  })
  
  filter_table_r <- reactive({
    req(input$DESTINATION)
    shipname_r() %>% 
      filter(DESTINATION == input$DESTINATION) %>% 
      select(c("LAT", "LON","SPEED","DATETIME","ship_type","is_parked","Date_Tm_lag1_sec","Dist_mt","Dist_lag1_mt"
))
    
  })

  output$table <-renderDataTable({
    req(input$DESTINATION)
    filter_table_r()
    
  })
  
  output$mymap <- renderLeaflet({
    req(input$DESTINATION)
    map_ships<-m %>%
      leaflet(data=filter_table_r())%>%
      addTiles()%>%
      addMarkers()
    
    map_ships
    
  })
  
  output$text <- renderText({
    req(input$DESTINATION)
    paste("The Ship Selected is:", input$SHIPNAME,"of the type",input$ship_type,"moving towards the destination:",input$DESTINATION,"covered maximum distance of",filter_table_r()$Dist_lag1_mt
[2],"meters" )
  })
  
}

shinyApp(ui = ui, server = server)

