# Created march 8, 2013 by christophe
# Creation of an HTML dynamic file for data exploration 

## D abord on efface tout silencieusement...
rm(list=ls())

## Second change the working directory

#setwd("D:/progs/Air/progs")   
setwd("C:/Chris/zprogs/Air/progs")   

#load the libraries
library("googleVis")
library("foreign")

## Partie I: Reading the data (All years) 
# On prend le fichier ave tous les inputs et outputs 30/03 

#fichier ="AllyearsKLEM.dta"
fichier ="MultiYKLEM.dta"

dataall <- read.dta(paste("../data/",fichier, sep=""))

dim(dataall)
Mydata <- data.frame(dataall)

# New unit for Y, K, E 
Mydata$Y <- Mydata$Y/1000
Mydata$K <- Mydata$K/1000
Mydata$E <- Mydata$E/1000
Mydata$M <- Mydata$M/1000

### SUBSET of "BIG AIRLINES" + Selection on files with test0 != NA
MyBigdata <-subset(Mydata, Y> quantile(Y, .75, na.rm = TRUE)  & Test0 > 0) 

## Subset of airlines at least present once !!
Workdata <-subset(Mydata, Test0 > 0)

## Part 2 :  On crie l'objet ` visualiser 

#M <- gvisMotionChart(Workdata, idvar="carrier", timevar="year")
M.big <- gvisMotionChart(MyBigdata, idvar="carrier", timevar="year",  xvar="K", yvar="Y", 
                         colorvar="Region", sizevar="L", 
                         options=list(width=400, height=420))

# la visualisation se fait dans le navigateur !!
# Personalisation de la page
M.big$html$caption = " Big Airline Database (MyBigData)"

# Creation de la page 
plot(M.big)

# second graphique 
# On crie une planisfhre 
G.big<-gvisGeoChart(MyBigdata, "country", "Y",
             options=list(width=220, height=150))

G.big<-gvisGeoChart(MyBigdata, "country", "Y",
                    options=list(displayMode="Markers", 
                    colorAxis="{colors:['purple', 'red', 'orange', 'grey']}",
                    backgroundColor="lightblue"))
plot(G.big)

# On va aussi crier une table 
T.big <- gvisTable(MyBigdata,  options=list(page='enable', pageSize= 200))
plot(T.big)

#On combine carte et table
GT <- gvisMerge(G.big,T.big, horizontal=FALSE)
# On combine le tout
MGT <- gvisMerge(GT, M.big,horizontal=TRUE, tableOptions="bgcolor=\"#CCCCCC\" cellspacing=10")
# Traci Final 

plot(MGT)

 


