# Examples of use.
# 
# 
# In these examples I have seperated the functions that do the work
# from the actual work.  You can use the functions as you would use
# a normal R package (except it is of course not yet a package).
# The following script is a walkthrough. 
# 
# We need the following packages to be loaded.
# If they are not installed. they will be.
# Logical test, if the package is not installed, install it.####
if(!library(httpcache,logical.return = TRUE)){install.packages("httpcache")}
if(!library(jsonlite,logical.return = TRUE)){install.packages("jsonlite")}
library(jsonlite)
library(httpcache)

### I make the assumption that you are in the working directory and that the 
### functions script is in the same working directory.
# load the functions that do the work.
# The functions are contained in the file DOI_queries_OADOI_API.R
source("DOI_queries_OADOI_API.R")

#import csv with DOIs; csv should contain list of doi's in column labeled "DOI"
#DOI_input <- read.csv(file="xxx.csv", header=TRUE, sep=",") 
## if you want to be specific about the file you can use the line above, but the defaults are also fine.
DOI_input <- read.csv("tests/doi_examples.csv")

# To use the api we need to strep the "DOI:"-part
# I have created a function that checks if the doi is character and 
# if it is, removes the "DOI" part. 
# If nothing special is going on, there will be no warnings and the 
# dataframe is transformed.
DOI_input <- validate_doi(DOI_input, "DOI")

# then we loop through the information and get the results back.
# the results are put into a dataframe and are returned.
# If there are many many DOI's this will take a while. 
# It is not optimized in any way. I believe the API has the option to bulk
# send data. But untill we have implemented that in some way a new request
# is made for every doi.
downloaded_doi_info <- download_all_doi_info(DOI_input$DOI)

# You might want to write that resulting file back to disk.
write.csv(downloaded_doi_info, file="OADOI_API_results.csv", row.names=FALSE)
