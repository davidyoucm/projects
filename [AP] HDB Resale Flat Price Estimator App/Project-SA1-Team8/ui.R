library(shinydashboard) 
library(leaflet)
library(shinycssloaders)
library(plotly)

header <- dashboardHeader(
  title = "HDB P.E.T"
)
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Advanced Price Estimate Tool", tabName = "dashboard", icon = icon("dollar-sign")),
    menuItem("2 Property Comparison", icon = icon("chart-bar"), tabName = "widgets"),
    menuItem("Information/How to Use", icon=icon("info-circle"), tabName = "info")
    
  )
)
body <- dashboardBody(
  
  tabItems(
    tabItem(tabName="info", column(width=12,box(width=12, 
            p(h2("Welcome!",align = "center")), p(h3("Advanced Price Estimate Tool Walkthrough",align = "center")), p("To use our price estimate tool, all you need to do is enter in the relevant data for your particular property of interest. You will find this panel on the left hand side of the page."), tags$img(src="part1.png",style="display: block; margin-left: auto; margin-right: auto;", height=500,width=295), p("The address field is optional and will not affect the price estimate!"),
                                                  p("Once we have filled in all the details we want, we can hit the 'calculate' button to load the outputs we want to see."), tags$img(src="part2.png",style="display: block; margin-left: auto; margin-right: auto;"), 
                                                  p("Once this is done, we are able to get a price estimate for this particular property. This is of course an approximation that has been achieved via linear regression, so we obtain an error equal to the standard error of the regression, which is roughly $30,000. Thus all fair price estimates are given within a range of $60,000."),
                                                  tags$img(src="part3.png",style="display: block; margin-left: auto; margin-right: auto;"), p("The price estimate also tells us how much more valuable our property is compared to all other HDB flats used in our sample, which allows us to estimate how expensive this property is relative to all Singapore HDB flats."), tags$img(src="part4.png",style="display: block; margin-left: auto; margin-right: auto;"),
                                                  p("Next, the user is likely to be interested in what the value of such a theoretical property would be across different HDB Towns of Singapore. So we have used a leaflet map to allow the user to visualise the relative difference in price estimates across all towns for the user's specified property."), tags$img(src="part5.png",style="display: block; margin-left: auto; margin-right: auto;"), p("If the user wants to get more detailed information about each HDB Town and its associated price estimate, they can simply click on each marker."), tags$img(src="part6.png",style="display: block; margin-left: auto; margin-right: auto;"),
                                                  p("If the user would instead like to compare how such a theoretical property's value compares to all Singapore HDB properties (in different towns), they may choose to switch the display type of the graph to 'Compare Price Estimate in Each Town With all Singapore HDB properties.'"), tags$img(src="part7.png",style="display: block; margin-left: auto; margin-right: auto;"),
                                                  p("This changes the fill colour of each marker to instead compare the price estimate of the theoretical property with all other Singapore HDB properties. A dark red circle means that the price for the theoretical property the user has entered in, for that particular HDB Town, is greater than 80% of all HDB flats in our data."), tags$img(src="part8.png",style="display: block; margin-left: auto; margin-right: auto;"),
                                                  p("If the user wants more detailed analysis on the Price estimate, and how it compares to the prices of other properties with the same number of bedrooms within the same HDB Town, they can simply look at the following graph located on the bottom left of the page."), tags$img(src="part9.png",style="display: block; margin-left: auto; margin-right: auto;"),
                                                  p("They may also change this graph to compare the price estimate of the property with all other properties in Singapore. This is useful for HDB investors or current HDB owners who want to compare their wealth to the rest of HDB owners in Singapore."), tags$img(src="part10.png",style="display: block; margin-left: auto; margin-right: auto;"),tags$img(src="part11.png",style="display: block; margin-left: auto; margin-right: auto;"),
                                                  p("Note that because of the large number of properties in the data, loading this graph may take some time."), p("We may even compare the price estimate with other Singapore properties that have the same number of bedrooms."),tags$img(src="part12.png",style="display: block; margin-left: auto; margin-right: auto;"),p("Finally, when the user is ready for some more detailed analysis and has found a particular address of a HDB block they're interested (e.g. Queenstown), they may choose to now enter in an address into the optional address field on the top left hand side of the page."),                                       
                                                  tags$img(src="part13.png",style="display: block; margin-left: auto; margin-right: auto;"), p("This will then provide user information on the distance from this address to nearby amenities and the number of amenities nearby in the following table located on the bottom right hand side of the tool."), tags$img(src="part14.png",style="display: block; margin-left: auto; margin-right: auto;"), 
                                                  p("Users have great functionality over this table, and can even add in an optional additional amenity, labelled as a work/POI, as they may be interested in the distance between this HDB and the address of another particular location such as their workplace. By default, this address is set to Changi Airport."),tags$img(src="part15.png",style="display: block; margin-left: auto; margin-right: auto;"), 
            tags$img(src="part16.png",style="display: block; margin-left: auto; margin-right: auto;"), p("Users can also adjust the cut off range for the calculation of nearby amenities by adjusting the slider input located here. For example, if we only want to see amenities located within 1000m of my address, we can update the slider as shown here."),  tags$img(src="part17.png",style="display: block; margin-left: auto; margin-right: auto;"),p("This will update the number of amenities that are within the cutoff range."),
                                                  p("Also note that this tool provides information on the amount of walking time between the inputted address and the nearest amenity. We approximate walking speed to be 5km/h."), p(h3("2 Property Comparison Tool Information",align = "center")), p("The two property comparison tool works much in the same way as the advanced price estimate tool, however, now we allow the user to simultaneously analyse price estimates of 2 properties and give the user 2 fields to enter house data in. The user can then analyse the convenience of the locations of 2 properties, how the value of properties in each HDB Town vary over time and the relative values of the two properties."),tags$img(src="part19.png",style="display: block; margin-left: auto; margin-right: auto;"),
                                                  p("We hope you find this app useful."))
    )),
    
    
    tabItem(tabName = "dashboard",
            fluidRow(
              column(width = 4,
                     
                     box(width = NULL, status = "warning",
                         uiOutput("routeSelect"),
                         p(
                           class = "text-muted",
                           paste("Please enter the information below. For instructions on how to use, please see the information tab."
                           )
                         ),
                         #textInput("town", "Town:", "Queenstown"),
                         selectInput("town", "HDB Town:", 
                                     choices=c('ANG MO KIO','BEDOK','BISHAN','BUKIT BATOK','BUKIT MERAH',
                                               'BUKIT PANJANG','BUKIT TIMAH','CENTRAL AREA','CHOA CHU KANG',
                                               'CLEMENTI','GEYLANG','HOUGANG','JURONG EAST','JURONG WEST',
                                               'KALLANG','MARINE PARADE','PASIR RIS','PUNGGOL','QUEENSTOWN',
                                               'SEMBAWANG','SENGKANG','SERANGOON','TAMPINES','TOA PAYOH','WOODLANDS','YISHUN'),
                                     selected= 'QUEENSTOWN'
                         ),
                         p(strong("(Optional) Address:")),
                         textInput("address", "Note the address does not affect the price calculation, It is used to improve information about nearby amenities",""),
                         sliderInput("floorarea", "Floor Area (Sqm):",  min = 30, max = 200, value =75),
                         sliderInput("bedroom", "Number of Bedrooms:", value=3, min = 2, max = 5),
                         sliderInput("remainingLease", "Remaining Lease (40-99yrs):", value=75, min = 40, max = 99),
                         sliderInput("floor", "Floor Level:", value=10, min = 1, max = 50),
                         p(strong("Range : ")),
                         sliderInput("range", "Cut Off For Calculation of Number of Nearby Amenities", value=5000, min = 0, max = 10000, step = 100),
                         textInput("waddress", "(Optional) Work Address/POI :", "Changi Airport"),
                         submitButton("Calculate")
                     ),
                     box(
                       width = NULL, status = "warning", height =515,
                       selectInput("comparison", "Comparison:", choices=c('Within HDB Town (Same Bedrooms)','All of Singapore (Same Bedrooms)', 'All of Singapore', "Within HDB Town"))
                       ,submitButton("Refresh"),
                       withSpinner(plotOutput("priceGraph", height = 385))
                       
                       
                       
                     )
                     
              ),
              column(width = 8,
                     box(width = NULL, status="warning", 
                         uiOutput("priceEstimate")
                     ),
                     box(width = NULL, status="success", p(h2(paste("Compare The Value of Similar Properties In Different HDB Towns"))), radioButtons("radio", "Choose Marker Fill Type", c("Relative Price Estimate of Each Town","Compare Price Estimate in Each Town With all Singapore HDB properties. ")),
                         withSpinner(leafletOutput("housemap",width = "100%", height = "600px")),
                         submitButton("Refresh")
                     ),
                     box(width = NULL, status="warning",
                         uiOutput("nearestAmendities")
                     )
                     
              ),
              
              box(width = 12, status="warning", p("Data retrieved from https://data.gov.sg/dataset/resale-flat-prices . Price estimate is based on a linear regression of the following form. (Price ~ FloorArea + Bedrooms + FloorLevel + Town + RemainingLease) "),
                  p("Created by, Mubin Kazi, Haiwen Chen, David You, Neo Kar Min & Alina Su"))
              
            )
    ),
    
    tabItem(tabName = "widgets",
            fluidRow(
              column(width = 3,
                     
                     box(width = NULL, status = "warning"
                         ,
                         p(
                           class = "text-muted",
                           h3("Please enter information for your FIRST property below.")
                           
                         ),
                         
                         selectInput("town2", "Town:", 
                                     choices=c('ANG MO KIO','BEDOK','BISHAN','BUKIT BATOK','BUKIT MERAH',
                                               'BUKIT PANJANG','BUKIT TIMAH','CENTRAL AREA','CHOA CHU KANG',
                                               'CLEMENTI','GEYLANG','HOUGANG','JURONG EAST','JURONG WEST',
                                               'KALLANG','MARINE PARADE','PASIR RIS','PUNGGOL','QUEENSTOWN',
                                               'SEMBAWANG','SENGKANG','SERANGOON','TAMPINES','TOA PAYOH','WOODLANDS','YISHUN'),
                                     selected= 'KALLANG'
                         ),
                         p(strong("(Optional) Address:")),
                         textInput("address2", "Note the address does not affect the price calculation, It is used to improve information about nearby amenities",""),
                         sliderInput("floorarea2", "Floor Area (Sqm):",  min = 30, max = 200, value =75),
                         sliderInput("bedroom2", "Number of Bedrooms:", value=3, min = 2, max = 5),
                         sliderInput("remainingLease2", "Remaining Lease (40-99yrs):", value=75, min = 40, max = 99),
                         sliderInput("floor2", "Floor Level:", value=10, min = 1, max = 50),
                         p(strong("Range : ")),
                         sliderInput("range2", "Cut Off For Calculation of Number of Nearby Amenities", value=5000, min = 0, max = 10000, step=100),
                         textInput("waddress2", "(Optional) Work Address/POI :", "Changi Airport"),
                         submitButton("Calculate")
                     )
                     
              ),
              column(width = 6,
                      
                      box(width = NULL, status = "success", p(h2(paste("Property Price Comparison"))), 
                          withSpinner(plotlyOutput("housemap2",width = "90%", height = "500px")), p(h2("Average HDB Value Of Each HDB Town Over Time")), withSpinner(plotlyOutput("trend", width = "100%", height="275px")), submitButton("Refresh")
                          
                      )
                      
              ),
              column(width = 3,
                     box(
                       width=NULL, status = "primary", p(h3("Please enter information for your SECOND property below.")),
                       selectInput("town3", "Town:", 
                                   choices=c('ANG MO KIO','BEDOK','BISHAN','BUKIT BATOK','BUKIT MERAH',
                                             'BUKIT PANJANG','BUKIT TIMAH','CENTRAL AREA','CHOA CHU KANG',
                                             'CLEMENTI','GEYLANG','HOUGANG','JURONG EAST','JURONG WEST',
                                             'KALLANG','MARINE PARADE','PASIR RIS','PUNGGOL','QUEENSTOWN',
                                             'SEMBAWANG','SENGKANG','SERANGOON','TAMPINES','TOA PAYOH','WOODLANDS','YISHUN'),
                                   selected= 'GEYLANG'
                       ),
                       p(strong("(Optional) Address of 2nd property")),
                       textInput("address3", "Compare distance to amenities with a 2nd property. Note, the address does not affect the price calculation",""),
                       sliderInput("floorarea3", "Floor Area (Sqm):",  min = 30, max = 200, value =75),
                       sliderInput("bedroom3", "Number of Bedrooms:", value=3, min = 2, max = 5),
                       sliderInput("remainingLease3", "Remaining Lease (40-99yrs):", value=75, min = 40, max = 99),
                       sliderInput("floor3", "Floor Level:", value=10, min = 1, max = 50),
                       p(strong("Range : ")),
                       sliderInput("range3", "Cut Off For Calculation of Number of Nearby Amenities", value=5000, min = 0, max = 10000, step=100),
                       textInput("waddress3", "(Optional) Work Address/POI :", "Changi Airport"),
                       submitButton("Calculate")
                       
                     ))
              
            ),
            fluidRow(column(width=6,
                            box(width = NULL, status="warning",uiOutput("priceEstimate2"),
                                uiOutput("nearestAmenities2")
                            )),
                     column(width=6,
                            box(width= NULL, status="primary", uiOutput("priceEstimate3"),
                                uiOutput("nearestAmenities3"))),
                     column(width=6, 
                            box( width = NULL, status = "warning", height =540,
                                 selectInput("comparison2", "Comparison:", choices=c('Within HDB Town (Same Bedrooms) ',  'All of Singapore (Same Bedrooms)', 'All of Singapore', "Within HDB Town"))
                                 ,submitButton("Refresh"),
                                 withSpinner(plotOutput("priceGraph2")))),
                     column(width=6,
                            box( width = NULL, status = "primary", height =540,
                                 selectInput("comparison3", "Comparison:", choices=c('Within HDB Town (Same Bedrooms)', 'All of Singapore (Same Bedrooms)', 'All of Singapore', "Within HDB Town"))
                                 ,submitButton("Refresh"),
                                 withSpinner(plotOutput("priceGraph3")))),
                     box(width = 12, p("Data retrieved from https://data.gov.sg/dataset/resale-flat-prices . Price estimate is based on a linear regression of the following form. (Price ~ FloorArea + Bedrooms + FloorLevel + Town + RemainingLease) "),
                         p("Created by, Mubin Kazi, Haiwen Chen, David You, Neo Kar Min & Alina Su")))
            
            )
            
            
            )
    )
                              
  
  
  


dashboardPage(
  header,
  sidebar,
  body
)
