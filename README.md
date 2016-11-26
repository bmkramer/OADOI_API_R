# OADOI API - R script

Based on a similar attempt for [querying the Dissemin API] (https://github.com/bmkramer/scihub_netherlands/blob/Dissemin_API_R/README.md) 

##Description
This script uses the OADOI API to get information on online availability (gold and green Open Access) of academic articles, identified by their DOI, as well as publisher policies on archiving. 

[OADOOI API documentation] (https://oadoi.org/api)
 
[OADOI documentation] (https://oadoi.org/about)

##Input / output
This script uses as input a csv file with a list of doi's in a column labeled "DOI"

The output is a dataframe (written to a csv file) with, for each DOI, the following information from the Dissemin API:
  - DOI: original DOI used as input
  - DOI_resolver: CrossRef or DataCite
  - evidence: the step of the OA detection process where the free fulltext URL was found, if any
  - free_fulltext_URL: URL where free full text is found, if any
  - is-subscription_journal: true whenever the journal is not in DOAJ or DataCite 
  - license: name of CC-license associated with free_fulltext_url. Example: "cc-by".
  - oa_color: green or gold, if any
  - URL: canonical DOI URL 
 
##Caveats / issues
  - The script uses loops (bad R!, and places a heavy load on OADOI's servers), if someone can improve this using an apply-function, please do! 
  - The script currently stops executing when it encounters a HTTP status 404 for one of the DOIs checked. 
    - This could probably be circumvented with try.catch(), but I don't know how (yet)
    - In the current setup, the script can be rerun manually, skipping the offending DOI by resetting the loop counter. 
    
    I'm sure there is a more elegant solution! 

##The script
[DOI_queries_OADOI_API.R](https://github.com/bmkramer/scihub_netherlands/blob/OADOI_API_R/DOI_queries_OADOI_API.R)
