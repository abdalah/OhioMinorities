library(shiny)
library(rgdal)
library(RColorBrewer)
library(leaflet)
library(tigris)
library(magrittr)
load("shinyData.RData")

shinyServer(function(input, output, session) {
  
  output$mymap <- renderLeaflet({
    if(input$type!=0){
      sub <- subset(new, appl == input$type,)
      subpop <- paste0("<p><b>", sub$CTYNAME, "</b>",
                       "<br><br><u>Demographics for ages 12-25</u>",
                       "<br><em>Population: </em>",
                       prettyNum(sub$total_popn,big.mark=",",scientific=FALSE),
                       "<br><em>Number of Minority Individuals: </em>", 
                       prettyNum(sub$total_minority_popn,big.mark=",",scientific=FALSE), 
                       "<br><em>Percent of Minorities in Population: </em>",
                       round(sub$pct_minority_popn, 2),"%",
                       "<br><br><u>Demographics for Entire Population</u>",
                       "<br><em>Total Population: </em>", 
                       prettyNum(sub$TOT_POP,big.mark=",",scientific=FALSE),
                       "<br><em>Percent of Minorities in Population: </em>",
                       round(sub$PCTMINOR, 2),"%</p>")
      
      subplc <- subset(plc, appl == input$type,)
      
      subcitypop <- paste0("<p><b>", subplc$NAME, "</b>",
                           "<br><em>Total Population: </em>",
                           prettyNum(subplc$HD01_VD01,big.mark=",",scientific=FALSE),
                           "<br><em>Percent of Minorities in Population: </em>",
                           round(subplc$percMinority, 2), "%</p>")
      pal <- colorBin("Blues", domain = sub$pct_minority_popn, )
      
      return(
        leaflet(sub) %>%
          addTiles() %>%
          addPolygons(stroke = F, 
                      fillOpacity = .8, 
                      smoothFactor = 1,
                      color=~pal(pct_minority_popn), 
                      popup = subpop) %>%
          addCircleMarkers(data = subplc, ~INTPTLONG, ~INTPTLAT,
                           radius = subplc$percMinority/2.5, 
                           color = "navy", 
                           stroke = F, fillOpacity = .8,
                           popup = subcitypop) %>%
          addLegend("bottomright", pal = pal, values = ~pct_minority_popn, title = "Minority Population <br>(by percent of total)", opacity = 1)
      )
    } else{
      pal <- colorBin("Blues", domain = new$pct_minority_popn, )
      return(
        leaflet(new) %>%
          addTiles() %>%
          addPolygons(stroke = F,
                      fillOpacity = .8,
                      smoothFactor = 1,
                      color=~pal(pct_minority_popn),
                      popup = countypop) %>%
          addCircleMarkers(data = plc, ~INTPTLONG, ~INTPTLAT,
                           popup = citypop,
                           radius = plc$percMinority/2.5,
                           color = "navy",
                           stroke = F, fillOpacity = .8) %>%
          addLegend("bottomright", pal = pal, values = ~pct_minority_popn, title = "Minority Population <br>(by percent of total)", opacity = 1)
      )
    }
  })
  
  output$table <- renderDataTable(
    dataInput()
  )
  
  output$table2 <- renderDataTable(
    placedataInput()
  )
  
  dataInput <- function(){
    if(input$type2!=0){
      table <- subset(tabledata, appl == input$type2,)
      return(table[c(-21, -22)])
    } else{return(tabledata[c(c(-21, -22), -22)])}
  }
  
  placedataInput <- function(){
    if(input$type3!=0 | !is.null(input$counts)){
      if(input$type3 != 0){
        table <- subset(placeTable, appl == input$type3,)
        if(!is.null(input$counts)){return(subset(table[-13], County%in% input$counts, ))}
      }
      else{return(subset(placeTable[-13], County %in% input$counts, ))}
      return(table[-13])
    } else{return(placeTable[-13])}
  }
  
  output$downloadData <- downloadHandler(
    filename = function(){
      if(input$type2 == 0){
        ty <- "All"
      } else if(input$type2 == 1){
        ty = "Appalachian"
      } else{ty="Rural"}
      paste(choose.files(), ty, 'OhioMinorityDataByCounty.csv', sep='')
    },
    content = function(file) {
      write.csv(dataInput(), file)
    }
  )
  
  output$downloadPlaces  <-  downloadHandler(
    filename = function() {
      if(input$type3 == 0){
        ty <- "All"
      } else if(input$type3 == 1){
        ty = "Appalachian"
      } else{ty="Rural"}
      paste(ty, 'OhioMinorityDataByPlace.csv', sep='') 
    },
    content = function(file) {
      write.csv(placedataInput(), file)
    }
  )
  
  output$top <- renderTable(top)
  
  output$bot <- renderTable(bot)
  
  output$myBlockmap <- renderLeaflet({
    cnty <- tabledata[tabledata$County == input$counts2,]$COUNTYFP
    dat <- subset(block, COUNTYFP10==cnty & minority_pop >= input$daslider,)
    
    BLOCKpal <- colorBin("Blues", domain = dat$pct_minority)
    
    subpop <- paste0("<p><b>Block: ", dat@data$BLOCK, "</b>",
                     "<br><em>Population: </em>",
                     prettyNum((dat$`Total White Alone`+dat$minority_pop),big.mark=",",scientific=FALSE),
                     "<br><em>Number of Minority Individuals: </em>", 
                     prettyNum(dat$minority_pop,big.mark=",",scientific=FALSE), 
                     "<br><em>Percent of Minorities in Population: </em>",
                     round(dat$pct_minority, 2),"%</P>")
    
    return(leaflet(dat) %>%
      addTiles() %>%
      addPolygons(stroke = T,
                  fillOpacity = .5,
                  smoothFactor = 3,
                  color=~BLOCKpal(pct_minority), popup=subpop) %>%
      addLegend("bottomright", pal=BLOCKpal, values = ~pct_minority, title = "Minority Population <br>(by percent of total)", opacity = 1))
  })
  
})