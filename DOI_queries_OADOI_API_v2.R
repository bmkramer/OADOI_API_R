#this script uses the OADOI API to get information on online availability (gold and green Open Access) 
#of academic articles, identified by their DOI, as well as publisher policies on archiving. 
#OADOI API information: https://oadoi.org/api and https://oadoi.org/api/v2
#OAIDOI documentation: https://oadoi.org/about

#input and output
#v2
#this script uses as input a csv file with a list of doi's in a column labeled "DOI"
#the output is a dataframe (written to a csv file) with for each DOI, the following information from the OADOI API
#for the best* OA location (if any)
#*(publisher over repository, published version over author version, authoritative repository over less authoritative repository)
#- DOI: original DOI used as input
#- data_standard: data collection approache(s) used for this resource (Crossref API only or broader hybrid detection)
#- is_oa: true if there is an OA copy of this resource
#- journal_is_oa: true for journals included in DOAJ
#- journal_issns: any ISSNs assigned to the journal publishing this resource
#- journal_name (not fully normalized)
#- publisher
#additional information for best* OA location (if any) (*publisher over repository, published version over author version, authoritative repository over less authoritative repository)
#- evidence: how OA location (if any) was found
#- host_type: type of host that serves this OA location (publisher or repository)
#- license: license under which this article copy is published (e.g. specific CC license, publisher license, "implied OA"
#- versions: the content version accessible at this location (submitted version, accepted version, published version)
#- URL: URL where you can find this OA copy

#caveats / issues
#1) the script uses loops (bad R!), if someone can improve this using an apply-function, you're most welcome! 
#2) the script currently stops executing when it encounters a HTTP status 404 for one of the DOIs checked.
#this could probably be circumvented with try.catch(), but I don't know how (yet);
#in the current setup, the script can be manually rerun from line 38, 
#skipping the offending DOI by resetting the loop counter in line 87.

#install packages
#install.packages("rjson")
#install.packages("httpcache")
require(rjson)
require(httpcache)
#import csv with DOIs; csv should contain list of doi's in column labeled "DOI"
DOI_input <- read.csv(file="xxx.csv", header=TRUE, sep=",")

#create empty dataframe with 12 columns
df <- data.frame(matrix(nrow = 1, ncol = 12))
#set column names of dataframe
colnames(df) = c("DOI", "data_standard", "is_oa", "evidence", "host_type", "license", "versions", "URL", "journal_is_oa", "journal_issns", "journal_name", "publisher")

naIfNull <- function(cell){
  if(is.null(cell)) {
    return(NA)
  } else {
    return(cell)
  }
}

#define function to get data from OADOI API and construct vector with relevant variables;
#this vector will become a row in the final dataframe to be produced;
#define doi.character as character for doi to be included as such in the vector;
#employ naIfNull function because not all values are always present in OADOI output.
getData <- function(doi){
  doi_character <- as.character(doi)
  #enter your email address in the line below (replace your@email.com), this helps OADOI contact you if something is wrong
  url <- paste("https://api.oadoi.org/v2/",doi,"?email=your@email.com",sep="")
  raw_data <- GET(url)
  rd <- httr::content(raw_data)
  first_result <- rd
  best_location <- rd$best_oa_location
  result <- c(
    doi_character,
    naIfNull(first_result$data_standard),
    naIfNull(first_result$is_oa),
    naIfNull(best_location$evidence),
    naIfNull(best_location$host_type),
    naIfNull(best_location$license),
    naIfNull(best_location$version),
    naIfNull(best_location$url),
    naIfNull(first_result$journal_is_oa),
    naIfNull(first_result$journal_issns),
    naIfNull(first_result$journal_name),
    naIfNull(first_result$publisher)
    )
  return(result)
}


#fill dataframe df (from 2nd row onwards) with API results for each DOI from original dataset
#use counter approach to be able to test/run on subsets of data, and to manually jump any rows giving a 404 error
#reset counter range to fit number of rows in source file
for (i in 1:10){
  df <- rbind(df,getData(DOI_input$DOI[i]))
}

#alternatively, to try out the script, block lines 87-88, 
#and run the script with lines 93-95 instead, using 3 example DOIs with different outputs. 
#df <- rbind(df,getData("10.1016/j.paid.2009.02.013"))
#df <- rbind(df,getData("10.1001/archderm.1986.01660130056025"))
#df <- rbind(df,getData("10.1002/0471140856.tx2306s57"))

write.csv(df, file="OADOI_API_v2_results.csv", row.names=FALSE)
