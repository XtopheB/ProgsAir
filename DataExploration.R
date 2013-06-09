# Created march 8, 2013 by christophe
# Creation of an HTML dynamic file for data exploration 
# 01/04/2013 : Customized for Steve and Nath

## D abord on efface tout silencieusement...
rm(list=ls())

## Second change the working directory

setwd("C:/Chris/zprogs/Air/progs/")   

## Partie I: Reading the data (All years) 
# On prend le fichier ave tous les inputs et outputs 30/03 

dataall <- read.dta(paste("../data/MultiYKLEM.dta")) # file is in ../data

dim(dataall)
Mydata <- data.frame(dataall)

# New unit for Y, K, E 
Mydata$Y <- Mydata$Y/1000
Mydata$K <- Mydata$K/1000
Mydata$E <- Mydata$E/1000
Mydata$M <- Mydata$M/1000

### SUBSET of "BIG AIRLINES" + Selection on files with test0 != NA
MyBigdata <-subset(Mydata, Y> quantile(Y, .75, na.rm = TRUE)  & Test0 > 0) 

# ## Partie II; Install the libraries (To do ONLY ONCE !)
#install.packages("googleVis")
#install.packages("foreign")

#load the libraries
library("googleVis")
library("foreign")

## Part III :  On crie l'objet ?? visualiser 

M.big <- gvisMotionChart(MyBigdata, idvar="carriername", timevar="year",  xvar="K", yvar="Y", 
                         colorvar="Region", sizevar="L", 
                         options=list(width=400, height=420))

# Creation de la page,  la visualisation se fait dans le navigateur !!
plot(M.big)


# Second graphique 
# On cr??e une planisph??re 

G.big<-gvisGeoChart(MyBigdata, "country", "Y",
                    options=list(displayMode="Markers", 
                    colorAxis="{colors:['purple', 'red', 'orange', 'grey']}",
                    backgroundColor="lightblue"))
plot(G.big)

# On va aussi crier une table 
T.big <- gvisTable(MyBigdata,  options=list(page='enable', pageSize= 200))
plot(T.big)


 


