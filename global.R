library(readxl)
library(dplyr)
library(tidyr)
library(sf)
df <- read_xlsx("dataset/data_hmo.xlsx")
univs <- read_xlsx("dataset/univ_loc.xlsx", sheet = "used")
yogya_peta <-  st_read("map/peta_desa_yogya.shp") 

##### Functions

#########
## Data Wrangling
#########
cm <- cor(df$price_monthly, df[57:66])
cmdf <- data.frame(Amenities = colnames(cm), `Correlation` = cm[1,])
facilities <- df[c(73:99,18,11)]
names_facil <- colnames(facilities)[1:27]
df['min_month'] <- factor(df$min_month, levels = c("1", "2-4","5-8", "12"))
chars <- colnames(df)[c(5,37,72)]
char_vc <- c("Inside Bathrooms", "WiFi", "AC", "Sitting Closet", "Mattress")
