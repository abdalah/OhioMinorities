library(shiny)
library(rgdal)
library(RColorBrewer)
library(leaflet)
library(tigris)
library(magrittr)
load("shinyData.RData")

shinyUI(fluidPage(
  tabsetPanel("tabs",
              tabPanel("Home",
                       h3("Minority populations in Ohio by County and Place"),
                       HTML("<p>This choropleth map and related data tables describe the percentage of Ohio's population that belongs to race and ethnicity groups in all 88 counties as well as nearly 200 places in Ohio.
                            <br>The county map in the second tab indicates the percentage of non-white individuals between 12 and 25 years old. Clicking on a county will reveal more detailed information about that Ohio county's minority population.
                            <br>Each blue dot on the map indicates a place in which 10 percent or more of the total population for all ages falls into a minority group.
<br>The block-level map in the third tab displays the percentage of minority individuals between 10 and 24 years old. The slider in the sidebar panel allows one to subset the map to display only blocks with a designated minimum population of minority individuals. 
<br>Notice that the data at the county, place and block levels consists of different age ranges. This is because the data were pulled from different resources online, thus limiting the map creators' ability to use consistent age groups. 
                            <br>In the last two tabs, one can view the raw data at the county and place levels, subset it by county or Rural and Appalachian indicators, and download the data.</p>")    ,
                       h4("Top Five Counties with Highest Minority Percentage"),
                       tableOutput("top"),
                       h4("Top Five Counties with Lowest Minority Percentage"),
                       tableOutput("bot"),
                       
                       HTML("<p><br>The tabs for county and place level data tables provide more detailed information for each county or place. Statistics for counties were pulled from the U.S. Census Bureau's annual <a href = 'http://www.cdc.gov/nchs/nvss/bridged_race/data_documentation.htm#vintage2014'>Bridged-Race Postcensal Population Estimates,</a> which contain estimates of the resident population of the U.S. as of April 1, 2010 to July 1, 2014, based on the 2010 census. Statistics for places were pulled from the American Community Survey's <a href = 'http://www.census.gov/acs/www/data/data-tables-and-tools/data-profiles/'>five-year estimates</a> of places in Ohio for all ages from 2009 to 2013. Statistics for blocks were pulled from the Inter-university Consortium for Political and Social Research's (ICPSR) data on <a href = 'https://www.icpsr.umich.edu/icpsrweb/ICPSR/studies/33461?q=icpsr+33461&searchSource=icpsr-landing'>Census of Population and Housing for 2010</a>, which contains estimates based on answers to the 2010 Census questionaire.
                            <br>This visualization was created by Abdalah El-Barrad and Danielle Keeton-Olsen for the Ohio Department of Mental Health and Addiction Services to gain a detailed understanding of teenage and young adult population throughout the state of Ohio.
                            </p>")
              ),
              tabPanel("County Map",
                       titlePanel("Minority Population in Ohio's Counties"),
                       sidebarPanel(
                         radioButtons("type", "Subset By", choices=list("All"=0, "Appalachian"=1, "Rural"=2), selected = 0),
                         p("This map displays the distribution of minority individuals for each county's population between 12 and 25 years old. Each county is colored by the percentage of minority individuals in that designated age group. Each marker then designates cities and townships where 10 percent or more of the total population (all ages) falls into a minority category. The size of each bubble indicates the ratio of minorities in that place. Click on a county or a place marker for more information.")
                       ),
                       mainPanel(leafletOutput("mymap", height = "700px"))
              ),
              tabPanel("Block Map",
                       titlePanel("Minority Population in Ohio's Neighborhoods"),
                       sidebarPanel(
                         HTML("<p>This map displays the total number of individuals who are 10 to 24 years old in each Census block, according to the 2010 Census. Click on any block to see the area's total 10 to 24-year-old population, as well as the percentage of the population which falls into one or more minority groups. Due to data issues, the shinyapps version only shows blocks with total populations over 25.
                              <br>Cuyahoga County, the county with the greatest minority population, displays automatically. Select any county from the dropdown menu to view it in detail. The slider allows one to subset the blocks to display only if they have a designated minimum minority population.</p>"),
                         sliderInput("daslider", "Minimum Size of Minority Population (Age 10-24)", min = 0, max = 50, value = 0),
                         selectInput("counts2", "Select a County", choices=levels(All), selected="Cuyahoga County")
                         ),
                       
                       mainPanel(leafletOutput("myBlockmap", height = "700px"))
              ),
              tabPanel("County Level Data Table",
                       sidebarPanel(
                         radioButtons("type2", "Subset By", choices=list("All"=0, "Appalachian"=1, "Rural"=2), selected = 0),
                         HTML("<p><strong>Legend for Table's Race/Ethnicity Indicators</strong>
                           <br>NH = Non-Hispanic
                           <br>H = Hispanic
                           <br>Black/AA = Black/African American
                           <br>AI/AN = American Indian/Alaska Native
                           <br>Asian/PI = Asian/Pacific Islander</p>"),
                         downloadButton('downloadData', "Download")
                       ),
                       mainPanel(
                         HTML("<center><h4><strong>Population Data for Ages 12-25</strong></h4></center>"),
                         dataTableOutput("table")
                       )
              ),
              tabPanel("Place Level Data Table",
                       sidebarPanel(
                         radioButtons("type3", "Subset By", choices=list("All"=0, "Appalachian"=1, "Rural"=2), selected = 0),
                         HTML("<p><strong>Legend for Table's Race/Ethnicity Indicators</strong>
                           <br>H = Hispanic
                           <br>Black/AA = Black/African American
                           <br>AI/AN = American Indian/Alaska Native
                           <br>NH/PI = Native Hawaiian/Other Pacific Islander</p>"),
                         downloadButton('downloadPlaces', "Download"),
                         conditionalPanel(condition = 'input.type3 == 0',
                                          selectizeInput("counts", "Filter By Counties", choices=levels(All), multiple=T)
                         ),
                         conditionalPanel(condition = 'input.type3 == 1',
                                          selectizeInput("counts", "Filter By Counties", choices=levels(appalachian), multiple=T)
                         ),
                         conditionalPanel(condition = 'input.type3 == 2',
                                          selectizeInput("counts", "Filter By Counties", choices=levels(rural), multiple=T)
                         )
                         
                       ),
                       mainPanel(
                         HTML("<center><h4><strong>Racial Demographics Data for Total Population</strong></h4></center>"),
                         dataTableOutput("table2")
                       )
              )
  )
))