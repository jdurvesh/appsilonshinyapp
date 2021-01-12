library(DT)
library(data.table)
library(dplyr)
library(tidyverse)
library(shiny)
library(leaflet)

#####  Importing the file 
setwd("C:\\Users\\Disha\\Desktop\\ShinyProject\\shiprouteapp")
data<-fread("shiny_calc_F.csv")

DependentDropdownUI <- function(id) {
  tagList(
    selectInput(NS(id,"ship_type"), "Ship_Type", choices = unique(data$ship_type)),
    selectInput(NS(id,"SHIPNAME"), "Ship_Name", choices = NULL),
    selectInput(NS(id,"dESTINATION"), "Destination", choices = NULL)
  )
}

DependentDropdownServer <- function(id) {
  
    moduleServer(id, function(input, output, session) {
    
    
    
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
      updateSelectInput(session, "dESTINATION", choices = choices)
    })
    
    return(list( x= shipname_r,
                 y =reactive(input$dESTINATION),
                 z = reactive(input$ship_type),
                 z1 = reactive(input$SHIPNAME)))
  }
  )
  
}


DropdownApp <- function() {
  ui <- fluidPage(
    DependentDropdownUI("DD"),
    tableOutput("table"),
    textOutput("text"),
    leafletOutput("mymap")
    
    
  )
  server <- function(input, output, session) {
    

    
    d1<-DependentDropdownServer("DD")
    
    
    filter_table_r <- reactive({
    
    d1$x() %>% 
    filter(DESTINATION == d1$y()) %>% 
    select(c("LAT", "LON","SPEED","DATETIME","ship_type","is_parked","Date_Tm_lag1_sec","Dist_mt","Dist_lag1_mt"
    ))
    })
    
    output$table <-renderTable({
      
      
     filter_table_r()
    })
    
    output$mymap <- renderLeaflet({
      
      
      map_ships<-
        leaflet(data=filter_table_r())%>%
        addTiles()%>%
        addMarkers()
      
      map_ships
      
    })
    
    output$text <- renderText({
      req(d1$y())
      paste("The Ship Selected is:",d1$z1(),"of the type",d1$z(),"moving towards the destination:",input$DESTINATION,"covered maximum distance of",filter_table_r()$Dist_lag1_mt
            [2],"meters" )
    })
    
  
  }
  
  shinyApp(ui, server)  
  
}

DropdownApp()
