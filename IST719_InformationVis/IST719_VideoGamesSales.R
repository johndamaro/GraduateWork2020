#
# John D'Amaro
# Final Project
# IST 719 
#
install.packages("waffle", repos = "https://cinc.rud.is")
install.packages("hrbrthemes")

library(ggplot2)
library(reshape2)
library(magrittr)
library(hrbrthemes)
library(tidyverse)
library(treemap)
library(waffle)

setwd("C:\\Users\\user\\Desktop\\IST 719 - Information Vis\\Final Project\\")

vgsales <- read.csv(paste0("VideoGamesSales.csv")
                    , header = TRUE
                    , stringsAsFactors = FALSE)
unique(vgsales$Year_of_Release)
## Data Cleaning
#Removing rows with empty data
vgsales[vgsales$Name == "", ]
vgsales <- vgsales[-c(660, 14247), ]

#Renaming specific records
unique(vgsales$Platform)
vgsales$Platform[vgsales$Platform == "GB"] <- "GameBoy"
vgsales$Platform[vgsales$Platform == "GBA"] <- "GameBoyAdv"
vgsales$Platform[vgsales$Platform == "XB"] <- "Xbox"
vgsales$Platform[vgsales$Platform == "PS"] <- "PlayStation"
vgsales$Platform[vgsales$Platform == "2600"] <- "Atari2600"
vgsales$Platform[vgsales$Platform == "GC"] <- "GameCube"
vgsales$Platform[vgsales$Platform == "GEN"] <- "Genesis"
vgsales$Platform[vgsales$Platform == "DC"] <- "DreamCast"
vgsales$Platform[vgsales$Platform == "PSV"] <- "PSVita"
vgsales$Platform[vgsales$Platform == "SAT"] <- "SegaSaturn"
vgsales$Platform[vgsales$Platform == "SCD"] <- "SegaCD"
vgsales$Platform[vgsales$Platform == "WS"] <- "WonderSwan"
vgsales$Platform[vgsales$Platform == "NG"] <- "NeoGeo"
vgsales$Platform[vgsales$Platform == "TG16"] <- "TurboGrafx-16"
vgsales$Platform[vgsales$Platform == "GG"] <- "GameGear"

#Subsetting data with Scores
scored <- vgsales[!is.na(vgsales$User_Score) & !is.na(vgsales$Critic_Score), ]

scored$Critic_Score <- scored$Critic_Score/10

unique(vgsales$Genre)

#################################################################

## General Score CriticvUser
par(mfrow = c(1,2), mar = c(6,4,4,2), bty = "n")
critic.by.genre <- scored$Critic_Score~scored$Genre
user.by.genre <- scored$User_Score~scored$Genre

boxplot(critic.by.genre, main = "Distribution of Critic Score per Genre"
        , ylab = "Score", xlab = "", las = 2, ylim = c(0,10), notch = TRUE
        , pch = 16, whisklty = 1, staplelty = 0, col = "cornflowerblue")

boxplot(user.by.genre, main = "Distribution of User Score per Genre"
        , ylab = "Score", xlab = "", las = 2, ylim = c(0,10), notch = TRUE
        , pch = 16, whisklty = 1, staplelty = 0, col = "mediumaquamarine")

## More sophisticated box plot by genre differing critic & user
par(mfrow = c(1,1))
dat.m <- melt(scored, id.vars = 'Genre'
            , measure.vars = c('Critic_Score','User_Score'))

colnames(dat.m) <- c("Genre", "Individual", "Score")

p <- ggplot(dat.m) + aes(x=Genre, y=Score, fill=Individual) +
  geom_boxplot(notch = TRUE, notchwidth = 0.3
               , outlier.alpha = 0.2) +
  facet_wrap(~Genre, scale="free")

p + scale_fill_manual(values = c("cornflowerblue", "mediumaquamarine")) + 
    ggtitle("Do Critics Opinions Differ?") +
  theme(
    strip.text.x=element_blank(),
    legend.background = element_blank(),
    legend.key        = element_blank(),
    strip.background  = element_blank(),
    panel.grid = element_line(colour = "grey88"),
    panel.grid.minor = element_line(size = rel(0.5)),
    panel.background  = element_blank(),
    
    complete = TRUE
  )


critic10 <- scored[order(-scored$Critic_Score, -scored$Critic_Count), ]
critic10 <- head(critic10, n = 10)

user10 <- scored[order(-scored$User_Score, -scored$User_Count), ]
user10 <- head(user10, n = 10)
user10

## Top 10 User/Critic Games Table
top10 <- cbind(user10$Name, user10$Platform, user10$User_Score
       , critic10$Name, critic10$Platform, critic10$Critic_Score)
colnames(top10) <- c("User's Top 10", "Platform", "Score"
                   , "Critics' Top 10", "Platform", "Score")
View(top10)

#################################################################

## Time Series Sales Data
yeardata <- vgsales[vgsales$Year_of_Release != "N/A", ]
yeardata <- yeardata[yeardata$Year_of_Release != "2020", ]
yeardata <- yeardata[yeardata$Year_of_Release != "2017", ]

#Global Sales by year
sales.by.year <- aggregate(yeardata$Global_Sales
                         , list(yeardata$Year_of_Release)
                         , sum)
colnames(sales.by.year) <- c("Year", "GlobalSales")

#NA Sales by year
sales.us <- aggregate(yeardata$NA_Sales
                    , list(yeardata$Year_of_Release)
                    , sum)
colnames(sales.us) <- c("Year", "NASales")

#EU Sales by year
sales.eu <- aggregate(yeardata$EU_Sales
                      , list(yeardata$Year_of_Release)
                      , sum)
colnames(sales.eu) <- c("Year", "EUSales")

#JP Sales by year
sales.jp <- aggregate(yeardata$JP_Sales
                      , list(yeardata$Year_of_Release)
                      , sum)
colnames(sales.jp) <- c("Year", "JPSales")

#Other Sales by year
sales.o <- aggregate(yeardata$Other_Sales
                      , list(yeardata$Year_of_Release)
                      , sum)
colnames(sales.o) <- c("Year", "OtherSales")

## Times Series of Sales by Geographic throughout the years
par(mar = c(5,5,4,2), mfrow = c(1,1))
plot(sales.by.year$Year, sales.by.year$GlobalSales
     , type = "l", col = "darkslategray", bty = "n", lwd = 3
     , xlab = "Year", ylab = "Sales (million units)"
     , main = "Global Gross Sales")
lines(sales.by.year$Year, sales.us$NASales, col = "cornflowerblue", lwd = 2)
lines(sales.by.year$Year, sales.eu$EUSales, col = "mediumaquamarine", lwd = 2)
lines(sales.by.year$Year, sales.jp$JPSales, col = "tomato", lwd = 2)
lines(sales.by.year$Year, sales.o$OtherSales, col = "violet", lwd = 2)
legend("topleft", lty=c(1,1,1,1), lwd = c(3,2,2,2), bty = "n"
       , legend=c("Global Sales","NA Sales","EU Sales", "JP Sales", "Other Sales")
       , col=c("darkslategray", "cornflowerblue"
               , "mediumaquamarine", "tomato", "violet"))

##Top Five top Selling games each jump in sales
top1996 <- yeardata[yeardata$Year_of_Release=="1996", ]
top1996 <- head(top1996, n = 5)

top2002 <- yeardata[yeardata$Year_of_Release=="2002", ]
top2002 <- head(top2002, n = 5)

top2009 <- yeardata[yeardata$Year_of_Release=="2009", ]
top2009 <- head(top2009, n = 5)

top2009

## The year where Japan starts to decrease
yeardata[yeardata$Year_of_Release=="2009", ]

#################################################################
str(genre.by.year)
genre.by.year <- aggregate(yeardata$Global_Sales
                           , list(
                             yeardata$Genre
                           , yeardata$Year_of_Release)
                           , sum)
colnames(genre.by.year) <- c("Genre", "Year", "GlobalSales")

genre.by.year <- transform(genre.by.year, Year = as.numeric(Year))

ggplot(genre.by.year) + 
  aes(x = Year, y = GlobalSales) +
  geom_area(aes(color = Genre, fill = Genre), 
            alpha = 0.8, position = position_dodge(1))+
  scale_fill_brewer(palette = "RdYlBu")
  
genre.by.year$Genre <- replace(as.character(genre.by.year$Genre), genre.by.year$Genre == "Role-Playing", "RPG")

#ggplot(genre.by.year, aes(x=Year, y=GlobalSales, col=Genre)) + geom_line()

p <- treemap(genre.by.year,
             # data
             index=c("Genre", "Year"),
             vSize="GlobalSales",
             type="value",
             
             # Main
             title="Genre Popularity Throughout the Ages",
             palette=grey.colors(12
                               , start = 0, end = 0.6
                               , alpha = .7),
             
             # Borders:
             border.col=c("black", "white", "grey"),             
             border.lwds=c(2,1.75,0.1),                     
             
             # Labels
             fontsize.labels=c(12, 10, 8),
             fontcolor.labels=c("white", "white", "black"),
             fontface.labels=2,            
             bg.labels=c("transparent"),              
             align.labels=list(c("center", "center")
                             , c("left", "top"))
             , overlap.labels=0)

genre.by.year
#################################################################

View(vgsales)

sales.by.platform <- aggregate(vgsales$Global_Sales
                             , list(vgsales$Platform)
                             , sum)
colnames(sales.by.platform) <- c("Platform", "GlobalSales")

sales.by.platform <- sales.by.platform[order(
                     sales.by.platform[,2],decreasing=FALSE),]

sales.by.platform <- sales.by.platform[sales.by.platform[2] > 10,]

par(mar = c(4,6,3,2), mfrow = c(1,1))
barplot(sales.by.platform$GlobalSales
      , names.arg = sales.by.platform$Platform
      , las = 1, horiz = TRUE, cex.names = .75
      , border = NA
      , col = "darkslategrey"
      , xlab = "Sales (millon units)"
      , main = "Global Sales of Video Games per Platform")
###########
######################################################

top25alltime <- vgsales[order(vgsales$Global_Sales
                            , decreasing = TRUE), ]

View(top25alltime)
gametable <- table(top25alltime$Name,top25alltime$Platform)
#################################################################

genre.by.year <- genre.by.year[order(genre.by.year[,2], genre.by.year[,3], decreasing = TRUE), ]

quant.genre <- c(genre.by.year[genre.by.year$Year == 2016, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2015, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2014, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2013, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2012, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2011, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2010, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2009, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2008, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2007, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2006, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2005, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2004, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2003, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2002, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2001, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 2000, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1999, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1998, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1997, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1996, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1995, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1994, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1993, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1992, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1991, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1990, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1989, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1988, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1987, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1986, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1985, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1984, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1983, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1982, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1981, ][1:5, 1])
quant.genre <- append(quant.genre,genre.by.year[genre.by.year$Year == 1980, ][1:5, 1])

genre.df <- data.frame(table(quant.genre))
genre.df <- genre.df[order(genre.df[,2], decreasing = TRUE), ]
colnames(genre.df) <- c("Genre", "Freq")

legend <- reorder(genre.df$Genre, genre.df$Freq)

ggplot(genre.df, aes(fill=legend, values=Freq)) +
  geom_waffle(color="white", flip = TRUE, n_rows = 10) + theme_minimal() + coord_equal() + 
  theme_enhance_waffle() + scale_fill_manual(
    values = 
      c("#454545", "#575757", "#6A6A6A", "#7D7D7D"
      , "#909090", "#A3A3A3", "#B6B6B6", "#C9C9C9"
      , "#66ddaa", "#6495ed", "#ff6347","#EE82EE")) +
  theme(legend.key.height = unit(1.5, "line")) +
  theme(legend.text = element_text(size = 11, hjust = 0, vjust = 0.75)) + labs(title = "Top Genres Throughout the Years")

#   "#EE82EE", "#ff6347", "#6495ed", "#66ddaa"
# , "#C9C9C9", "#B6B6B6", "#A3A3A3", "#909090"
# , "#7D7D7D", "#6A6A6A", "#575757", "#454545"








