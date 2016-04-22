#---------------------------------------------------
# setwd("/home/kate/final/en_US")
# list.files()
train <- read.table("/home/kate/final/en_US/train.txt", header = TRUE, stringsAsFactors = FALSE, fill=TRUE)

options( java.parameters = "-Xmx24g" );

library(RWeka); library(dplyr)

# Tokenizing function
tok = function(x) NGramTokenizer(x, Weka_control(min = 1, max = 4, delimiters=' '))

# Term Frequency Evaluation
eval_tf <- function (input) {
        data <- data.frame(src = input);
        data$pre <- tolower(data$src);
        # All the numbers
        data$pre <- gsub("[0-9#][^ ]*", " TN ", data$pre);
        # Multiple spaces to a single space
        data$pre <- gsub(" +", " ", data$pre);
        # Replace punctuations (..., ., ?, !) with a special token
        data$pre <- gsub("[\\.\\?\\!]+", " TS ", data$pre);
        # Filter out words only (maybe some numbers if still left)
        data$pre <- gsub("[^A-Za-z0-9' ]", " ", data$pre);
        # Space series again
        data$pre <- gsub(" +", " ", data$pre);

        tokens <- tok(data$pre);
        tf = data.frame(w = as.character(tokens), f = 1, stringsAsFactors=FALSE);
        tfl = dplyr::summarise(group_by(tf, w), f = sum(f));

        return (tfl);
}

# Learn dictionaries with data chunks
set.seed(4759)

#trunc(length(train[, 1])/100)
#length(train[, 1]) - trunc(length(train[, 1])/100)*100

# Index partitions for train data

ind <- matrix(c(1:(trunc(length(train[, 1])/100)*100)), ncol = 100)

x1 <- data.frame(w = character(), f = numeric(), stringsAsFactors = FALSE)

for (i in 1:100) {
        print(paste0("Eval ", i))
        x2 <- eval_tf(train[ind[1:length(ind[, 1]), i], ])
        print(paste0("Merge ", i))
        x1 <- dplyr::summarise(group_by(rbind(x1, x2), w), f = sum(f))
}


# Merge dictionaries
merge_tfs <- function (t1, t2) {
        print(paste0("Merge"))
        return(dplyr::summarise(group_by(rbind(t1, t2), w), f = sum(f)));
}

eval_all <- function(input, n, m){
        if (m - n > 50000) {
                z = (n + m) / 2;
                return(merge_tfs(eval_all(input, n, z), eval_all(input, z, m)));
        }
        else
        {
                print(paste0("Eval from ", n, " to ", m))
                return(eval_tf(input[c(n:(m-1)), ]));
        }

}

tf_tab <- eval_all(train, 1, length(train[ ,1]))
write.table(tf_tab, "/home/kate/final/en_US/tf_tab.txt", sep = "\t");
dics <- read.table(tf_tab, "/home/kate/final/en_US/tf_tab.txt", sep = "\t")


x1 = eval_tf(train[ind[1:length(ind[, 1]), 1], ])
x2 = eval_tf(train[ind[1:length(ind[, 1]), 2], ])
rbind(x1, x2)


# x1 = eval_tf(train[sample(1:nrow(train), 25, replace = FALSE), ])




# Learn dictionaries with data chunks
x1 = eval_tf(sample(train, size = 25));




x2 = eval_tf(sample(twitter, size = 100000));
x3 = merge_tfs(x1, x2);

# TODO: build dictionaries - learn and merge

# Result: ngram dictionary
tf_tab <- ungroup(x3)

# x3[x3$f > 50,]

# parent - n-1 gram
tf_tab$parent <- sub(" ?[A-Za-z0-9']+$", "", tf_tab$w) # \\w+ - doesn't work??
# n-1 gram frequency
dict = dplyr::left_join(tf_tab, tf_tab, by = c("parent" = "w"));
colnames(dict) <- c("w", "f", "parent", "pf", "grand_parent")
dict$prob <- dict$f / dict$pf

dict[dict$parent == "how do you", ]
dict[dict$parent == "do you", ]
dict[dict$parent == "you", ]


#---------------------------------------------------




tf_tab$wl <- strsplit(tf_tab$w, " ");
tf_tab$n <- sapply(tf_tab$wl, "length");

tf_tab$w <- NULL

g = c(1, 2, 3, 4, 5)
head(g, -1)

tf_tab[tf_tab$f > 5000 & tf_tab$n > 1, ]$wl

build_ngram_tf <- function(vMin, vMax, data) {
        # Term matrix
        dtm <- DocumentTermMatrix(Corpus(VectorSource(unlist(data$pre))),
                                  control = list(tokenize = function(x) NGramTokenizer(x,
                                                                                       Weka_control(min = vMin, max = vMax, delimiters=' '))));

        # Convert to data frame
        dtm.tmp = as.matrix(dtm);

        tf_tab <- data.frame(
                w = as.character(colnames(dtm.tmp)),
                f = colSums(dtm.tmp),
                stringsAsFactors = FALSE,
                row.names = NULL);

        tf_tab$wl <- strsplit(tf_tab$w, " ");
        tf_tab$n <- sapply(tf_tab$wl, "length");

        tf_tab$w <- NULL

        return(tf_tab);
}

tf_tab = build_ngram_tf(1, , data);

d1 = tf_tab[(tf_tab$n != 1) | (tf_tab$f > 1),]
d2 = tf_tab[tf_tab$n == 2,]

# Term matrix
dtm <- DocumentTermMatrix(Corpus(VectorSource(unlist(data$pre))), control = list(wordLengths = c(1, 12)));

# Convert to data frame
dtm.tmp = as.matrix(dtm);
tf_tab <- data.frame(w1 = as.character(colnames(dtm.tmp)), f1 = colSums(dtm.tmp), stringsAsFactors=FALSE)
tf_tab = tf_tab[tf_tab$f1 > 1,]

dtm.matrix <- as.matrix(dtm)

Sentences <- sapply(asylym$data, function(x){
        y <- unlist(strsplit(x, "\\.|\\?|[\\!]"))
        y <- trimws(y)
        y <- tolower(y)
        y[nchar(y) > 1 & !is.na(y)]
})

corT <- get5(twitter, tw); corB <- get5(blogs, bl); corN <- get5(news, nw)

asylym <- data.frame(rbind(corT, corB, corN), stringsAsFactors = FALSE)
names(asylym) <- "data"

Sentences <- sapply(asylym$data, function(x){
        y <- unlist(strsplit(x, "\\.|\\?|[\\!]"))
        y <- trimws(y)
        y <- tolower(y)
        y[nchar(y) > 1 & !is.na(y)]
})

as <- data.frame(matrix(unlist(Sentences), byrow=TRUE))
head(as, 20)

# Packages
library(tm); library(SnowballC)
# Preprocessing
# Convert Data to Corpus
data <- Corpus(VectorSource(as))
# Removing punctuation
data <- tm_map(data, removePunctuation)
# Removing numbers:
data <- tm_map(data, removeNumbers)
# # Converting to lowercase:
# data <- tm_map(data, tolower)
# Removing common word endings (e.g., “ing”, “es”, “s”), stemming
# data <- tm_map(data, stemDocument)
# Stripping unnecesary whitespace from your documents:
data <- tm_map(data, stripWhitespace)
# After preprocessing make sure to tell R to treat documents as text documents
data <- tm_map(data, PlainTextDocument)

# Creating document-term matrix (unigrams)
dtm <- DocumentTermMatrix(data, control = list(wordLengths = c(1, 12)))
dtm.matrix <- as.matrix(dtm)
v <- sort(colSums(dtm.matrix),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v, stringsAsFactors = FALSE)

# d[d$freq < 2, ]$word <- "UNKN"
# grep("UNKN", d, value = TRUE)
# d$word <- apply(d, 1, function(x){if(x.freq < 2) x.word <- "UNKN"})

# Generating Bigrams
library(RWeka)
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
txtTdmBi <- TermDocumentMatrix(data, control = list(tokenize = BigramTokenizer))
txtTdmBi.matrix <- as.matrix(txtTdmBi)
v2 <- sort(rowSums(txtTdmBi.matrix),decreasing=TRUE)
d2 <- data.frame(word = names(v2),freq=v2)

# Generating Trigrams
TrigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 3, max = 3))
txtTdmTri <- TermDocumentMatrix(data, control = list(tokenize = TrigramTokenizer))
txtTdmTri.matrix <- as.matrix(txtTdmTri)
v3 <- sort(rowSums(txtTdmTri.matrix),decreasing=TRUE)
d3 <- data.frame(word = names(v3),freq=v3)

# Generating Quadrograms
QuadroTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 4, max = 4))
txtTdmQuo <- TermDocumentMatrix(data, control = list(tokenize = QuadroTokenizer))
txtTdmQuo.matrix <- as.matrix(txtTdmQuo)
v4 <- sort(rowSums(txtTdmQuo.matrix),decreasing=TRUE)
d4 <- data.frame(word = names(v4),freq=v4)

# Generating Pentagrams
PentaTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 5, max = 5))
txtTdmPen <- TermDocumentMatrix(data, control = list(tokenize = PentaTokenizer))
txtTdmPen.matrix <- as.matrix(txtTdmPen)
v5 <- sort(rowSums(txtTdmPen.matrix),decreasing=TRUE)
d5 <- data.frame(word = names(v5),freq=v5)


# Top N-grams summary
k <- data.frame(head(d, 10), head(d2, 10), head(d3, 10), head(d4, 10), head(d5, 10))
row.names(k) <- NULL
names(k) <- c("Unigrams", "UniFrequency", "Bigrams", "BiFrequency",
              "Trigrams", "TriFrequency", "Quadrigrams", "Quadriquency", "Pentagrams", "Pentaquency")
k

library(stringr)
#
# sillyPredict <- function(x, n){
#         i2 <- grep(paste0("^", x," \\w"), d2$word, value = TRUE)[1]
#         i3 <- grep(paste0("^",i2, " "), d3$word, value = TRUE)[1]
#         res <- i3; i3r <- i3
#         for(i in 1:n){
#                 i3r <- str_extract(i3r, '\\w+ \\w+$')
#                 i4 <- grep(paste0("^",i3r, " "), d3$word, value = TRUE)[1]
#                 i3r <- str_extract(i4, '\\w+ \\w+$')
#                 res <- paste(res, str_extract(i4,'\\w+$'))
#         }
#         return(res)
# }
# sillyPredict("of", 3)
# sillyPredict("the", 15)
# sillyPredict("i", 15)


# "The cat, in the ?"

# d5[grep("the cat in the hat", d5$word), ]
# d4[grep("^cat in the", d4$word), ]
# head(d3[grep("^in the ", d3$word), ], 15)
# d2[grep("^the", d4$word), ]


# Split n-grams into word-columns

## Unigrams
head(d)
d$probs <- d$freq/sum(d$freq)
## Bigrams
head(d2)
d2$w <- strsplit(as.character(d2$word), " ")
d2$w1 <- sapply(d2$w, '[[', 1)
d2$w2 <- sapply(d2$w, '[[', 2)
d2$w <- NULL
head(d2)
## Trigrams
head(d3)
d3$w <- strsplit(as.character(d3$word), " ")
d3$w1 <- sapply(d3$w, '[[', 1)
d3$w2 <- sapply(d3$w, '[[', 2)
d3$w3 <- sapply(d3$w, '[[', 3)
d3$w <- NULL
head(d3)
## Quadrirams
head(d4)
d4$w <- strsplit(as.character(d4$word), " ")
d4$w1 <- sapply(d4$w, '[[', 1)
d4$w2 <- sapply(d4$w, '[[', 2)
d4$w3 <- sapply(d4$w, '[[', 3)
d4$w4 <- sapply(d4$w, '[[', 4)
d4$w <- NULL
head(d4)
## Pentagrams
head(d5)
d5$w <- strsplit(as.character(d5$word), " ")
d5$w1 <- sapply(d5$w, '[[', 1)
d5$w2 <- sapply(d5$w, '[[', 2)
d5$w3 <- sapply(d5$w, '[[', 3)
d5$w4 <- sapply(d5$w, '[[', 4)
d5$w5 <- sapply(d5$w, '[[', 5)
d4$w <- NULL
head(d5)

d$w1 <- d$word
head(d)

## Probabilities

t1=data.frame(w1=d$w1, f1=d$freq, p = d$probs, stringsAsFactors = FALSE);
t2=data.frame(w1=d2$w1, w2=d2$w2, f2=d2$freq, stringsAsFactors = FALSE);
t3=data.frame(w1=d3$w1, w2=d3$w2, w3=d3$w3, f3=d3$freq, stringsAsFactors = FALSE);
t4=data.frame(w1=d4$w1, w2=d4$w2, w3=d4$w3, w4=d4$w4, f4=d4$freq, stringsAsFactors = FALSE);
t5=data.frame(w1=d5$w1, w2=d5$w2, w3=d5$w3, w4=d5$w4, w5=d5$w5, f5=d5$freq, stringsAsFactors = FALSE);

clean2 <- merge(t2, t1, by="w1"); #, all.x = TRUE)
clean2$p <- clean2$f2 / clean2$f1
clean2 = subset(clean2, select=c("w1", "w2", "p"))

clean2[sample(1:nrow(clean2), 20), ];

clean3 <- merge(t3, t2, by=c("w1", "w2")); #, all.x = TRUE)
clean3$p <- clean3$f3 / clean3$f2
clean3 = subset(clean3, select=c("w1", "w2", "w3", "p"))

clean3[sample(1:nrow(clean3), 20), ]

clean4 <- merge(t4, t3, by=c("w1", "w2", "w3")); #, all.x = TRUE)
clean4$p <- clean4$f4 / clean4$f3
clean4 = subset(clean4, select=c("w1", "w2", "w3", "w4", "p"))

clean4[sample(1:nrow(clean4), 20), ]

clean5 <- merge(t5, t4, by=c("w1", "w2", "w3", "w4")); #, all.x = TRUE)
clean5$p <- clean5$f5 / clean5$f4
clean5 = subset(clean5, select=c("w1", "w2", "w3", "w4", "w5", "p"))

clean5[sample(1:nrow(clean5), 20), ]

write.table(t1, "unigram.txt", sep = "\t")
write.table(clean2, "bigram.txt", sep = "\t")
write.table(clean3, "trigram.txt", sep = "\t")
write.table(clean4, "quagram.txt", sep = "\t")
write.table(clean5, "pengram.txt", sep = "\t")
