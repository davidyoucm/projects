library(shinydashboard)
library(leaflet)
library(shiny)
library(curl) # make the jsonlite suggested dependency explicit
library(geosphere)
library(ggmap)
register_google("AIzaSyAXGjdqxP4C-E35RBfQC2YpSVhCH653m88")
library(scales)
library(tidyverse)
library(rvest)
library(RCurl)
library(curl)
library(jsonlite) 
library(XML)
library(broom)
library(plotly)
library(dplyr)
#install.packages('shinycssloaders')
library(shinycssloaders)
options(scipen=100000000)


hdb_housing_data <- read.csv('hdb_final_with_num.csv') 
hdb_housing_data$town <- as.factor(hdb_housing_data$town)
hdb_housing_data$flat_model <- as.factor(hdb_housing_data$flat_model)
hdb_housing_data$bedrooms <- as.numeric(hdb_housing_data$bedrooms)
#table(hdb_housing_data$bedrooms)
hdb_housing_data <- hdb_housing_data %>% mutate(age = 2020-lease_commence_date)
head(hdb_housing_data)
hdb_housing_data<- hdb_housing_data[-16]
x <- hdb_housing_data %>% group_by(town) %>% summarise(mean(bedrooms))
#hdb_housing_data
towns <- as.character(x$town)
#hdb_housing_data
#names(hdb_housing_data) <- c("town", "flat_type", "flat_model", "floor_area_sqm", "street_name", "resale_price", "Year", "Month", "remaining_lease", "lease_commence_date", "Min_Storey", "Max_Storey", "_id", "block", "Planning_area", "Future_stations", "No_stations", "No_Future_stations", "Total_stations", "Operational_stations", "bedrooms", "years_remaining", "Floor", "Age")  #Rename columns for readibility
hdb_housing_data$No_stations <- as.factor(hdb_housing_data$No_stations)
price_estimate <- lm(resale_price~town+floor_area_sqm+years_remaining+Floor+bedrooms,hdb_housing_data) 
myCDs <- rev(sort(cooks.distance(price_estimate)))
#summary(myCDs)
#names(myCDs)
#plot(price_estimate, pch =18, col = "red", which=c(4))
influential <- as.numeric(names(myCDs)[(myCDs > 0.00001)])
res <- hdb_housing_data[-influential,]
#hdb_housing_data
#res
price_estimate <- lm(resale_price~town+floor_area_sqm+years_remaining+Floor+bedrooms,res)
price_estimate2 <- lm(resale_price~town+floor_area_sqm+years_remaining+Floor+bedrooms+num,res)
price_estimate.res <- resid(price_estimate)

regression <- tidy(price_estimate)
Av_Price <- hdb_housing_data %>% group_by(town) %>% summarise(mean=mean(resale_price))
#Av_Price$mean <- as.character(Av_Price$mean)
Av_Price$mean <- paste0('$',formatC(Av_Price$mean,digits=2,big.mark=',',format='f'))
hdb_price_estimate <- function(town, areas, years, level, bedrooms) {
  town <- toupper(town)
  if(town == "ANG MO KIO"){ #Need this as Ang Mo Kio is the base category, so it is not included in the regression table and has no value for 'town'
    result <- regression$estimate[1] + areas*regression$estimate[27] + years*regression$estimate[28] + level*regression$estimate[29] + bedrooms*regression$estimate[30]
    return(result)
  } #Everything else however does have a value for town. 
  area<- regression[grep(town, regression$term),] #Filter the town estimate, eg. if im in Bukit Batok, I get the value -73316 and add this to the rest of the regression parameters. 
  area_value <- area$estimate[1]
  result <- regression$estimate[1] + area_value + areas*regression$estimate[27] + years*regression$estimate[28] + level*regression$estimate[29] + bedrooms*regression$estimate[30] #We extract individual parts of the regression from here, and add them to the value of the area
  if(result<140000){
    return(140000)
  }
  if(result>1205000){
    return(1205000)
  }
  return(result)
}

Percentage <- function(price){
  number <- hdb_housing_data %>% filter(resale_price>=price)
  answer <- 1-nrow(number)/nrow(hdb_housing_data)
  answer <- sprintf("%.2f",answer*100, "%")
  answer <- paste0(answer, "%")
  return(answer)
}
x <- hdb_housing_data %>% group_by(town) %>% summarise(mean(bedrooms))
towns <- as.character(x$town)
towns <- list(towns)
towns <- str_sort(towns[[1]])
#towns
towns_lat_lon <- data.frame(towns, stringsAsFactors = FALSE)
towns_lat_lon$towns <- paste(towns_lat_lon$towns, "Singapore")
#towns_lat_lon 

towns_lat_lon <- read.csv("towns_lat_lon.csv")[c(2,3,4)]
towns_lat_lon <- towns_lat_lon %>% rename(town = towns)
towns_lat_lon$town <- towns
town_df <- data.frame(towns_lat_lon, estimated_price = rep(0,26))

price_estimate_by_town <- function(areas, years, level, bedrooms) { #This function spits out the price estimate for every town based on floor area bedrooms level years remaining and their lat/lon so we can leaflet plot this
  result <- regression$estimate[1] + areas*regression$estimate[27] + years*regression$estimate[28] + level*regression$estimate[29] + bedrooms*regression$estimate[30]
  town_df$estimated_price[1] <- result
  for (i in 1:25){
    town_df$estimated_price[i+1] <- result + regression$estimate[1+i]
  }

  town_df$estimated_price <- paste0('$',formatC(town_df$estimated_price,digits=2,big.mark=',',format='f'))
  return(town_df[c(1,4,2,3)])
  
}

produce_leaflet <- function(areas, years, level, bedrooms){
  hdb_housing_data$No_stations <- as.character(hdb_housing_data$No_stations)
  hdb_housing_data$No_stations <- as.numeric(hdb_housing_data$No_stations)
  leaflet_df <- price_estimate_by_town(areas, years, level, bedrooms)
  leaflet_df$estimated_price <- as.numeric(gsub('[$,]',"",leaflet_df$estimated_price))
  qpal <- colorQuantile(c("green", "yellow", "firebrick1"), hdb_housing_data$resale_price, n = 5)
  #qpal2 <- colorQuantile(c("green", "yellow", "firebrick1"), leaflet_df$resale_price, n = 3)
  for(i in 1:26){
    if(leaflet_df$estimated_price[i] < 140000)
    {
      leaflet_df$estimated_price[i] <- 140000
    }
  }
  for(i in 1:26){
    if(leaflet_df$estimated_price[i] > 1205000)
    {
      leaflet_df$estimated_price[i] <- 1205000
    }
  }
  leaflet_df$estimated_price2 <- ifelse(leaflet_df$estimated_price == 140000,paste0('<$',formatC(leaflet_df$estimated_price,digits=2,big.mark=',',format='f')),ifelse(leaflet_df$estimated_price == 1205000,paste0('>$',formatC(leaflet_df$estimated_price,digits=2,big.mark=',',format='f')),paste0('$',formatC(leaflet_df$estimated_price,digits=2,big.mark=',',format='f')))) 
  mrts_by_town <- hdb_housing_data %>% group_by(town) %>% summarise(No_stations = mean(No_stations))
  leaflet_df <- merge(leaflet_df,mrts_by_town)
  library(stringi)
  leaflet_df$av_price <- Av_Price$mean
  
  leaflet() %>% addTiles() %>% addCircleMarkers(data = leaflet_df, lng = ~lon, lat=~lat, popup = ~sprintf('HDB Town = %s <br/> Price = %s <br/> Number of MRTs = %s <br/> <br/> Average_Price = %s <br/> ', stri_trans_totitle(town), estimated_price2, No_stations, av_price),color = ~qpal(estimated_price), radius=15, opacity = 0.7) %>% addLegend(data = leaflet_df, position = "bottomright", pal = qpal, values = hdb_housing_data$resale_price, title="Price Classification (Comparison With All SG HDB flats)")
}

produce_leaflet2 <- function(areas, years, level, bedrooms){
  hdb_housing_data$No_stations <- as.character(hdb_housing_data$No_stations)
  hdb_housing_data$No_stations <- as.numeric(hdb_housing_data$No_stations)
  leaflet_df <- price_estimate_by_town(areas, years, level, bedrooms)
  leaflet_df$estimated_price <- as.numeric(gsub('[$,]',"",leaflet_df$estimated_price))
  qpal <- colorQuantile(c("green", "yellow", "firebrick1"), leaflet_df$estimated_price, n = 3)
  #qpal2 <- colorQuantile(c("green", "yellow", "firebrick1"), leaflet_df$resale_price, n = 3)
  for(i in 1:26){
    if(leaflet_df$estimated_price[i] < 140000)
    {
      leaflet_df$estimated_price[i] <- 140000
    }
  }
  for(i in 1:26){
    if(leaflet_df$estimated_price[i] > 1205000)
    {
      leaflet_df$estimated_price[i] <- 1205000
    }
  }
  leaflet_df$estimated_price2 <- ifelse(leaflet_df$estimated_price == 140000,paste0('<$',formatC(leaflet_df$estimated_price,digits=2,big.mark=',',format='f')),ifelse(leaflet_df$estimated_price == 1205000,paste0('>$',formatC(leaflet_df$estimated_price,digits=2,big.mark=',',format='f')),paste0('$',formatC(leaflet_df$estimated_price,digits=2,big.mark=',',format='f')))) 
  mrts_by_town <- hdb_housing_data %>% group_by(town) %>% summarise(No_stations = mean(No_stations))
  leaflet_df <- merge(leaflet_df,mrts_by_town)
  library(stringi)
  leaflet_df$av_price <- Av_Price$mean
  leaflet() %>% addTiles() %>% addCircleMarkers(data = leaflet_df, lng = ~lon, lat=~lat, popup = ~sprintf('HDB Town = %s <br/> Price = %s <br/> Number of MRTs = %s <br/> <br/> Average Price = %s <br/> ', stri_trans_totitle(town), estimated_price2 , No_stations, av_price),color = ~qpal(estimated_price), radius=15, opacity = 0.7) %>% addLegend(data = leaflet_df, position = "bottomright", pal = qpal, values = ~estimated_price, title="Colour Comparison of Price Estimates By Town)")
}
# I need to enter data for town, floor area, years remaining, level and bedrooms to get an estimate for the price. 
#hdb_price_estimate("Bukit Timah", 150, 25, 10, 3)

#hdb_price_estimate function End



#from Calculate Distance
getwd()
primaryschools <- read.csv("primarysch.csv")
secondaryschools <- read.csv("secsch.csv")
tertiaryschools <- read.csv("tertiarysch.csv")
malls <- read.csv("mallcoord.csv")
mrt <- read.csv("mrtcoord.csv")
hawker <- read.csv("hawkercoord.csv")
primaryschools$Coord <- paste(primaryschools$lon,primaryschools$lat)
secondaryschools$Coord <- paste(secondaryschools$lon,secondaryschools$lat)
tertiaryschools$Coord <- paste(tertiaryschools$lon,tertiaryschools$lat)
malls$Coord <- paste(malls$lon,malls$lat)
mrt$Coord <- paste(mrt$lon,mrt$lat)
hawker$Coord <- paste(hawker$lon,hawker$lat)



findStraightLineDistance <- function(lon1,lat1,lon2,lat2){
  return(distm (c(lon1, lat1), c(lon2, lat2), fun = distHaversine)) # in meters
}

distance <- function(place, lon, lat){
  x <- strsplit(place, split = " ")
  return(as.numeric(findStraightLineDistance(lon,lat, as.numeric(x[[1]][1]), as.numeric(x[[1]][2]))))
}

findNearest <- function(inputAddress, range = 0, waddress){
  address<-as.data.frame(inputAddress, stringsAsFactors=FALSE)
  addressGeocode <- mutate_geocode(address, inputAddress)
  #find nearing mrt
  mrt$dist <- sapply(mrt$Coord, distance, as.numeric(addressGeocode$lon[1]),as.numeric(addressGeocode$lat[1]))
  mrt$withinRange <-ifelse(mrt$dist <=range, TRUE,FALSE)
  mrtNearest <- data.frame(Type="MRT",Name=mrt$MRT[which(mrt$dist==min(mrt$dist))],Distance=mrt$dist[which(mrt$dist==min(mrt$dist))],withinRange=sum(mrt$withinRange))
  #find nearest primary school
  primaryschools$dist <- sapply(primaryschools$Coord, distance, as.numeric(addressGeocode$lon[1]),as.numeric(addressGeocode$lat[1]))
  primaryschools$withinRange <-ifelse(primaryschools$dist <=range, TRUE,FALSE)
  primaryschoolsNearest <- data.frame(Type="Primary School",Name=primaryschools$School[which(primaryschools$dist==min(primaryschools$dist))],Distance=primaryschools$dist[which(primaryschools$dist==min(primaryschools$dist))],withinRange=sum(primaryschools$withinRange))
  #find nearest secondary school
  secondaryschools$dist <- sapply(secondaryschools$Coord, distance, as.numeric(addressGeocode$lon[1]),as.numeric(addressGeocode$lat[1]))
  secondaryschools$withinRange <-ifelse(secondaryschools$dist <=range, TRUE,FALSE)
  secondaryschoolsNearest <- data.frame(Type="Secondary School",Name=secondaryschools$School[which(secondaryschools$dist==min(secondaryschools$dist))],Distance=secondaryschools$dist[which(secondaryschools$dist==min(secondaryschools$dist))],withinRange=sum(secondaryschools$withinRange))
  #find nearest tertiary school
  tertiaryschools$dist <- sapply(tertiaryschools$Coord, distance, as.numeric(addressGeocode$lon[1]),as.numeric(addressGeocode$lat[1]))
  tertiaryschools$withinRange <-ifelse(tertiaryschools$dist <=range, TRUE,FALSE)
  tertiaryschoolsNearest <- data.frame(Type="Tertiary School",Name=tertiaryschools$School[which(tertiaryschools$dist==min(tertiaryschools$dist))],Distance=tertiaryschools$dist[which(tertiaryschools$dist==min(tertiaryschools$dist))],withinRange=sum(tertiaryschools$withinRange))
  #find nearest mall
  malls$dist <- sapply(malls$Coord, distance, as.numeric(addressGeocode$lon[1]),as.numeric(addressGeocode$lat[1]))
  malls$withinRange <-ifelse(malls$dist <=range, TRUE,FALSE)
  mallNearest <- data.frame(Type="Shopping Mall",Name=malls$Mall[which(malls$dist==min(malls$dist))],Distance=malls$dist[which(malls$dist==min(malls$dist))],withinRange=sum(malls$withinRange))
  #find nearest hawkercenter
  hawker$dist <- sapply(hawker$Coord, distance, as.numeric(addressGeocode$lon[1]),as.numeric(addressGeocode$lat[1]))
  hawker$withinRange <-ifelse(hawker$dist <=range, TRUE,FALSE)
  hawkerNearest <- data.frame(Type="Hawker Center",Name=hawker$HawkerCentre[which(hawker$dist==min(hawker$dist))],Distance=hawker$dist[which(hawker$dist==min(hawker$dist))],withinRange=sum(hawker$withinRange))
  #find distance to work
  work <- geocode(paste(waddress, "Singapore"))
  work$Coord <- paste(work$lon,work$lat)
  work$dist <- sapply(work$Coord, distance, as.numeric(addressGeocode$lon[1]),as.numeric(addressGeocode$lat[1]))
  workNearest <- data.frame(Type="Work Place",Name=waddress,Distance=work$dist[which(work$dist==min(work$dist))],withinRange="-/-")
  nearest <- rbind(primaryschoolsNearest,secondaryschoolsNearest,tertiaryschoolsNearest,mrtNearest,mallNearest,hawkerNearest, workNearest)
  nearest$Walking_Time <- nearest[3]/83.3
  nearest$Walking_Time <- sprintf("%.1f", unlist(nearest$Walking_Time), "%")
  print(nearest)
}

#findNearest("28 College Avenue Queenstown, Singapore",5000)

library(ggrepel)
price_estimate_summary_graph <- function(towns2, areas, years, level, bedrooms,intown){
  if(intown ==F){
    a <- toupper(towns2)
    user_price <- hdb_price_estimate(towns2, areas, years, level, bedrooms)
    prices <- hdb_housing_data$resale_price
    prices <- sort(prices)
    max <- max(prices)
    prices <- data.frame(prices)
    big <- prices %>% filter(prices > user_price)
    prop <- nrow(big)/nrow(prices)
    prop_perc <- paste(sprintf("%.2f",(1-prop)*100),"%")
    user_price_c <- paste0('$',formatC(user_price,digits=2,big.mark=',',format='f'))
    p <- ggplot(data = hdb_housing_data) + geom_histogram(aes(x=resale_price, y = ..count.., fill = cut(resale_price, breaks= c(0,user_price,2000000))),binwidth = 25000) + theme_linedraw()  + theme(legend.position = "none") + scale_fill_manual(values = c("palegreen", "tomato")) + geom_vline(xintercept=user_price, size=2.5, color="gray") + ggtitle("Singapore Property Value Comparison Tool") + geom_text(x=(100000+user_price)/2, y=5000, label=prop_perc, size=5) + geom_text(x=(user_price+1250000)/2, y=2000, label=paste(sprintf("%.2f",prop*100),"%"),size=5) + geom_text(aes(x=user_price, label=paste0("     Price  =    ",user_price_c), y=0, size=5), colour="black", vjust = 1, text=element_text(size=8)) +ylab("Number Of Properties") + xlab("Sale Price") + coord_cartesian(xlim =c(0, max+100000))
    return(p)
  }
  else{
    user_price <- hdb_price_estimate(towns2, areas, years, level, bedrooms)
    a <- toupper(towns2)
    b <- bedrooms
    town_price <- hdb_housing_data %>% filter(town == a, bedrooms==b) %>% select(resale_price)
    town_price <- town_price %>% arrange(resale_price)
    max <- max(town_price)
    big2 <- town_price %>% filter(town_price > user_price)
    prop2 <- nrow(big2)/nrow(town_price)
    prop_perc <- paste(sprintf("%.2f",(1-prop2)*100),"%")
    
    make <- hdb_housing_data %>% filter(town==a, bedrooms==b)
    user_price_c <- paste0('$',formatC(user_price,digits=2,big.mark=',',format='f'))
    p <- ggplot(data = make) + geom_histogram(aes(x=resale_price, y = ..count.., fill = cut(resale_price, breaks= c(0,user_price,2000000))),binwidth = 25000) + theme_linedraw() + theme(legend.position = "none") + scale_fill_manual(values = c("palegreen", "tomato")) + geom_vline(xintercept=user_price, size=2.5, color="gray") + ggtitle(paste(towns2, bedrooms, "Bedroom Property Value Comparison Tool")) + geom_text(x=user_price-50000, y=nrow(make)/20, label=prop_perc,hjust=1, size=5) + geom_text(x=user_price+50000, y=nrow(make)/20, label=paste(sprintf("%.2f",prop2*100),"%"), hjust=0, size=5) + geom_text(aes(x=user_price, size=5, label=paste0("     Price  =    ",user_price_c), y=0), colour="black", vjust = 1, text=element_text(size=8)) + ylab("Number Of Properties") + xlab("Sale Price") + coord_cartesian(xlim =c(0, max+100000))
    return(p)
  }
}
price_estimate_summary_graph2 <- function(towns2, areas, years, level, bedrooms,intown){
  if(intown ==F){
    a <- toupper(towns2)
    b <- bedrooms
    user_price <- hdb_price_estimate(towns2, areas, years, level, bedrooms)
    hdb_housing_data <- hdb_housing_data %>% filter(bedrooms == b)
    prices <- hdb_housing_data$resale_price
    prices <- sort(prices)
    max <- max(prices)
    prices <- data.frame(prices)
    big <- prices %>% filter(prices > user_price)
    prop <- nrow(big)/nrow(prices)
    prop_perc <- paste(sprintf("%.2f",(1-prop)*100),"%")
    user_price_c <- paste0('$',formatC(user_price,digits=2,big.mark=',',format='f'))
    p <- ggplot(data = hdb_housing_data) + geom_histogram(aes(x=resale_price, y = ..count.., fill = cut(resale_price, breaks= c(0,user_price,2000000))),binwidth = 25000) + theme_linedraw()  + theme(legend.position = "none") + scale_fill_manual(values = c("palegreen", "tomato")) + geom_vline(xintercept=user_price, size=2.5, color="gray") + ggtitle(paste("Singapore", bedrooms,"Bedroom Property Value Comparison Tool")) + geom_text(x=(user_price-120000), y=nrow(hdb_housing_data)/20, label=prop_perc, size=5) + geom_text(x=(user_price+120000), y=nrow(hdb_housing_data)/30, label=paste(sprintf("%.2f",prop*100),"%"),size=5) + geom_text(aes(x=user_price, label=paste0("     Price  =    ",user_price_c), y=0, size=5), colour="black", vjust = 1, text=element_text(size=8)) +ylab("Number Of Properties") + xlab("Sale Price") + coord_cartesian(xlim =c(0, max+100000))
    return(p)
  }}
price_estimate_summary_graph3 <- function(towns2, areas, years, level, bedrooms,intown){
    user_price <- hdb_price_estimate(towns2, areas, years, level, bedrooms)
    a <- toupper(towns2)
    b <- bedrooms
    town_price <- hdb_housing_data %>% filter(town == a) %>% select(resale_price)
    town_price <- town_price %>% arrange(resale_price)
    max <- max(town_price)
    big2 <- town_price %>% filter(town_price > user_price)
    prop2 <- nrow(big2)/nrow(town_price)
    prop_perc <- paste(sprintf("%.2f",(1-prop2)*100),"%")
    
    make <- hdb_housing_data %>% filter(town==a)
    user_price_c <- paste0('$',formatC(user_price,digits=2,big.mark=',',format='f'))
    p <- ggplot(data = make) + geom_histogram(aes(x=resale_price, y = ..count.., fill = cut(resale_price, breaks= c(0,user_price,2000000))),binwidth = 25000) + theme_linedraw() + theme(legend.position = "none") + scale_fill_manual(values = c("palegreen", "tomato")) + geom_vline(xintercept=user_price, size=2.5, color="gray") + ggtitle(paste(towns2, "Property Value Comparison Tool")) + geom_text(x=user_price-50000, y=nrow(make)/20, label=prop_perc,hjust=1, size=5) + geom_text(x=user_price+50000, y=nrow(make)/20, label=paste(sprintf("%.2f",prop2*100),"%"), hjust=0, size=5) + geom_text(aes(x=user_price, size=5, label=paste0("     Price  =    ",user_price_c), y=0), colour="black", vjust = 1, text=element_text(size=8)) + ylab("Number Of Properties") + xlab("Sale Price") + coord_cartesian(xlim =c(0, max+100000))
    return(p)
  }

function(input, output, session) {
  output$priceEstimate <- renderUI({
    # locations <- routeVehicleLocations()
    # if (length(locations) == 0 || nrow(locations) == 0)
    #   return(NULL)
    # Create a Bootstrap-styled table
    #print(hdb_price_estimate(input$town,input$floorarea,input$remainingLease,input$floor,input$bedroom))
    est_price <- hdb_price_estimate(input$town,input$floorarea,input$remainingLease,input$floor,input$bedroom)
    tags$table(class = "table",
               # tags$h3("Approximate Distance to Amendities"),
               tags$thead(tags$tr(
                 tags$th("Your Property Value:")
               )),
               tags$tbody(
                 tags$tr(
                   tags$td(h1(paste0('$',formatC(est_price, format="f", digits=2, big.mark=","), ' ± $30,000'))),
                 ),
                 tags$tr(
                   tags$td(paste("Based on a sample of HDB sales between 2017-2020, Your Property is worth more than approximately",Percentage(est_price),"of all HDB resale flats in Singapore!")),
                 )
               )
    )
  })
  output$priceEstimate2 <- renderUI({
    # locations <- routeVehicleLocations()
    # if (length(locations) == 0 || nrow(locations) == 0)
    #   return(NULL)
    # Create a Bootstrap-styled table
    #print(hdb_price_estimate(input$town,input$floorarea,input$remainingLease,input$floor,input$bedroom))
    est_price <- hdb_price_estimate(input$town2,input$floorarea2,input$remainingLease2,input$floor2,input$bedroom2)
    tags$table(class = "table",
               # tags$h3("Approximate Distance to Amendities"),
               tags$thead(tags$tr(
                 tags$th("Your First Property's Value:")
               )),
               tags$tbody(
                 tags$tr(
                   tags$td(h1(paste0('$',formatC(est_price, format="f", digits=2, big.mark=","), ' ± $30,000'))),
                 ),
                 tags$tr(
                   tags$td(paste("Based on a sample of HDB sales between 2017-2020, Your Property is worth more than approximately",Percentage(est_price),"of all HDB resale flats in Singapore!")),
                 )
               )
    )
  })
  output$priceEstimate3 <- renderUI({
    # locations <- routeVehicleLocations()
    # if (length(locations) == 0 || nrow(locations) == 0)
    #   return(NULL)
    # Create a Bootstrap-styled table
    #print(hdb_price_estimate(input$town,input$floorarea,input$remainingLease,input$floor,input$bedroom))
    est_price <- hdb_price_estimate(input$town3,input$floorarea3,input$remainingLease3,input$floor3,input$bedroom3)
    tags$table(class = "table",
               # tags$h3("Approximate Distance to Amendities"),
               tags$thead(tags$tr(
                 tags$th("Your Second Property's Value:")
               )),
               tags$tbody(
                 tags$tr(
                   tags$td(h1(paste0('$',formatC(est_price, format="f", digits=2, big.mark=","), ' ± $30,000'))),
                 ),
                 tags$tr(
                   tags$td(paste("Based on a sample of HDB sales between 2017-2020, Your Property is worth more than approximately",Percentage(est_price),"of all HDB resale flats in Singapore!")),
                 )
               )
    )
  })
  
  output$nearestAmendities <- renderUI({
    # locations <- routeVehicleLocations()
    # if (length(locations) == 0 || nrow(locations) == 0)
    #   return(NULL)
    nearestDf <- findNearest(paste(input$address,input$town,', Singapore'),input$range,input$waddress)
    # Create a Bootstrap-styled table
    tags$table(class = "table",
               tags$h3(paste("Approximate Distance to Amenities From",input$address,input$town)),
               tags$thead(tags$tr(
                 tags$th("Type"),
                 tags$th("Name"),
                 tags$th("Distance(m)"),
                 tags$th("Walking Time(min)"),
                 tags$th(paste("Number of Amenities Within", input$range, "m"))
               )),
               tags$tbody(
                 tags$tr(
                   tags$td("Primary School"),
                   tags$td(nearestDf[1,'Name']),
                   tags$td(round(nearestDf[1,'Distance'], digits = 0)),
                   tags$td(nearestDf[1,'Walking_Time']),
                   tags$td(nearestDf[1,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Secondary School"),
                   tags$td(nearestDf[2,'Name']),
                   tags$td(round(nearestDf[2,'Distance'], digits = 0)),
                   tags$td(nearestDf[2,'Walking_Time']),
                   tags$td(nearestDf[2,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Tertiary School"),
                   tags$td(nearestDf[3,'Name']),
                   tags$td(round(nearestDf[3,'Distance'], digits = 0)),
                   tags$td(nearestDf[3,'Walking_Time']),
                   tags$td(nearestDf[3,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("MRT"),
                   tags$td(nearestDf[4,'Name']),
                   tags$td(round(nearestDf[4,'Distance'], digits = 0)),
                   tags$td(nearestDf[4,'Walking_Time']),
                   tags$td(nearestDf[4,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Shopping Mall"),
                   tags$td(nearestDf[5,'Name']),
                   tags$td(round(nearestDf[5,'Distance'], digits = 0)),
                   tags$td(nearestDf[5,'Walking_Time']),
                   tags$td(nearestDf[5,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Hawker Center"),
                   tags$td(nearestDf[6,'Name']),
                   tags$td(round(nearestDf[6,'Distance'], digits = 0)),
                   tags$td(nearestDf[6,'Walking_Time']),
                   tags$td(nearestDf[6,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Work/POI"),
                   tags$td(nearestDf[7,'Name']),
                   tags$td(round(nearestDf[7,'Distance'], digits = 0)),
                   tags$td(nearestDf[7,'Walking_Time']),
                   tags$td(nearestDf[7,'withinRange'], digits = 0)
                 )
               )
    )
  })
  output$nearestAmenities2 <- renderUI({
    # locations <- routeVehicleLocations()
    # if (length(locations) == 0 || nrow(locations) == 0)
    #   return(NULL)
    nearestDf <- findNearest(paste(input$address2,input$town2,', Singapore'),input$range2,input$waddress2)
    # Create a Bootstrap-styled table
    tags$table(class = "table",
               tags$h3(paste("Approximate Distance to Amenities From",input$address2,input$town2)),
               tags$thead(tags$tr(
                 tags$th("Type"),
                 tags$th("Name"),
                 tags$th("Distance(m)"),
                 tags$th("Walking Time(min)"),
                 tags$th(paste("Number of Amenities Within", input$range2, "m"))
               )),
               tags$tbody(
                 tags$tr(
                   tags$td("Primary School"),
                   tags$td(nearestDf[1,'Name']),
                   tags$td(round(nearestDf[1,'Distance'], digits = 0)),
                   tags$td(nearestDf[1,'Walking_Time']),
                   tags$td(nearestDf[1,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Secondary School"),
                   tags$td(nearestDf[2,'Name']),
                   tags$td(round(nearestDf[2,'Distance'], digits = 0)),
                   tags$td(nearestDf[2,'Walking_Time']),
                   tags$td(nearestDf[2,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Tertiary School"),
                   tags$td(nearestDf[3,'Name']),
                   tags$td(round(nearestDf[3,'Distance'], digits = 0)),
                   tags$td(nearestDf[3,'Walking_Time']),
                   tags$td(nearestDf[3,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("MRT"),
                   tags$td(nearestDf[4,'Name']),
                   tags$td(round(nearestDf[4,'Distance'], digits = 0)),
                   tags$td(nearestDf[4,'Walking_Time']),
                   tags$td(nearestDf[4,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Shopping Mall"),
                   tags$td(nearestDf[5,'Name']),
                   tags$td(round(nearestDf[5,'Distance'], digits = 0)),
                   tags$td(nearestDf[5,'Walking_Time']),
                   tags$td(nearestDf[5,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Hawker Center"),
                   tags$td(nearestDf[6,'Name']),
                   tags$td(round(nearestDf[6,'Distance'], digits = 0)),
                   tags$td(nearestDf[6,'Walking_Time']),
                   tags$td(nearestDf[6,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Work/POI"),
                   tags$td(nearestDf[7,'Name']),
                   tags$td(round(nearestDf[7,'Distance'], digits = 0)),
                   tags$td(nearestDf[7,'Walking_Time']),
                   tags$td(nearestDf[7,'withinRange'], digits = 0)
                 )
               )
    )
  })
  output$nearestAmenities3 <- renderUI({
    # locations <- routeVehicleLocations()
    # if (length(locations) == 0 || nrow(locations) == 0)
    #   return(NULL)
    nearestDf <- findNearest(paste(input$address3,input$town3,', Singapore'),input$range3,input$waddress3)
    # Create a Bootstrap-styled table
    tags$table(class = "table",
               tags$h3(paste("Approximate Distance to Amenities From",input$address3,input$town3)),
               tags$thead(tags$tr(
                 tags$th("Type"),
                 tags$th("Name"),
                 tags$th("Distance(m)"),
                 tags$th("Walking Time(min)"),
                 tags$th(paste("Number of Amenities Within", input$range3, "m"))
               )),
               tags$tbody(
                 tags$tr(
                   tags$td("Primary School"),
                   tags$td(nearestDf[1,'Name']),
                   tags$td(round(nearestDf[1,'Distance'], digits = 0)),
                   tags$td(nearestDf[1,'Walking_Time']),
                   tags$td(nearestDf[1,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Secondary School"),
                   tags$td(nearestDf[2,'Name']),
                   tags$td(round(nearestDf[2,'Distance'], digits = 0)),
                   tags$td(nearestDf[2,'Walking_Time']),
                   tags$td(nearestDf[2,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Tertiary School"),
                   tags$td(nearestDf[3,'Name']),
                   tags$td(round(nearestDf[3,'Distance'], digits = 0)),
                   tags$td(nearestDf[3,'Walking_Time']),
                   tags$td(nearestDf[3,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("MRT"),
                   tags$td(nearestDf[4,'Name']),
                   tags$td(round(nearestDf[4,'Distance'], digits = 0)),
                   tags$td(nearestDf[4,'Walking_Time']),
                   tags$td(nearestDf[4,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Shopping Mall"),
                   tags$td(nearestDf[5,'Name']),
                   tags$td(round(nearestDf[5,'Distance'], digits = 0)),
                   tags$td(nearestDf[5,'Walking_Time']),
                   tags$td(nearestDf[5,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Hawker Center"),
                   tags$td(nearestDf[6,'Name']),
                   tags$td(round(nearestDf[6,'Distance'], digits = 0)),
                   tags$td(nearestDf[6,'Walking_Time']),
                   tags$td(nearestDf[6,'withinRange'], digits = 0)
                 ),
                 tags$tr(
                   tags$td("Work/POI"),
                   tags$td(nearestDf[7,'Name']),
                   tags$td(round(nearestDf[7,'Distance'], digits = 0)),
                   tags$td(nearestDf[7,'Walking_Time']),
                   tags$td(nearestDf[7,'withinRange'], digits = 0)
                 )
               )
    )
  })

  
  
  
  output$housemap <- renderLeaflet({
    if(input$radio=="Compare Price Estimate in Each Town With all Singapore HDB properties. "){
    leaf <- produce_leaflet(input$floorarea,input$remainingLease,input$floor,input$bedroom) 
    leaf
    }
    else{
    leaf <- produce_leaflet2(input$floorarea,input$remainingLease,input$floor,input$bedroom) 
    leaf
    }
  })
  output$housemap2 <- renderPlotly({
    data2 <- mean(hdb_housing_data[hdb_housing_data$town == input$town2,]$resale_price)
    data3 <- mean(hdb_housing_data[hdb_housing_data$town == input$town3,]$resale_price)
    y2 <- hdb_price_estimate(input$town3,input$floorarea3,input$remainingLease3,input$floor3,input$bedroom3)
    y1 <- hdb_price_estimate(input$town2,input$floorarea2,input$remainingLease2,input$floor2,input$bedroom2)
    Price <- c(y1,data2,y2,data3)
    x <- c(paste(input$town2, "Price Estimate"),paste(input$town2,"Average Price"), paste(input$town3, "Price Estimate"),paste(input$town3, "Average Price"))
    data <- data.frame(x,Price)
    plot <- data %>% ggplot() + geom_bar(aes(x=x,y=Price, fill=x), stat="identity") + xlab("Property") + ylab("Price ($)") + theme(axis.text.x = element_text(angle=45, size = 12), axis.text.y=element_text(size=12)) + theme(legend.position="none")+ scale_y_continuous(name="Asking Price ($)", labels = function(x){dollar_format()(x)})+ theme(axis.title.x = element_text(size=13))+ theme(axis.title.y = element_text(size=11)) + scale_fill_manual(values=c("dodgerblue1","dodgerblue1", "lightsalmon2", "lightsalmon2"))
    return(ggplotly(plot, tooltip="Price"))
  })
  output$priceGraph <-renderPlot({
    if(input$comparison == 'All of Singapore'){
    price_estimate_summary_graph(input$town, input$floorarea, input$remainingLease, input$floor, input$bedroom,F)
    }
    else if(input$comparison == 'All of Singapore (Same Bedrooms)'){
    price_estimate_summary_graph2(input$town, input$floorarea, input$remainingLease, input$floor, input$bedroom,F)
    }
    else if(input$comparison=="Within HDB Town"){
      price_estimate_summary_graph3(input$town, input$floorarea, input$remainingLease, input$floor, input$bedroom,T)
    }
    else {
      price_estimate_summary_graph(input$town, input$floorarea, input$remainingLease, input$floor, input$bedroom,T)
    }
  })
  output$priceGraph2 <-renderPlot({
    if(input$comparison2 == 'All of Singapore'){
      price_estimate_summary_graph(input$town2, input$floorarea2, input$remainingLease2, input$floor2, input$bedroom2,F)
    } 
    else if(input$comparison2 == 'All of Singapore (Same Bedrooms)'){
      price_estimate_summary_graph2(input$town2, input$floorarea2, input$remainingLease2, input$floor2, input$bedroom2,F)
    }
    else if(input$comparison2=="Within HDB Town"){
      price_estimate_summary_graph3(input$town2, input$floorarea2, input$remainingLease2, input$floor2, input$bedroom2,T)
    }
    else {
      price_estimate_summary_graph(input$town2, input$floorarea2, input$remainingLease2, input$floor2, input$bedroom2,T)
    }
  })
  output$priceGraph3 <-renderPlot({
    if(input$comparison3 == 'All of Singapore'){
      price_estimate_summary_graph(input$town3, input$floorarea3, input$remainingLease3, input$floor3, input$bedroom3,F)
    } 
    else if(input$comparison3 == 'All of Singapore (Same Bedrooms)'){
      price_estimate_summary_graph2(input$town3, input$floorarea3, input$remainingLease3, input$floor3, input$bedroom3,F)
    }
    else if(input$comparison3=="Within HDB Town"){
      price_estimate_summary_graph3(input$town3, input$floorarea3, input$remainingLease3, input$floor3, input$bedroom3,T)
    }
    else {
      price_estimate_summary_graph(input$town3, input$floorarea3, input$remainingLease3, input$floor3, input$bedroom3,T)
    }
  })
  
  output$trend <- renderPlotly({
    data1 <- hdb_housing_data[hdb_housing_data$town==input$town2&hdb_housing_data$bedrooms==input$bedroom2,] %>% group_by(Year) %>% summarise(mean_price = mean(resale_price))
    data1$town <- input$town2
    data1$bedrooms <- input$bedroom2
    data2 <- hdb_housing_data[hdb_housing_data$town==input$town3&hdb_housing_data$bedrooms==input$bedroom3,] %>% group_by(Year) %>% summarise(mean_price = mean(resale_price))
    data2$town <- input$town3
    data2$bedrooms <- input$bedroom3
    data <- rbind(data1,data2)
    plot <- ggplot() + geom_smooth(data=data, aes(x=Year, y=mean_price, color=town, text=paste("bedrooms: ",bedrooms)), size=1.5)  + theme(axis.text.x = element_text(size = 12), axis.text.y=element_text(size=15))+coord_cartesian(ylim=c(200000,ceiling(max(data$mean_price))))+ scale_y_continuous(name="Asking Price", labels = function(x){dollar_format()(x)}) + theme(axis.title.x = element_text(size=13))+ theme(axis.title.y = element_text(size=13)) + scale_colour_manual(values=c("dodgerblue1", "lightsalmon2"))
    return(ggplotly(plot))
  })
}