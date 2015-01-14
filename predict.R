#============================================================
# load libraries
#============================================================
library(stringr)
library(data.table)
#library(tm)
#library(wordcloud)

#============================================================
###prediction function
# word <- "Whose line is it anyway? Isn't it Jeff's? This is a very long line! With 3,000 words! zzzz ahahaha, ahhahh''#@@!_-++=''' We'll have to wait for a long time....Possibly 15 minutes. Very very bad bad bad!!!"
# line_input <- "I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the"

#============================================================
# helper functions to clean input and extract words
#============================================================
line_clean <- function(line) {
        ###clean the input and return words for prediction
        
        # convert all lines to lowercase
        line <- tolower(line) 
        
        # replace terms that may be confusing after punctuation cleaning
        line <- gsub(" it's ", " it is ", line) 
        line <- gsub(" 's ", " is ", line) 
        line <- gsub(" you'r ", " you are ", line) 
        line <- gsub(" i'd ", " i would ", line) 
        line <- gsub(" he'd ", " he would ", line) 
        line <- gsub(" she'd ", " she would ", line) 
        line <- gsub(" we'd ", " we would ", line) 
        line <- gsub(" i'll ", " i will ", line) 
        line <- gsub(" he'll ", " he will ", line) 
        line <- gsub(" she'll ", " she will ", line) 
        line <- gsub(" we'll ", " we will ", line) 
        line <- gsub(" we're ", " we were ", line) 
        line <- gsub(" who're ", " who are ", line) 
        
        # replace - with space
        line <- gsub("-", " ", line) 
        
        # remove single quotes
        line = gsub("'", "", line)
        
        # remove punctuations except apostrophes
        line <- gsub("[^\\w' ]|_", " ", line, perl=T)  
        # line <- gsub("[^[:alnum:][:space:]']", " ", line)
        
#         # remove extra single quotes # not needed anymore
#         line <- gsub("^' ' | ' ' | ' |''| ' ", " ", line)
#         line <- gsub("^' ' | ' ' | ' |''| ' ", " ", line) # catch ' left by first go
        
        # remove numbers
        line <- gsub("\\(?[0-9,.]+\\)?", " ", line)
        
        ##remove extra spaces
        remove_space <- function(x) return(gsub("^ *|(?<= ) | *$", "", x, perl=T))
        line <- remove_space(line) 
        # http://stackoverflow.com/questions/14737266/removing-multiple-spaces-and-trailing-spaces-using-gsub
        # this uses a positive lookbehind to see if the current space is preceded by a space
        # "^ *|(?<= ) | *$" this pattern gets leading, trailing, and in-between

        # remove characters repeated 3 or more times
        line <- gsub('(.)\\1{2,}', '\\1\\1', line)
        
        # remove 2-character strings  repeated 2 or more times
        line <- gsub('(..)\\1{2,}', '\\1\\1', line)
        
        # remove 3-character strings  repeated 2 or more times
        line <- gsub('(...)\\1{2,}', '\\1\\1', line) 
        
        # remove repeated words
        for (i in 1:3){
                line <- gsub('(.+) \\1{1,}', '\\1', line, perl=TRUE) #!!! not working completely. have to be repeated
        }

        ##remove extra spaces
        line <- remove_space(line)      
        
        return(line)
} 

#wclean <- line_clean(word)
# lclean <- line_clean(line_input)

#============================================================
# remove or replace and extract words

replace_unk <- function(clean_line){
        ### replace words not in dict with 'unkn'
        # load corpus-based dictionary
        dict <- fread("dict.txt", header=F)
        word <- unlist(str_split(clean_line," "))
        word[!(word %in% dict$V1)] <- 'unkn'
        return(word)
}

# l_unk <- replace_unk(lclean)
# w_unk <- replace_unk(wclean)

get_ng_words <- function(word){
        ### get up to two preceding words from input, including stopwords for ngrams
        # word <- unlist(str_split(clean_line," "))
        # print(word)
        len <- length(word)
        
        if (len == 1){
                if (word == "") return(NULL)
                else return(word)
        }
        if (len > 1){
                return(tail(word,2)) 
        }
        else{
                print("Warning: no words exacted!")
                return(NULL)
        }

} 

# get_ng_words(w_unk)
# ng_words <- get_ng_words(l_unk)

get_skg_words <- function(word){
        ### get up to three words from input for skipgram
        #word <- unlist(str_split(clean_line," "))
        # load stopword list
        stwd <- fread("SMART_eng_stopwords2.txt", header=F)
        
        word <- word[!(word %in% stwd$V1)]
        # print(word)
        len <- length(word)
        
        if (len == 1){
                if (word == "") return(NULL)
                else return(word)
        }
        if (len == 2){
                return(word)
        }
        if (len >= 3){
                #return(tail(word,3)) 
                return(tail(word,2)) # for tg nostop
        }
        else{
                print("Warning: no skg words exacted!")
                return(NULL)
        }
        
} 

#skg_words <- get_skg_words(l_unk)

#============================================================
# get top words and their probabilities from ngram and skip grams
#word <- c('quite', 'some')
pngram <- function(word){
        len <- length(word)
        #print(len)
        # read uigram
        filename <- unzip("ug_prob.csv.zip")
        object.size(ug <- fread(filename))
        file.remove("ug_prob.csv") 
        wprob1 <- ug
        print("ug read")
        rm(ug)
        
        if (len == 2){
                # read trigram
                filename <- unzip("tg_prob_top20_noa.csv.zip")
                object.size(tg <- fread(filename))
                file.remove("tg_prob_top20_noa.csv") # remove unzipped file for save disk space
                wprob3 <- head(tg[w1 == word[1] & w2 == word[2], list(w3, prob3)], 20)
                print("tg read")
                #print(wprob3)
                # summary(tg$prob) # 25% = 0.013720
                rm(tg) # remove trigram to free up memory
                
                # read bigram
                filename <- unzip("bg_prob_top20_noa.csv.zip")
                object.size(bg <- fread(filename))
                file.remove("bg_prob_top20_noa.csv") 
                wprob2 <- head(bg[w1 == word[2], list(w2, prob2)], 20)
                print("bg read")
                #print(wprob3)
                rm(bg)
                
#                 # read uigram
#                 filename <- unzip("ug_prob.csv.zip")
#                 object.size(ug <- fread(filename))
#                 file.remove("ug_prob.csv") 
#                 wprob1 <- ug
#                 #cut_ug <- median(ug$prob1) * 3  # ~ 3rd quartile, for unigram discounting
#                 #cut_ug <- mean(ug$prob1)
#                 cut_ug <- 0.005
#                 rm(ug)

#                 ug[w1 == 'a'] <- 0.9 
                
                # merge tables
                setkey(wprob3, w3)
                setkey(wprob2, w2)
                
                unique_keys <- unique(c(wprob3[,w3], wprob2[,w2]))
                ng23 <- wprob2[wprob3[J(unique_keys)]]
                setkey(ng23, w2)
                # subset unigram table
                wprob1 <- wprob1[wprob1$w1 %in% ng23$w2]
                setkey(wprob1, w1)
                
                unique_keys <- unique(c(wprob1[,w1], ng23[,w2]))
                ng23 <- ng23[wprob1[J(unique_keys)]]
                setnames(ng23, "w2", "w")
                ng23$prob2[is.na(ng23$prob2)] <- 0
                ng23$prob3[is.na(ng23$prob3)] <- 0
                ng23$prob1[is.na(ng23$prob1)] <- 0.1 # underweigh words not in ug (tg??)
                
                print("New Run")
                # print(ng23)
                # calculate weighted probability
                #cut_ug <- rep(cut_ug, length(ng23$prob1))
#                cut_ug_div <- pmax(ng23$prob1, cut_ug)
                cut_ug_div <- 1.0 - ng23$prob1
                cut_ug_div <- cut_ug_div * cut_ug_div 
                ng23$cut_ug_div <- cut_ug_div
                ng23$prob23 <- ng23$prob2 * cut_ug_div * 0.2 + ng23$prob3 * cut_ug_div * 0.8 # need to apply machine learning to optimize
                setkey(ng23, prob23)
                ng23 <- ng23[order(-prob23)]
                
                
                # print(ng23)
                #ng23[, c('prob2', 'prob3'):=NULL]
                if (!(max(ng23$prob23) < (0.000078))){ # first quantile of bg program
                        #ng23 <- data.frame(ng23)
                        ng23 <- head(ng23, 20)
                        return(ng23)
                
                }
                # back off to unigram if prob is too low
               else {
                       print("prob23 too low")
                       # read uigram
#                        filename <- unzip("ug_prob.csv.zip")
#                        object.size(ug <- fread(filename))
#                        file.remove("ug_prob.csv") 
#                        wprob1 <- head(ug[, list(w1, prob1)], 20)
#                        rm(ug)
                        #ng23$prob12 <- ng23$prob1 * cut_ug_div * 0.2 + ng23$prob3 * cut_ug_div * 0.8 

                       # calculate weighted probability
                       ng23$prob12 <- ng23$prob2 * cut_ug_div #ng12$prob1 * 0.001 + ng12$prob2 * 0.999 # need to apply machine learning to optimize
                       setkey(ng23, prob12)
                       ng23 <- ng23[order(-prob12)]
                }
                #ng23 <- data.frame(ng23)
                #ng23[, c('prob2', 'prob3', 'prob1', 'cut_ug_div'):=NULL]
                ng23 <- head(ng23, 20)
                return(ng23)
        }
        if (len == 1){
                print("1-word input")
                # read bigram
                filename <- unzip("bg_prob_top20_noa.csv.zip")
                object.size(bg <- fread(filename))
                file.remove("bg_prob_top20_noa.csv") 
                wprob2 <- head(bg[w1 == word[1], list(w2, prob2)], 20)
                rm(bg)
                #summary(bg$prob) # 25% = 0.000078
                #print(wprob2)
                # subset unigram table
                wprob1 <- wprob1[wprob1$w1 %in% wprob2$w2]
                setkey(wprob1, w1)
                
                # merge table
                setkey(wprob2, w2)
                
                unique_keys <- unique(c(wprob1[,w1], wprob2[,w2]))
                ng23 <- wprob2[wprob1[J(unique_keys)]]
                setkey(ng23, w2)

                setnames(ng23, "w2", "w")
                #ng23$prob2[is.na(ng23$prob2)] <- 0
                ng23$prob1[is.na(ng23$prob1)] <- 0.3
                
                # calculate discount
                cut_ug_div <- 1.0 - ng23$prob1
                cut_ug_div <- cut_ug_div * cut_ug_div
                ng23$cut_ug_div <- cut_ug_div
                ng23$prob12 <- ng23$prob2 * cut_ug_div 
                
                setkey(ng23, prob12)
                ng23 <- ng23[order(-prob12)]
                setnames(ng23, "prob2", "prob23")
                #ng23 <- data.frame(ng23)
                ng23 <- head(ng23, 20)
                return(ng23)
        }
}
#png_word <- pngram(input)

pskgram <- function(word){
        
        if (is.null(word)){
                return(NULL)
        }        
        
        # read uigram
        filename <- unzip("skg_prob_top20.csv.zip")
        #filename <- unzip("tg_nostop_prob.csv.zip")
        object.size(skg <- fread(filename))
        print("read skg")
        file.remove("skg_prob_top20.csv") 
        
#         wprob3 <- head(skg[w1 == word[1] & w2 == word[2], list(w3, prob)], 20) # not prob3
#         print(wprob3)
#         if (nrow(wprob3 >0)){
#                return(wprob3) 
#         }
#         else {return (NULL)}

        len <- length(word)
        
        if (len == 3){
                w1back <- head(skg[w1 == word[3], list(w2, prob_skg)], 20)
                w2back <- head(skg[w1 == word[2], list(w2, prob_skg)], 20)
                w3back <- head(skg[w1 == word[1], list(w2, prob_skg)], 20)
                rm(skg)
                
                # rename columns
                setnames(w1back, "prob_skg", "p1back")
                setnames(w2back, "prob_skg", "p2back")
                setnames(w3back, "prob_skg", "p3back")
                
                # merge tables
                setkey(w1back, w2)
                setkey(w2back, w2)
                setkey(w3back, w2)
                
                unique_keys <- unique(c(w1back[,w2], w2back[,w2]))
                pskg <- w1back[w2back[J(unique_keys)]]
                setkey(pskg, w2)
                               
                unique_keys <- unique(c(w3back[,w2], pskg[,w2]))
                pskg <- pskg[w3back[J(unique_keys)]]
                setnames(pskg, "w2", "w")

                pskg$p1back[is.na(pskg$p1back)] <- 0
                pskg$p2back[is.na(pskg$p2back)] <- 0
                pskg$p3back[is.na(pskg$p3back)] <- 0
                
                pskg$prob <- pskg$p1back * 0.6 + pskg$p2back * 0.3 + pskg$p3back * 0.1
                
                setkey(pskg, prob)
                pskg <- pskg[order(-prob)]
                #pskg <- data.frame(pskg)
                #print(pskg)
                pskg <- head(pskg, 20)
                
                return(pskg)
        }
        
        if (len == 2){
                w1back <- head(skg[w1 == word[2], list(w2, prob_skg)], 20)
                w2back <- head(skg[w1 == word[1], list(w2, prob_skg)], 20)
                rm(skg)
                
                # rename columns
                setnames(w1back, "prob_skg", "p1back")
                setnames(w2back, "prob_skg", "p2back")
                
                # merge tables
                setkey(w1back, w2)
                setkey(w2back, w2)
                
                unique_keys <- unique(c(w1back[,w2], w2back[,w2]))
                pskg <- w1back[w2back[J(unique_keys)]]
                setkey(pskg, w2)

                setnames(pskg, "w2", "w")
                
                pskg$p1back[is.na(pskg$p1back)] <- 0
                pskg$p2back[is.na(pskg$p2back)] <- 0
                
                pskg$prob <- pskg$p1back * 0.8 + pskg$p2back * 0.2 
                
                setkey(pskg, prob)
                pskg <- pskg[order(-prob)]
                #pskg <- data.frame(pskg)
                #print(pskg)
                pskg <- head(pskg, 20)
                
                return(pskg)
        }
        
        if (len == 1){
                w1back <- head(skg[w1 == word[1], list(w2, prob_skg)], 20)
                rm(skg)
                
                # rename columns
                setnames(w1back, "prob_skg", "prob")

                pskg <- w1back
                setnames(pskg, "w2", "w")
                
                setkey(pskg, prob)
                pskg <- pskg[order(-prob)]
                #pskg <- data.frame(pskg)
                #print(pskg)
                pskg <- head(pskg, 20)
                
                return(pskg)
        }

        
}

#pskg_word <- pskgram(skg_words)

combine_prob <- function(png, pskg){
        setkey(pskg, w)
        setkey(png, w)
        cp <- pskg[png]
        cp <- cp[ , list(w, prob, prob23)]
        #cp[, c('p1back', 'p2back', 'p3back','prob2', 'prob3', 'prob1', 'cut_ug_div'):=NULL]
        cp$prob[is.na(cp$prob)] <- 0 # cp$prob is the skg prob
        cp$p_all <- cp$prob23 * 0.2 + cp$prob * 0.8
        setkey(cp, p_all)
        cp <- cp[order(-p_all)]
        return(cp)
}

#============================================================
# test
#substring(ng_words[1], 1,1) # !!! for file name lookup

# file <- unzip("ug_prob.csv.zip") # gz didn't work
# object.size(skg <- fread("zcat skg_prob.csv.gz"))
# object.size(skg <- fread("skg_prob.csv"))

#============================================================
# main predict function
predict <- function(app_input){
        ### given app_input words return top ??? following words
        app_input <- line_clean(app_input)
        app_input <- replace_unk(app_input)
        wng <- get_ng_words(app_input)
        wskg <- get_skg_words(app_input) 
        # !!!need to change
#         dfng <- pngram(wng)
#         dfskg <- pskgram(wskg)
        
         output <- pngram(wng)
#         output <- data.frame(pskgram(wskg))
        output <- data.frame(output)
#         if (is.null(dfskg)){
#                 output <- pngram(wng)
#                 output <- data.frame(output)
#                 
#         }
#         else{
#                 output <- combine_prob(dfng, dfskg)
#                 output <- data.frame(output)    
#         }

        return(output)
}


