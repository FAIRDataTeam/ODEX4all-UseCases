library(httr)
library(jsonlite)
library(magrittr)

## connect to Euretos server with login credentials of 
login <- "http://178.63.49.197:8080/spine-ws/login/authenticate"
pars <- list(
  username = "a.gavai@esciencecenter.nl",
  password = "hwZi5VVPqNfGNbzTxa3"
)

res <- POST(login, body = pars,encode="json",verbose())

token <- content(res)$token


## Search for concept ids 
# Input parameters make sure the single quotes are removed for the term
query = "/external/concepts/search"

###

base_url <- "http://178.63.49.197:8080/spine-ws"


####### DSM work flow starts here ###############

setwd("/home/anandgavai/ODEX4all/ODEX4all-UseCases/scripts/EKP/DSM")
yeast_genes<-read.csv("yeast_genes_sgdID.csv",header=TRUE)


# Execute the query
pr <- POST(url = paste(base_url, query, sep =""), 
           add_headers('X-token' = token),
           body=fromJSON('{ "queryString": "term:s000004214", "searchType": "STRING" }'),
           encode = "json", 
           accept_json(),verbose())
a<-content(pr)

for (i in 1:length(yeast_genes)){
  b<-paste0("'{",'"queryString":"term:',yeast_genes[i,],'","searchType":"STRING"',"}'")
  
  pr <- POST(url = paste(base_url, query, sep =""), 
             add_headers('X-token' = token),
             body=b,
             encode = "json", 
             accept_json(),verbose())
  a<-content(pr)
}



##########################################################
query<- "/external/semantic-categories"
gr = GET(
  url = paste(base_url, query, sep =""),
  add_headers('X-token' = token),
  body=fromJSON('{"additionalFields": ["egfr"]}'),
  encode = "json",
  accept_json()
)

content(gr)

