#this script uses the OADOI API to get information on online availability (gold and green Open Access) 
#of academic articles, identified by their DOI, as well as publisher policies on archiving. 
#OADOI API information: https://oadoi.org/api
#OAIDOI documentation: https://oadoi.org/about

#input and output
#this script uses as input a csv file with a list of doi's in a column labeled "DOI"
#the output is a dataframe (written to a csv file) with for each DOI, the following information from the Dissemin API:
#- DOI: original DOI used as input
#- DOI_resolver: CrossRef or DataCite
#- evidence: the step of the OA detection process where the free fulltext URL was found, if any
#- free_fulltext_URL: URL where free full text is found, if any
#- is-subscription_journal: true whenever the journal is not in DOAJ or DataCite 
#- license: name of CC-license associated with free_fulltext_url. Example: "cc-by".
#- oa_color: green or gold, if any
#- URL: canonical DOI URL 

#caveats / issues
#1) the script uses loops (bad R!, and places a heavy load on OADOI's servers), if someone can improve this using an apply-function, you're most welcome! 
#2) the script currently stops executing when it encounters a HTTP status 404 for one of the DOIs checked.
#this could probably be circumvented with try.catch(), but I don't know how (yet);
#in the current setup, the script can be manually rerun from line 38, 
#skipping the offending DOI by resetting the loop counter in line 74.

#install packages
install.packages("rjson")
install.packages("httpcache")
require(rjson)
require(httpcache)
#import csv with DOIs; csv should contain list of doi's in column labeled "DOI"
DOI_input <- read.csv(file="xxx.csv", header=TRUE, sep=",")

#create empty dataframe with 8 columns
df <- data.frame(matrix(nrow = 1, ncol = 8))
#set column names of dataframe
colnames(df) = c("DOI", "DOI_resolver", "evidence", "free_fulltext_URL", "is_subscription_journal", "license", "oa_color", "url")

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
#employ naIfNull function because not all values are always present in OADOI API output.
getData <- function(doi){
  doi_character <- as.character(doi)
  #enter your email address in the line below (replace your@email.com), this helps OADOI contact you if something is wrong
  url <- paste("https://api.oadoi.org/",doi,"?email=your@email.com",sep="")
  raw_data <- GET(url)
  rd <- httr::content(raw_data)
  first_result <- rd$results[[1]]
  result <- c(
    doi_character,
    naIfNull(first_result$doi_resolver),
    naIfNull(first_result$evidence),
    naIfNull(first_result$free_fulltext_url),
    naIfNull(first_result$is_subscription_journal),
    naIfNull(first_result$license),
    naIfNull(first_result$oa_color),
    naIfNull(first_result$url)
    )
  return(result)
}

#fill dataframe df (from 2nd row onwards) with API results for each DOI from original dataset
#use counter approach to be able to test/run on subsets of data, and to manually jump any rows giving a 404 error
#when jumping rows by changing counter, rerun the script from line 38. This way, results are added to the same dataframe 
#reset counter range to fit number of rows in source file
for (i in 1:100){
  df <- rbind(df,getData(DOI_input$DOI[i]))
}

#alternatively, to try out the script, block lines 74-76, 
#and run the script with lines 80-82 instead, using 3 example DOIs with different outputs. 
#df <- rbind(df,getData("10.1016/j.paid.2009.02.013"))
#df <- rbind(df,getData("10.1001/archderm.1986.01660130056025"))
#df <- rbind(df,getData("10.1002/0471140856.tx2306s57"))

write.csv(df, file="OADOI_API_results.csv", row.names=FALSE)
