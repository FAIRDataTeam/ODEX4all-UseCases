setwd("/home/anandgavai/Documents/ODEX4all/R_Scripts")

library(RMySQL)
library(rrdf)
library(rols)
library(paxtoolsr) # Access Pathway information in owl format
library(sqldf)  # Check Ontobee for a more comprehensive


mydb = dbConnect(MySQL(), user='root', password='xxxxxx', dbname='breedb', host='localhost')
table_list<- dbListTables(mydb)

field_names<- dbListFields(mydb, 'pp_accession')



dat = dbGetQuery(mydb, "select * from pp_accession") # result remains on the MySQL database

# Select latitude,longitude, collectionsitecountry, collectionSite, province

rs<-dat[,c("accessionID","accessionName","gpsLat","gpsLong","collectionSiteCountry","collectionSite","collectionSiteProvence")]
rs<-rs[which(rs[,"gpsLat"]!="NA"),]


# Filter for selected germ plasm field 
# https://www.eu-sol.wur.nl/fair/v1/germplasm/EA00258

# Example row 5693


sample_data<-rs[,c("accessionID","accessionName")]



# desc<- dbGetQuery(mydb,"desc pp_accession ;") # get the description of the table metadata



# Create a triple store for each column make sure the primary key is the first column 
# sample_data is table with 2 columns, prefix_pred is the prerix uri, type is the datatype of the column
# Create Triple store for data literals
create_triple_store_literal<-function(sample_data,prefix_pred,type){
  # Create a triple store
  store = new.rdf(ontology=TRUE)
  for (i in 1:dim(sample_data)[1]){
    subject=paste("https://www.eu-sol.wur.nl/fair/v1/germplasm/",sample_data[i,1],sep="")
    predicate=paste(prefix_pred,colnames(sample_data[2]),sep="")
    data=sample_data[i,2]
    type=type 
    add.data.triple(store,subject,predicate,data,type)
  }
  save.rdf(store,paste(colnames(sample_data)[2],".ttl",sep=""),"TURTLE")
}




# Create Triple store for data objects
create_triple_store_object<-function(sample_data,prefix_pred,prefix_object){
  # Create a triple store
  store = new.rdf(ontology=TRUE)
  for (i in 1:dim(sample_data)[1]){
    subject=paste("https://www.eu-sol.wur.nl/fair/v1/germplasm/",sample_data[i,1],sep="")
    predicate=paste(prefix_pred,colnames(sample_data[2]),sep="")
    data=sample_data[i,2]
    object=paste(prefix_object,data,".html",sep="") 
    add.triple(store,subject,predicate,object)
  }
  save.rdf(store,paste(colnames(sample_data)[2],".ttl",sep=""),"TURTLE")
}


# Create triple store for accessionName
rs<-dat
rs<-rs[,c("accessionID","accessionName")]
prefix_pred = "http://example.org/Predicate/"
type="string"
create_triple_store_literal(rs,"http://example.org/Predicate/","string")

# Create triple store for accessionDescription
ss<-dat
ss<-ss[,c("accessionID","accessionDescription")]
prefix_pred = "http://example.org/Predicate/"
type="string"
create_triple_store_literal(ss,"http://example.org/Predicate/","string")



# Create triple store for location (latitude and longitude included)
# Standards used for latitute and longitude ISO-3166 alpha2
# URL http://www.geonames.org/countries/

rs<-dat[c(536,566,568,2701,5693),] # non empty GPS coordinates
rs<-rs[,c("accessionID","gpsLat","gpsLong")]
location<-paste(rs[,"gpsLat"],rs[,"gpsLong"],sep="_")
rs<-cbind(rs[,"accessionID"],location)
colnames(rs)<-c("accessionID","GPS_Location")
# http://www.geonames.org/maps/wikipedia_-0.90_-89.61.html # format for latitude and longitude 
create_triple_store_object(rs,"http://example.org/Predicate/","http://www.geonames.org/maps/wikipedia_")

# Create triple store for 


## GPS cordinates with non-empty values
 dat[which(dat[,11]!="NA"),c(11,13)]
:q!
   


