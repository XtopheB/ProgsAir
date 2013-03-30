# Created march 8, 2013 by christophe
# Creation of an HTML dynamic file for data exploration 

## D abord on efface tout silencieusement...
rm(list=ls())

## Second change the working directory

#setwd("D:/progs/Air/progs")   
setwd("C:/Chris/zprogs/Air/progs")   

library("googleVis")
library("foreign")

## Partie I: Reading the data (All years) 

fichier ="AllyearsKLEM.dta"
dataall <- read.dta(paste("../data/",fichier, sep=""))  

dim(dataall)
Mydata <- data.frame(dataall)

# New unit for Y, K, E 
Mydata$Y <- Mydata$Y/1000
Mydata$K <- Mydata$K/1000
Mydata$E <- Mydata$E/1000
Mydata$M <- Mydata$M/1000

### SUBSET of "BIG AIRLINES" !!
MyBigdata <-subset(Mydata, Y> quantile(Y, .75, na.rm = TRUE)  & Test0 > 0) 

## Subset of airlines at least present once !!
Workdata <-subset(Mydata, Test0 > 0)

## Part 2 :  On crée l'objet à visualiser 

#M <- gvisMotionChart(Workdata, idvar="carrier", timevar="year")
M.big <- gvisMotionChart(MyBigdata, idvar="carrier", timevar="year",  xvar="K", yvar="Y", 
                         colorvar="Region", sizevar="L", 
                         options=list(width=400, height=420))

# la visualisation se fait dans le navigateur !!
# Personalisation de la page
M.big$html$caption = " Big Airline Database (MyBigData)"

# Creation de la page 
#plot(M)
plot(M.big)

# On crée une planisfère 
G.big<-gvisGeoChart(MyBigdata, "country", "Y",
             options=list(width=220, height=150))

G.big<-gvisGeoChart(MyBigdata, "country", "Y",
                    options=list(displayMode="Markers", 
                    colorAxis="{colors:['purple', 'red', 'orange', 'grey']}",
                    backgroundColor="lightblue"))
plot(G.big)

# On va aussi créer une table 
T.big <- gvisTable(MyBigdata,  options=list(page='enable', pageSize= 200))
plot(T.big)

#On combine carte et table
GT <- gvisMerge(G.big,T.big, horizontal=FALSE)
# On combine le tout
MGT <- gvisMerge(GT, M.big,horizontal=TRUE, tableOptions="bgcolor=\"#CCCCCC\" cellspacing=10")
# Tracé Final 

plot(MGT)

 


