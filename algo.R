# Load dictionary

if (!exists("fullDict")) {
        fullDict <- read.table("data/out1.txt", stringsAsFactors=FALSE,
                             fill = TRUE, header = TRUE)
}

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
