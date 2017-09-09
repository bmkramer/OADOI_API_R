# OADOI API - R script

Based on a similar attempt for [querying the Dissemin API] (https://github.com/bmkramer/Dissemin_API_R) 

##Description
This script uses the OADOI API to get information on online availability (gold and green Open Access) of academic articles, identified by their DOI, as well as publisher policies on archiving. 

[OADOI API documentation] (https://oadoi.org/api) [OADOI API v2 documentation] (https://oadoi.org/api/v2)
 
[OADOI documentation] (https://oadoi.org/about)

##Input / output
This script uses as input a csv file with a list of doi's in a column labeled "DOI"

The output is a dataframe (written to a csv file) with, for each DOI, the following information from the Dissemin API:
  - DOI: original DOI used as input
  - data_standard: data collection approache(s) used for this resource (Crossref API only or broader hybrid detection)
  - is_oa: true if there is an OA copy of this resource
  - journal_is_oa: true for journals included in DOAJ
  - journal_issns: any ISSNs assigned to the journal publishing this resource
  - journal_name (not fully normalized)
  - publisher
Additional information for best* OA location (if any) (*publisher over repository, published version over author version, authoritative repository over less authoritative repository
  - evidence: how OA location (if any) was found
  - host_type: type of host that serves this OA location (publisher or repository)
  - license: license under which this article copy is published (e.g. specific CC license, publisher license, "implied OA"
  - versions: the content version accessible at this location (submitted version, accepted version, published version)
  - URL: URL where you can find this OA copy
 
##Caveats / issues
  - The script uses loops (bad R!), if someone can improve this using an apply-function, please do! 
  - The script currently stops executing when it encounters a HTTP status 404 for one of the DOIs checked. 
    - This could probably be circumvented with try.catch(), but I don't know how (yet)
    - In the current setup, the script can be rerun manually, skipping the offending DOI by resetting the loop counter. 
    
    I'm sure there is a more elegant solution! 

##The script
[DOI_queries_OADOI_API_v2.R](https://github.com/bmkramer/OADOI_API_R/blob/master/DOI_queries_OADOI_API_v2.R)
