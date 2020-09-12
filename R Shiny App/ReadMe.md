---
title: "DBA3702 Project Report"
author: "SA1 Team 8"
output:
  html_document:
    toc: true
    toc_depth: 4
    toc_float: true
    theme: flatly
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, eval=FALSE)
```
```{r message=FALSE, warning=FALSE, echo=FALSE}
library(tidyverse)
library(rvest)
library(RCurl)
library(curl)
library(jsonlite) 
library(XML)
library(ggmap)
options(scipen=100000000)
```
Kazi Mubin Mussaddique A0212754J <br>
David You Chen Ming A0183268W<br>
Alina @ Su Myat Htaik Htar Oo A0191122U<br>
Haiwen Chen A0212991A A0212991A<br>
Neo Kar Min A0184881R<br>

## 1. Case Description
### 1.1. Case Background

<div style="text-align: justify"> 

Housing Development Board (HDB) flats are subsidised public housing for Singaporeans. HDB flats are home to nearly 80% of the Singapore population and are usually located in housing estates with amenities in the estate (data.gov, 2020). Every housing estate has a MRT or LRT station to link citizens to other parts of the country. Currently, Singaporeans have the choice of purchasing a HDB resale flat or a new flat by purchasing what is commonly known as a Build-To-Order (BTO) flat. BTO flats come with many advantages but also disadvantages that deter people from purchasing them. One usually has to wait a few years before they get their BTO flat, and their BTO flat could be smaller than resale HDB flats (99.co, 2019). Plus, there are a number of criteria to be eligible for a BTO flat and if one has purchased one before, they will not be eligible for another (Fatti, 2019). In short, getting a BTO flat is a tedious process, not optimal for many Singaporeans. On the other hand, the buying and selling process for HDB resale flats is much faster. Since resale flats also tend to be larger than BTO flats, many Singaporeans still prefer to purchase a resale HDB flat instead.

</div>
### 1.2. Current Problem

<div style="text-align: justify"> 

When it comes to buying and selling on the HDB resale market, a big problem is the issue of accurately estimating the fair price for resale flats (Poh, 2018). This could also be due to the fact that many are first time buyers or sellers and are unfamiliar with the housing market. 

To alleviate this problem, many people visit websites such as propertyguru or directhome to try and get an estimated price of the HDB flat they are looking at. However, these sites may have marked up prices since listings are put up by property agents, and they may not provide enough relevant information for the users. In addition, it is tedious to do a manual price comparison through the prices listed on these websites. Although the websites allow you to search by district, one has to manually scroll through pages of listings and calculate an average in order to get a rough estimate of the prices of HDB flats in that district. Since it is likely that most people would only take a small number of prices to calculate this average, the estimate they derive is likely to be neither fair nor accurate.

Additionally, all price estimate tools online require the user to input an address. While an address may allow for a very accurate price estimate based on actual sale data from that address, requiring the input of an address might actually be a hindrance to users who only want to compare and analyse the value of multiple HDB flats in different regions or locations, as this will involve finding the addresses of all the types of properties in different locations that the user wants to compare. 

Since it is clearly difficult to independently buy or sell a HDB resale flat in Singapore, a popular option for many is to turn to property agents. By enlisting an agent, buyers and sellers can find out the estimated price of the property they are considering. However, a potential problem is that there could be a lack of transparency in the property agent’s costs. Since property agents typically earn a percentage commission off the sale price of the flat, the price given by them could be biased as it would be beneficial for them to mark up the price. Thus, the price estimates that property agents propose to their clients may not be fair due to this markup. Furthermore, property agents may also have incomplete information on nearby amenities, and would not be able to offer maximum value for their clients.

</div>

### 1.3. Proposed Solution

<div style="text-align: justify"> 

In order to tackle the aforementioned difficulties that buyers and sellers in the HDB resale market may face, we developed an app that is able to provide fair price estimates of HDB flats in a specified HDB Town. Our app takes in a number of user-selected parameters and returns a fair price estimate along with useful information such as details on nearby amenities. This allows buyers and sellers to compare HDB flat prices at a glance, which saves a lot of time and hassle.  In addition, the app also helps users find out the information they need to make an informed choice by providing numerous other visualisations and even a tool that allows them to specifically compare the information on 2 selected HDB flats. 

We will further discuss the methodology behind our app and how it helps to resolve the aforementioned issues along with the details of our app features in the following sections. 

</div>

***

## 2. Methodology

### 2.1. Data Sources

We retrieved our data from a variety of sources which have been listed in the following table:


Type of Information Retrieved |Data Source | Purpose/Section of Code
------------------------------|------------|------------------------
HDB/Flat Resale Prices | https://data.gov.sg/dataset/resale-flat-prices | To retrieve HDB Housing information to assist with the creation of the app
API for HDB/Flat Resale Prices | https://data.gov.sg/api/action/datastore_search?resource_id=42ff9cfe-abe5-4b54-beda-c88f9bb438ee&limit=106572 | To retrieve HDB Housing information to assist with the creation of the app
Information on MRTs, by planning area | https://en.wikipedia.org/wiki/List_of_Singapore_MRT_stations_by_planning_area | For Leaflet
Information on Schools | https://data.gov.sg/dataset/school-directory-and-information?resource_id=ede26d32-01af-4228-b1ed-f05c45a1d8ee | Geocoding
Information on ITEs | https://www.ite.edu.sg/who-we-are/get-in-touch | Retrieve info on ITEs for Geocoding
Information on Polytechnics | https://en.wikipedia.org/wiki/List_of_schools_in_Singapore#Polytechnics | Retrieve info on Polytechnics for Geocoding
Information on MRTs | https://en.wikipedia.org/wiki/List_of_Singapore_MRT_stations | Geocoding
Information on Shopping Malls | https://en.wikipedia.org/wiki/List_of_shopping_malls_in_Singapore | Geocoding
Information on Hawker Centres in Singapore | https://data.gov.sg/dataset/list-of-government-markets-hawker-centres | Geocoding

### 2.2. Data Processing

<div style="text-align: justify"> 

We crawled data from the aforementioned data sources to obtain datasets for schools, MRTs, shopping malls and hawker centres. 

We conducted geocoding on these datasets to derive their longitudes and latitudes, which were then used in the plotting of the leaflet map.

We used the libraries “curl”, “XML”, “rvest” and “ggmap”. 

</div>

#### 2.2.1. Schools
```{r eval=FALSE}
#Download csv file from data.gov, then read csv file
schoolsdata = read.csv("schools.csv", stringsAsFactors = F)
colnames(schoolsdata)
school <- schoolsdata %>% select('school_name', 'mainlevel_code')
names(school) <- c('School', 'Type')
school$School <- str_to_title(school$School) #making school names title case
school$School <- gsub("Chij", "CHIJ", school$School)
#View(school)

#creating a new dataframe to store mixed levels schools
schooltemp <- school[school$Type=="MIXED LEVELS",]
schooltemp$Type[1:3] <- "PRIMARY"
schooltemp$Type[4:14] <- "TERTIARY"

#manual adjustments for school types
school$Type[school$Type=="MIXED LEVELS"] <- "SECONDARY"
school$Type[334] <- "PRIMARY"
school$Type[school$Type=="JUNIOR COLLEGE"] <- "TERTIARY"
school$Type[school$Type=="CENTRALISED INSTITUTE"] <- "TERTIARY"

#importing ITE & poly data
data <- read_html("https://www.ite.edu.sg/who-we-are/get-in-touch")
ite_address <- html_nodes(data, "iframe+ p , p:nth-child(11)") %>% html_text %>% as.data.frame()
ite_address1 <- ite_address %>% separate(".",c("School", "Address"), sep = ":")
ite_names <- ite_address1$School %>% substr(1,nchar(ite_address1$School)-7) %>% as.data.frame()
names(ite_names)[1] <- "School"
#ite_names
poly_data <- read_html("https://en.wikipedia.org/wiki/List_of_schools_in_Singapore#Polytechnics")
poly_names <- html_nodes(poly_data,"h3+ .wikitable td > a ") %>% html_text %>% as.data.frame()
names(poly_names)[1] <- "School"
#poly_names

#creating Type field for Poly and ITE
ite_names$Type <- "TERTIARY"
poly_names$Type <- "TERTIARY"

#Combining all school data together
school_final <- rbind(school, schooltemp)
row.names(school_final) <- NULL #making the row count from 1:whatever
#View(school_final)
school_final <- rbind(school_final, ite_names) %>% rbind(poly_names)
school_final$School <- paste0(school_final$School, ", Singapore")
head(school_final)

#geocoding
schoolcoord <- mutate_geocode(school_final, School)

#manual adjustments
schoolcoord[63, c(3,4)] <- sprintf("%.7f",geocode("501 Ang Mo Kio Street 13, Singapore 569405")) #CHIJ St Nicholas
schoolcoord[348, c(3,4)] <- sprintf("%.7f",geocode("501 Ang Mo Kio Street 13, Singapore 569405")) #CHIJ St Nicholas
schoolcoord[283, c(3,4)] <- sprintf("%.7f",geocode("21 Pasir Ris Street 71, Singapore 518799")) #Tampines Meridian JC
schoolcoord[318, c(3,4)] <- sprintf("%.7f",geocode("11 Woodlands Ring Rd, Singapore 738240")) #Woodlands Ring Primary
schoolcoord[337, c(3,4)] <- sprintf("%.7f",geocode("35 Jurong West Street 41, Singapore 649406")) #Yuhua Sec

#final 
View(schoolcoord)
schoolcoord %>% arrange(Type)
primarysch <- subset(schoolcoord, Type=="PRIMARY")
secsch <- subset(schoolcoord, Type=="SECONDARY")
tertiarysch <- subset(schoolcoord, Type=="TERTIARY")

#School csv
write.csv(primarysch, "C:\\Users\\David\\Documents\\school stuff\\DBA3702\\project\\primarysch.csv",
           row.names=FALSE)
write.csv(secsch, "C:\\Users\\David\\Documents\\school stuff\\DBA3702\\project\\secsch.csv",
          row.names=FALSE)
write.csv(tertiarysch, "C:\\Users\\David\\Documents\\school stuff\\DBA3702\\project\\tertiarysch.csv",
          row.names=FALSE)
```

#### 2.2.2. MRT Stations
```{r eval=FALSE}
#retrieving URL
mrt_url <- "https://en.wikipedia.org/wiki/List_of_Singapore_MRT_stations"
mrt_url <- curl(mrt_url)
mrt_wiki <- readLines(mrt_url)
mrt_data <- readHTMLTable(mrt_wiki, stringsAsFactors=FALSE)

#retrieving table containing all MRT stations in Singapore, minus crappy headers
mrt <- as.data.frame(mrt_data[[2]])[-c(1,2),]
mrt[mrt[,1]=='N/A',] <- NA

mrt <- drop_na(mrt, c('V1', 'V3'))
mrt2 <- mrt[,c(1,3)]
mrt2 <- mrt2[complete.cases(mrt2),]
#creating a dataframe containing just the MRT station names
#also making it easier to geocode by adding suffix
mrtnames <- mrt[,3]
mrtnames <- paste0(mrtnames, "MRT, Singapore") 
mrtnames <- unique(mrtnames)
mrtnames <- as.data.frame(mrtnames, stringsAsFactors = FALSE)
mrtnames <- as.data.frame(mrtnames, stringsAsFactors=FALSE) %>% distinct()
mrtnames <- rename(mrtnames, MRT = mrtnames)
mrtnames[87,] <- "Botanic Gardens MRT, Singapore"

#geocoding
mrtcoord <- mutate_geocode(mrtnames, MRT)

#2 stations were very inaccurate, so adjusted manually
#changing promenade
mrtcoord[76, c(2,3)] <- sprintf("%.7f",geocode("Temasek Ave, 10-2"))
#changing bendemeer
mrtcoord[111, c(2,3)] <- sprintf("%.7f",geocode("50 Kallang Bahru, Singapore 339334"))

#final
head(mrtcoord)

#MRT Station csv
write.csv(mrtcoord, "C:\\Users\\David\\Documents\\school stuff\\DBA3702\\project\\mrtcoords.csv",
           row.names=FALSE)
```

#### 2.2.3. Shopping Malls
```{r}
mall_url <- "https://en.wikipedia.org/wiki/List_of_shopping_malls_in_Singapore"
mall_wiki <- read_html(mall_url)
mall <- html_nodes(mall_wiki, "h2+ ul li") %>% html_text()
mallnames <- as.data.frame(mall[-1])

mallnames <- paste(mallnames[,], ", Singapore", sep='')
mallnames[60] <- "The Poiz Centre, Singapore"
mallnames <- mallnames[-161]
mallnames <- as.data.frame(mallnames, stringsAsFactors=FALSE)
mallnames <- rename(mallnames, Mall = mallnames)

#geocoding
mallcoord <- mutate_geocode(mallnames, Mall)

#final product
head(mallcoord)

#Shopping Mall csv
write.csv(mallcoord, "C:\\Users\\David\\Documents\\school stuff\\DBA3702\\project\\mallcoord.csv",
           row.names=FALSE)
```

#### 2.2.4. Hawker Centres
```{r eval=FALSE}
#reading in hawker data
hawkerdata <- read.csv('hawker centres.csv', stringsAsFactors = F)

#extracting only name and address
hawkers <- hawkerdata[,1:2]
colnames(hawkers) <- c("HawkerCentre", "Address")

#geocoding
hawkercoord <- mutate_geocode(hawkers, Address)

#final
head(hawkercoord)

#Hawker Centre csv
write.csv(hawkercoord, "C:\\Users\\David\\Documents\\school stuff\\DBA3702\\project\\hawkercoord.csv", 
          row.names=FALSE)
```

#### 2.2.5. Preparing the HDB Dataset

##### Retrieving the HDB Housing Data
```{r}
api_url <- "https://data.gov.sg/api/action/datastore_search?resource_id=42ff9cfe-abe5-4b54-beda-c88f9bb438ee&limit=106572"
data <- fromJSON(api_url)
#data
hdb_housing_data <- data[[3]][[3]]
#head(hdb_housing_data)
#hdb_housing_data



```

##### Retrieving MRT Location Data
```{r}
url_mrt <- "https://en.wikipedia.org/wiki/List_of_Singapore_MRT_stations_by_planning_area"
urdata <- curl(url_mrt)
urldata <- readLines(urdata)
data2 <- readHTMLTable(urldata, header = T)
MRTS <- as.data.frame(data2[[2]])
#MRTS
MRTS$Operational_stations <- MRTS$`Operational stations`
MRTS$Operational_stations <- gsub("[\n]", "", MRTS$Operational_stations)
#MRTS$Operational_stations
#MRTS <- MRTS %>% rename('town' = 'Planning area')
MRTS$town <- MRTS$`Planning area`
#MRTS
#hdb_housing_data
MRTS$town <- toupper(MRTS$town)
#MRTS$town
#table(hdb_housing_data$town)
#MRTS
hdb_housing_data[hdb_housing_data$town == "KALLANG/WHAMPOA", ][, "town"] <- "KALLANG"
MRTS[MRTS$town == "DOWNTOWN CORE", ][, 'town'] <- "CENTRAL AREA"

#hdb_housing_data$No_stations <- as.numeric(hdb_housing_data$No_stations)
#hdb_housing_data
#table(hdb_housing_data_mrt$town)
```

##### Merge the two datasets
```{r}
hdb_housing_data_mrt <- left_join(hdb_housing_data,MRTS, by = 'town')
hdb_housing_data_mrt[is.na(hdb_housing_data_mrt$`No. ofoperational
stations

`),]
hdb_housing_data <- hdb_housing_data_mrt
head(hdb_housing_data)
```


##### Cleaning HDB Housing Data Dataset

Need a column for number of bedrooms. Flat type tells us this. 
https://www.hdb.gov.sg/cs/infoweb/residential/buying-a-flat/resale/types-of-flats
```{r}
#hdb_housing_data %>% group_by(town) %>% summarise(average_price = mean(as.numeric(resale_price))) %>% arrange(desc(average_price))
hdb_housing_data$bedrooms <- rep(1, nrow(hdb_housing_data)) #Create a new column for bedrooms
hdb_housing_data[hdb_housing_data$flat_type == "2 ROOM",][,"bedrooms"] <- 2 #Filter all rows where flattype = 2room, then change value of cell under the bedrooms column
hdb_housing_data[hdb_housing_data$flat_type == "3 ROOM",][,"bedrooms"] <- 3
hdb_housing_data[hdb_housing_data$flat_type == "4 ROOM",][,"bedrooms"] <- 4
hdb_housing_data[hdb_housing_data$flat_type == "5 ROOM",][,"bedrooms"] <- 5
hdb_housing_data[hdb_housing_data$flat_type == "EXECUTIVE",][,"bedrooms"] <- 3
hdb_housing_data[hdb_housing_data$flat_type == "MULTI-GENERATION",][,"bedrooms"] <- 3

#head(hdb_housing_data)
#hdb_housing_data
```

Now seperate 'month' column into a year and month column and make them numerical values instead of characters. 
```{r}
hdb_housing_data <- hdb_housing_data %>% separate(month, into = c("Year", "Month"), sep="-")
hdb_housing_data$Year <- as.numeric(hdb_housing_data$Year)
hdb_housing_data$Month <- as.numeric(hdb_housing_data$Month)

```

Edit house level column, make it 2 columns a min and max level. Add average level as well

```{r}
hdb_housing_data <- hdb_housing_data %>% separate(storey_range, into = c("Min_Storey", "Max_Storey"), sep = " TO ")
hdb_housing_data$Min_Storey <- as.numeric(hdb_housing_data$Min_Storey)
hdb_housing_data$Max_Storey <- as.numeric(hdb_housing_data$Max_Storey)
#hdb_housing_data %>% mutate(Average_level = (Min_Storey+Max_Storey)/2)
```

Convert remaining lease into a column with just years.
```{r}
hdb_housing_data$years_remaining <- substr(hdb_housing_data$remaining_lease,1,2)
hdb_housing_data$years_remaining <- as.numeric(hdb_housing_data$years_remaining)
#hdb_housing_data %>% arrange(desc(years_remaining))
```

Finally, convert remaining relevant columns into integers
```{r}
hdb_housing_data$floor_area_sqm <- as.numeric(hdb_housing_data$floor_area_sqm)
hdb_housing_data$resale_price <- as.numeric(hdb_housing_data$resale_price)
hdb_housing_data$lease_commence_date <- as.numeric(hdb_housing_data$lease_commence_date)
housing_data_clean <- hdb_housing_data[,c(6,1,4,15,10,11,12,3,7,8,16)]
hdb_housing_data <- hdb_housing_data %>% mutate(Floor = (Min_Storey+Max_Storey)/2)

```

Convert categorical variables to factors
```{r}
#hdb_housing_data
hdb_housing_data <- read.csv('HDB_Final.csv')

hdb_housing_data$town <- as.factor(hdb_housing_data$town)
hdb_housing_data$flat_model <- as.factor(hdb_housing_data$flat_model)
hdb_housing_data$bedrooms <- as.numeric(hdb_housing_data$bedrooms)
#table(hdb_housing_data$bedrooms)
hdb_housing_data <- hdb_housing_data %>% mutate(age = 2020-lease_commence_date)
```

##### Combining all HDB Towns
Do this to extract the value of all the HDB Towns in Singapore into one list. Then add this to a data frame with their latitidues and longitudes
```{r}
x <- hdb_housing_data %>% group_by(town) %>% summarise(mean(bedrooms))
towns <- as.character(x$town)
towns <- list(towns)
towns <- str_sort(towns[[1]])
#towns
towns_lat_lon <- data.frame(towns, stringsAsFactors = FALSE)
towns_lat_lon$towns <- paste(towns_lat_lon$towns, "Singapore")
head(towns_lat_lon)

```
```{r}
library(ggmap)
register_google("AIzaSyAXGjdqxP4C-E35RBfQC2YpSVhCH653m88")
towns_lat_lon <- mutate_geocode(towns_lat_lon, towns)
towns_lat_lon <- towns_lat_lon %>% rename(town = towns)
#towns_lat_lon <- read.csv("towns_lat_lon.csv")[c(2,3,4)]
#towns_lat_lon
#towns_lat_lon <- towns_lat_lon %>% rename(town = towns)
towns_lat_lon$town <- towns
#towns_lat_lon
#left_join(hdb_housing_data,towns_lat_lon)
#write.csv(towns_lat_lon, "towns_lat_lon.csv")
#towns_lat_lon
```


```{r}
#write.csv(hdb_housing_data,"HDB_Final.csv")
```

### 2.3. Regression

Our regression model is as follows: 

> Regression model: Price ~ FloorArea + Bedrooms + FloorLevel + Town + RemainingLease

<div style="text-align: justify"> 

The above variables were selected for their relevance in determining the price of a HDB flat. For example, the age of the property, which is captured by the number of years left on lease, is quite important. Many flat owners would prefer a longer lease because of reasons such as wanting to leave it for the next generation or seeing it as a long-term investment. Therefore, a longer remaining lease would presumably lead to a higher price. The location of the flat, captured by Town, is another important determinant of a flat’s price. Presumably, flats near central Singapore would be more expensive than units in fringe or less developed areas. Other variables like floor area or bedrooms are more explicit; simply, the larger the house, the higher the price. 

After conducting the regression model, we found that our chosen variables were all relevant as they were all statistically significant (p-value < 0.01) (Figure 1). We thus proceeded to use these variables for the app.

</div>
<center>

![Figure 1. Regression Summary](/Users/David/Documents/school stuff/DBA3702/project/pvalue.png)

</center>
<div style="text-align: justify"> 

We know that sometimes, for some strange reason that can’t be captured by the data, a house's price may be abnormally low (such as a damaged property) or abnormally high (such as a property which has quite lavish furnishings or was previously owned by a prominent figure). We did not want these points to influence our regression variables and outcomes, so we excluded all points with a large cook's distance. The remaining dataset used for the regression still had around 85,000 observations so we did not sacrifice much information. 

This procedure greatly improved the R^2 and standard error of the regression making the tool a lot more accurate and useful for the end user. 

</div>

### 2.4. Visualisation

<div style="text-align: justify"> 

In our app, 4 different types of plots are produced:

  1. **Histogram** <br>It is used to compare relative value of properties.

  2. **Leaflet Map** <br>It is the quickest way to compare price estimates across HDB Towns.

  3. **Bar plot of price estimates for 2 properties to allow for visual comparison of house prices** <br>It is a quick and easy way to compare the magnitude of a handful of items. The average property price for each HDB Town used in the comparison is also included to give the user a greater gauge on just how valuable their theoretical properties are.

  4. **Line plot of HDB Town value over time** <br>This is used to allow the user to see how the average value of similar in the same HDB Town has trended over time. 

</div>

***
    
## 3. Key Functionalities

### 3.1. Price Estimation

<div style="text-align: justify"> 

This app uses a regression model based on the real time HDB flat price data to calculate the estimated price for users. The regression model takes town, address, floor area, number of bedrooms, remaining lease, and floor level into consideration and calculates the estimated price for the user’s property. According to the standard error of our regression model, the price would fluctuate plus or minus $30,000. 

</div>

### 3.2. Map Visualization

<div style="text-align: justify"> 

The map contains information about each town in Singapore. Upon clicking on the circle, the HDB Town, price, number of MRTs, and average price will be shown. In addition, the user can choose to compare the price estimate of each town with the price estimate of other towns, or to compare the price estimate in each town with all Singapore HDB properties on the map.

</div>

### 3.3. Price Comparison

<div style="text-align: justify"> 

The comparison graphs allow users to compare the price of their property against other properties in the same HDB Town, against all other properties in Singapore, or against other properties of the same type in the same area. In doing so, users can see where the price falls in comparison, which helps them better understand the market price and make more informed decisions. With this information, the user can then decide to check the other properties.

</div>

### 3.4. Nearby Amenities

<div style="text-align: justify"> 

By inputting the distance range and address, the user can see what are the nearest amenities such as the nearest primary school, secondary school, tertiary school, MRT, shopping mall, and hawker centre. In addition, the table also shows the walking time to those areas and the number of amenities within the range set by the user. The user can also input an optional work address/point of interest to calculate the distance and time taken from the property to the work address/point of interest.

</div>

### 3.5. Compare Two Properties

<div style="text-align: justify"> 

In the second tab, the user can input two properties to make a comparison. The price estimation will be generated for each property and the price comparison graph will show price for other properties of the same number of bedrooms. The information on nearby amenities for each of the properties are also still provided. In addition, there will be a bar graph comparing the average price of town against the estimated price. There is also a line graph that compares the average price between the two towns. If the user hovers his or her cursor over the line graphs, then it will show the exact price at the point.

</div>

### 3.6. Information on Operation of App

<div style="text-align: justify"> 

In the third tab, the user can get a detailed walkthrough on what each input is for and generally how to use the app such as to obtain the information they want. The tab also provides simple explanations on what the visualisations mean, mitigating the user from feeling confused or lost about how to interpret the information they are given.

</div>

***

## 4. Discussion & Analysis of Output 

<div style="text-align: justify"> 

The functionalities, tools and visualisations in our app not only provide an estimated price of the user’s property with more ease and speed, but also provide additional analysis on the relative value of the property, something which is not offered by other price estimate tools. For users looking to compare 2 property prices, our tools make this process easier and swifter. Information on additional and possibly noteworthy features, amenities, present at the location within a certain proximity of the property is given as well. We have also envisioned this app to act as a complement to property websites. We will further discuss these in detail in this section.

</div>

### 4.1. Price Estimation

<div style="text-align: justify"> 

By removing the need to provide an address to obtain a price estimate, we allow the user to speed up their property search/comparison analysis. For example, if a user wanted to buy a medium sized property that was located close to the central business district, and wanted to see how much such a property should cost, he or she would either have to find such a property on a real estate website (who’s stated price may be inflated), or find the address of such a property and then input this address to a price estimate tool to get a more accurate ‘fair price’ estimate. 

With this tool however, we can generate a theoretical property in any location and obtain an estimate of its fair market price, based on data from over 100,000 HDB flat sales over the last 3 years. The user can then quickly check how much adding say 5sqm of floor area will add to such a property's price, without needing to find the address of a property that was 5sqm larger as they would have to with ordinary pricing estimate tools. 

</div>

### 4.2. Analysis of Visualisations

<div style="text-align: justify"> 

This app can also be used to give existing HDB flat owners a reference point for how to price their property when putting it on the market. It also enables users to better gauge the true value of their property while taking into consideration the current market for other HDB flat properties.

</div>

#### 4.2.1. Histogram

<div style="text-align: justify"> 

The app allows users to identify how valuable their property is, compared to all other properties in Singapore, all other properties in Singapore with the same number of bedrooms, and all other properties in the same HDB Town with the same number of bedrooms (Figure 2).  

</div>
<center>

![Figure 2. Histogram of Queenstown property values within HDB Town](/Users/David/Documents/school stuff/DBA3702/project/fig2.png)

</center>
<div style="text-align: justify"> 

The vertical line represents the house price estimate, while the green areas represent all properties below the price and the red areas represent all properties above the price. This provides the user with a quick and convenient visual tool to compare their properties’ value. Additionally, numerical values allow the user to easily quantify the relative value of the property. 

The user can therefore gauge just how valuable their property is compared to all other HDB flats’ in Singapore or all other HDB flats’ in the planning area. This can give them a better indication of how their properties value stacks up against others in the same area. It can give an owner an indication of the true value of their property, rather than just a numerical value. 

</div>

#### 4.2.2. Mapview

<div style="text-align: justify"> 

The user can compare the price estimate of the theoretical property, by location (HDB Town) via the leaflet map to evaluate the tradeoff between the property’s price and its location (Figure 3).

The map allows us to make a spatial comparison of the price of the user’s property with that of other properties in Singapore in 2 possible ways. The 2 possible methods of comparison are given as 2 options at the top of the map. The first option, which reads “Marker colour is based on a comparison with all Singapore HDB flat properties.”, will provide the comparison of the price of the user’s individual property against the prices of all the individual 100,000 HDB properties from our data. The second option, reading “Marker color is based on a comparison of price estimates by town”, will let the user compare the estimated price of a property from their property’s town with that of other towns.

</div>
<center>

![Figure 3. Map of Singapore with circle markers comparing price estimates](/Users/David/Documents/school stuff/DBA3702/project/fig3.png)

</center>
<div style="text-align: justify"> 

Hence, the 2 possible methods of comparison allow the user to have a general look at where their property’s price is relative to towns as well as a more detailed look at where it is against other individual properties. This also enables possible variation in the estimated price of a property in a town relative to the user's property be taken into consideration. For instance, although the estimated price of a property in Clementi may be higher or around the same as that of a property in Queenstown, the circle marker may indicate that its prices are actually lower when comparing with that in the first option of the map instead. This may mean that the prices are of a wider range in Clementi than in Queenstown. This likely provides the user with more insight on the actual value of their property. Their property may be higher or lower in value than seems when simply looking at the estimated prices.

The colours of the circle markers represent the different price classifications in regards to your property pricing. This enables the users to take a quicker and clearer look at how the prices of other properties are compared to theirs, rather than having to look through 6 digit numbers.

Furthermore, when the user clicks on each circle, they receive a pop-up which provides additional information - the circle’s HDB Town, price of property if it had the same inputs(as what the user selected)  in that town, number of MRTs within range in the area and the average price of all HDB flats in that area. These are crucial points that can help the seller decide if they are able to increase the price of their property listing, or lower it or keep it close to the suggested value. 

</div>
#### 4.2.3. Comparison between Two Properties

<div style="text-align: justify"> 

In order to further assist the user in comparing properties, the app also allows for a more detailed comparison between just two properties which the user chooses. In the second tab, users are able to key in a second property in the same way they would for the first property. The “Property Price Comparison” would be generated for the users. The bar graph displayed will enable the user to compare the two properties’ estimated prices, the property price estimate of the respective towns of the two properties and proceed to compare these information between the two properties (Figure 4). 

</div>
<center>

![Figure 4. Bar graph comparing prices between two properties](/Users/David/Documents/school stuff/DBA3702/project/fig4.png)

</center>
<div style="text-align: justify"> 

This allows the users to better understand the position of their interested properties’ with regards to each other.

Furthermore, there will be a line graph generated which shows the average price of HDB flats in each HDB Town from the respective properties over time (Figure 5). This feature is useful for both home buyers and investors, especially those who may be investing on a short term basis. An investor can view how an area's average HBD value has been trending in recent years, and can help inform their decisions on where to invest and in which type of property. If an area's average value seems to be decreasing in recent years, this may allow an investor to stay clear of investing in this particular area, if its increasing, it may be a good sign to invest. Home buyers may also use this feature to know whether it may be a good idea to wait or buy now depending on the trends depicted in the graph. 

</div>
<center>

![Figure 5. Line graph showing trend of HDB flat value over time](/Users/David/Documents/school stuff/DBA3702/project/fig5.png)

</center>
<div style="text-align: justify"> 

The information previously available in the first tab is provided for each property in the second tab as well. These are the histograms for the respective properties and the respective properties’ information about its distance from nearby amenities, which is further explained in the following. These hence allow users to gain a more comprehensive comparison between properties they are looking at with greater ease than obtaining these information individually from other websites.

</div>

#### 4.3. Distance from Nearby Amenities 

<div style="text-align: justify"> 

Our visualisations also allow the user to compare the distance to nearby amenities of different addresses simply. If a user has found a particular block or address of a property they are interested in and are satisfied with the price estimate provided by the app, he or she could further use our tool to determine the distance from this address to nearby amenities, and compare it with other properties. 

For example if a user finds 2 properties in Queenstown that he or she is interested in, the deciding factor may then be their proximity to nearby amenities such as a school or MRT or even some other Point of Interest (POI) that can be manually added by the user in the optional work/POI amenity input. They may then use our tool to compare how close each HDB flat is to the nearest school, MRT, shopping center and hawker center simultaneously to get a better picture of how convenient the property’s location is. 

</div>
#### 4.4. Integration with Online Tools

<div style="text-align: justify"> 

We noted that our app features and functionalities are quite different from online websites, such as propertyguru. Since our app provides different details and insights in comparison to these websites, we foresee that our app could be a good complement to online websites if not used independently.

For users that have identified a property they like on the website, our tool could be used to give them an idea of what the fair price of that HDB flat should be. Unlike online websites, our app allows for easy comparison of prices to other properties around Singapore. Furthermore,  the price estimates from our app are likely to be more reliable than that given by property agents. The feature of showing different amenities nearby is also unique to our app. Although our app does not display information like the interior of the HDB flat, such information can be found easily online. Thus, by using our app in conjunction with other tools, a user can gain an even more comprehensive view regarding the price estimate of his or her specified property.

</div>

***

## 5. Advantages & Limitations

### 5.1. Advantages

<div style="text-align: justify"> 

Compared to price estimators found on websites like propertyguru or directhome, our app provides a wide range of features that grant it many advantages over other tools in terms of usability, customisation and relevance of information.

</div>

#### 5.1.1 Usability

<div style="text-align: justify"> 

In the primary tool, users are able to easily determine the fair estimated price of a property in their selected HDB Town area, given their input parameters. This value is arguably “fair”, as it is the final transacted price of the resale flat. Our app is also fast, with both tools taking under 10 seconds on average to calculate and display all outputs and visualisations. The app also returns the most updated results as it uses real-time data that is sourced directly from the HDB resale API found on data.gov.sg. 

Furthermore, the layout of the app is such that all relevant information is available on the same page instead of the user having to click to different pages to view specific information. This includes the price estimate, map and graphical visualisations for comparisons, as well as the details of nearby amenities. Our app is also user-friendly as it provides a “How-to-Use” page for new users.

Finally, whereas other online tools require the address field to be filled in, our app allows the user to search for a property price estimate by simply inputting the desired HDB Town. 

</div>

#### 5.1.2. Relevance of Information

<div style="text-align: justify"> 

Many online price estimators only return just that - the price estimate. Our app, however, packs a lot more information that we believe would be useful to users. Firstly, the display of nearby amenities can be further refined through the input of an address. This will help users to know and find out the nearby amenities to a specific HDB flat they are interested in, ensuring that information returned is always relevant to the user.

At a glance, the clear visualisations present useful information on how the flat fares in comparison to others, and also whether that flat may be undervalued or overvalued.

In the second tab, our app supplies even more value by allowing the user to compare specifically between 2 properties. Comparisons between the price estimates, nearby amenities and even the historical price trends of the respective HDB Towns can be made. This would help the user to not only decide on what property to buy or sell, but possibly even when to do so. 

</div>

#### 5.1.3. Customisation

<div style="text-align: justify"> 

Despite being feature-packed and still highly user-friendly, our app still provides a high level of customisation by allowing the user to be very specific about the type of flat that he is searching for. This is done through a large number of selection parameters, all of which can be fine-tuned by the user to minute levels. For example, the user can adjust the size of the property by as little as 1sqm. 

In addition, the user can choose between multiple visualisations for both the graphs and the maps. Graphically, the user can compare his price estimate to other flats in the same HDB Town, across Singapore, or with others of the same type. Mapwise, there is the option of either viewing the property price estimate relative to other HDB Towns with the same input parameters, or the same price estimate relative to all flats in Singapore in different HDB Towns. 

</div>

### 5.2. Limitations

<div style="text-align: justify"> 

Nonetheless, this app does have a few limitations when compared to current online property websites. Firstly, it does not show the details of a specific property available. The interior of a resale flat could possibly be a determinant for buyers. The online website includes pictures of the property and surroundings which may be a factor when it comes to judging whether the price is fair. Secondly, people are unable to view the price of individual flats, only the estimated price of all flats in the HDB Town, given certain input parameters. The estimated price generated by our app is an average price of all HDB resale flats in a given Town. Thus, the app may not be as beneficial for users looking for an estimated price of a specific flat. 

Our app is only able to compare prices for HDB resale flats and not condominiums and landed property. This is due to the difficulty in getting information about such properties, especially the amenities nearby. However, private properties make up a small proportion of the living spaces in Singapore, with HDB flats housing a vast majority of the population. Therefore, we decided to focus our app to only HDB flats.

</div>

***

## 6. Conclusion

<div style="text-align: justify"> 

All in all, we hope that given the unique features of our app, we can make a difference in helping users find a fair estimate price of a HDB resale flat. This app provides users with the ability to speedily and easily compare average property prices, and provide additional information on the properties’ nearby facilities. Although there are certainly limitations in our app, we believe that they can be alleviated by using the app in conjunction with other online tools, which would provide more complete information for the user too. Ultimately, our app provides a sufficiently comprehensive solution to users looking for a way to find an accurate price estimate of their specified resale flat.

</div>
***

## 7. References
  
  1. 99.co. (2019, September 28). Should you buy a BTO or resale HDB flat? What to consider if you're a first-timer. Retrieved from Channel News Asia: https://www.channelnewsasia.com/news/lifestyle/should-you-buy-a-bto-or-resale-hdb-flat-what-to-consider-if-you-11946466
  
  2. Data.gov. (2020, Janurary 2). Estimated Singapore Resident Population in HDB Flats. Retrieved from Data.gov: https://data.gov.sg/dataset/estimated-resident-population-living-in-hdb-flats?resource_id=a7d9516f-b193-4f9b-8bbf-9c85a4c9b61b
  
  3. Fatti, M. (2019). 99.co’s guides: Buying a BTO – The Process & Procedures. Retrieved from 99.co: https://www.99.co/blog/singapore/buying-a-bto-process-procedures/
  
  4. Poh, J. (2018, March 27). What Can You Do To Get An Accurate Price Estimate On Singapore Property As a Buyer or Seller?Retrieved from MoneySmart: https://blog.moneysmart.sg/property/price-estimate-singapore-property/



