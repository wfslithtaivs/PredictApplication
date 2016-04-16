# Load dictionary

if (!exists("dict1")) {
        dict1 <- read.csv("data/uni.csv", stringsAsFactors=FALSE)
}
if (!exists("dict2")) {
        dict2 <- read.csv("data/bigrams.csv", stringsAsFactors=FALSE)
}
if (!exists("dict3")) {
        dict3 <- read.csv("data/trigrams.csv", stringsAsFactors=FALSE)
}

## Trim spaces in dictionaries

# dict1 <- gsub(" ", "", dict1)
# dict2 <- gsub(" ", "", dict2)
# dict3 <- gsub(" ", "", dict3)

## Merge dictionaries

dict2$first <- NA; dict2 <- dict2[c(4, 1, 2, 3)]
fullDict <- rbind(dict2, dict3)



# Return preprocessed word and number of components
preprocess <- function(x){
        k <- tolower(x) # to lower case
        k <- enc2native(k) # convert to native encoding
        k <- gsub("[[:digit:]]", "", k) # remove numbers 
        ## Remove punctuation, preserve intrawords dashes
        k <- gsub("(\\w)-(\\w)", "\\11\\2", k)
        k <- gsub("[[:punct:]]+", "", k)
        k <- gsub("1", "-", k, fixed = TRUE)
        k <- gsub("\ {2,}", " ", k) # trim white spaces 
        k <- gsub(" $", "", k) # trim the end spaces
        # Return preprocessed word and number of components
        len <- length(strsplit(k, " ")[[1]])
        if (len >= 3 ){
        k <- data.frame("one" = strsplit(k, " ")[[1]][len - 2], 
                        "two" = strsplit(k, " ")[[1]][len -1], 
                        "three" = strsplit(k, " ")[[1]][len],
                        stringsAsFactors = FALSE)
        }
        if (len == 2){
                k <- data.frame("one" = NA, 
                                "two" = strsplit(k, " ")[[1]][len -1], 
                                "three" = strsplit(k, " ")[[1]][len],
                                stringsAsFactors = FALSE)
        }
        
        if (len == 1){
                k <- data.frame("one" = NA, 
                                "two" = NA, 
                                "three" = strsplit(k, " ")[[1]][len],
                                stringsAsFactors = FALSE)
                
        }
        if (len == 0) {
                k <- data.frame("one" = NA, "two" = NA, "three" = NA, stringsAsFactors = FALSE)
        }
        
        return(k)
}