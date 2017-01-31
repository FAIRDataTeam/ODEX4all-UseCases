library(RMySQL)
library(rrdf)
library(sqldf)

mydb = dbConnect(MySQL(), user='root', password='p051D0n10', dbname='breedb', host='localhost')
table_list<- dbListTables(mydb)

field_names<- dbListFields(mydb, 'pp_accession')



rs = dbGetQuery(mydb, "select * from pp_accession") # result remains on the MySQL database

# Filter for selected germ plasm field 
# https://www.eu-sol.wur.nl/fair/v1/germplasm/EA00258

# Example row 5693

# sample_data<-rs[1:5,c("accessionID","accessionName","gpsLat_txt","gpsLong_txt","taxonomyID","dateCreated")]

sample_data<-rs[,c("accessionID","accessionName")]


# desc<- dbGetQuery(mydb,"desc pp_accession ;") # get the description of the table metadata


#create triple data.frame for first accession name


# Create a triple store
store = new.rdf()

for (i in 1:dim(sample_data)[1]){
  subject=paste("https://www.eu-sol.wur.nl/fair/v1/germplasm/",sample_data[i,1],sep="")
  predicate=paste("http://example.org/Predicate/",colnames(sample_data[2]),sep="")
  object=sample_data[i,2]
  add.triple(store,subject,predicate,object)
}
save.rdf(store,"pp_accession.ttl","TURTLE")








