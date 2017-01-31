#Template
#https://www.eu-sol.wur.nl/fair/v1/germplasm/EA00258

library(rrdf)
library(rrdflibs)
library(RMySQL)
library(sqldf)


setwd("/home/anandgavai/Documents/ODEX4all/R_Scripts")

#setwd("\\\\psf\\Home\\Desktop\\Fair_BreeDB")

# Access the local database

mydb = dbConnect(MySQL(), user='root', password='p051D0n10', dbname='breedb', host='localhost')
table_list<- dbListTables(mydb)
field_names<- dbListFields(mydb, 'pp_accession')
dat = dbGetQuery(mydb, "select * from pp_accession") # result remains on the MySQL database

#dat<-read.csv("pp_accession.csv",header=TRUE)
# Selection for FAIR

lat_long<-paste(dat[,"gpsLat"],dat[,"gpsLong"],sep=",")

#dat<-dat[,c("accessionID","accessionName","fromGenebankID","taxonomyID","collectionDate")]
dat<-dat[,c("accessionID","taxonomyID","fromGenebankID","germplasmStatus","collectionDate")]

dat<-cbind(dat,lat_long)
dat<-dat[,c(1,6,2,3,4,5)]


dat<-read.csv("EA00258.csv",header=TRUE)
dat[]<-lapply(dat,as.character)


fairStore<-new.rdf(ontology=FALSE)


### Start adding  prefixes "Remememer always to end prefixes with either "#" or "/" :-)
add.prefix(fairStore,"accID","https://www.eu-sol.wur.nl/passport/SelectAccessionByAccessionID.do?accessionID=")
add.prefix(fairStore,"lat_long","http://www.w3.org/2003/01/geo/wgs84_pos#")
add.prefix(fairStore,"sName","http://openlifedata.org/taxonomy/")
add.prefix(fairStore,"donorID","http://purl.org/cgngenis/accenumb/")
add.prefix(fairStore,"bStatus","http://purl.org/germplasm/germplasmType#cultivatedHabitat/")

add.prefix(fairStore,"accnNum","http://www.cropontology.org/terms/CO_715:0000227/Accession number/")


#Addition of predicates

plat_long<-"http://www.w3.org/2003/01/geo/wgs84_pos#lat_long"
pScientificName <-"http://rs.tdwg.org/dwc/terms/scientificName"
pDonorID<-"http://purl.org/germplasm/germplasmTerm#donorsID"
pBiologicalStatus<-"http://purl.org/germplasm/germplasmTerm#biologicalStatus"
pAcquisitionDate<-"http://purl.org/germplasm/germplasmTerm#acquisitionDate"
pCollectingEvent<-"http://purl.org/germplasm/germplasmTerm#CollectingEvent"
pGermplasmID<-"http://purl.org/germplasm/germplasmTerm#germplasmID"

createFairEntry<- function(row){
  accessionID<-row[1]
  lat_long<-row[2]
  taxonomyID<-paste("http://openlifedata.org/taxonomy:",row[3],sep="")
  fromGenebankID<-paste("http://purl.org/cgngenis/accenumb/",row[4],sep="")
  germplasmStatus<-paste("http://purl.org/germplasm/germplasmType#",row[5],sep="")
  collectionDate<-row[6]
  
  
  # Subject
  acnID<- paste("https://www.eu-sol.wur.nl/passport/SelectAccessionByAccessionID.do?accessionID=",accessionID,sep="")


#  add.triple(fairStore,acnID,accessionID,aID)

  #Predicates
  add.data.triple(fairStore,acnID,plat_long,lat_long)
  add.triple(fairStore,acnID,pScientificName,taxonomyID)
  add.triple(fairStore,acnID,pDonorID,fromGenebankID)
  add.triple(fairStore,acnID,pBiologicalStatus,germplasmStatus)
  add.data.triple(fairStore,acnID,pAcquisitionDate,collectionDate)
  add.data.triple(fairStore,acnID,pGermplasmID,accessionID)
}

apply(dat, MARGIN=1, FUN=createFairEntry)


save.rdf(fairStore, "FAIR_Profile.ttl","TURTLE")
save.rdf(fairStore,"FAIR_Profile.n3","N3")
save.rdf(fairStore,"FAIR_Profile.ntriple","N-TRIPLE")
#save.rdf(fairStore,"FAIR_Profile.rdfxml","RDF/XML")
cat(asString.rdf(fairStore))



