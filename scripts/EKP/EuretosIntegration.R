library(httr)
library(jsonlite)

## connect to Euretos server with login credentials of 
login <- "http://178.63.49.197:8080/spine-ws/login/authenticate"
pars <- list(
  username = "a.gavai@esciencecenter.nl",
  password = "hwZi5VVPqNfGNbzTxa3"
)

res <- POST(login, body = pars,encode="json",verbose())

token <- content(res)$token


## Search for concept ids 
# Input parameters
body =  fromJSON('{ "queryString": "term:\u0027egfr\u0027 AND taxonomies:\u0027Homo Sapiens\u0027", "searchType": "STRING" }')

query = "/external/taxonomies"

###

base_url <- "http://178.63.49.197:8080/spine-ws"

# Execute the query
pr <- POST(url = paste(base_url, query, sep =""), 
          add_headers('X-token' = token),
          body=fromJSON('{ "additionalFields":["publicationIds", "tripleIds", "predicateIds"], 
   "leftInputs": [ "4047995" ], "relationshipWeightAlgorithm": "PWS", "rightInputs": [ 
   "3062402", "12345" ], "sort": "ASC" }',"&page=",2),
          encode = "json", 
          accept_json(),verbose())

a<-content(pr)


pages <- list()
for(i in 0:10){
  mydata <- fromJSON(paste0(base_url, "&page=", i), flatten=TRUE)
  message("Retrieving page ", i)
  pages[[i+1]] <- mydata$filings
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

