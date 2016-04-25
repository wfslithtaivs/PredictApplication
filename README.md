# PredictApplication
Predict Application for Coursera Project

The goal of Data Science specialisation final project was to explore algorithmic part of word prediction, implement the web-based Data Product application using Shiny.io service and find the right words to explain for your family and friends (and possible investors) what exactly you been doing for almost two months avoiding social contacts (lol).

Prediction algorithm uses the n-gram language model built with RStudio friendly Natural Language Processing techniques: tm and RWeka packages and Markov’s assumption: the next word in the sentence can be predicted with some probability based on a few previos words.

Language model were built on data from corpus HC Corpora and external data sets for profanity filtering and non-english words cleansing. Initial model based on 70% of corpus data with up to 5-grams calculated, but then was reduced to short 3-gram model with very limited predictive power to optimise responce time.

WordPredict Application implements the following logic:

1. App is reading the input after "Guess the next word” button is pressed.
2. Preprocessing input (lowering case, remove punctuation, trim white spaces, etc.)
3. Looking up for all possible endings (among 2- and 3-grams)
4. Backing-of to the lower-grams applying reduction factor (0.4 for 2-grams, 0.16 for top unigrams).
5. Put all predictions together, sort desc by probability and show the top-5 predicted words.
6. If nothing found - the most common unigram “the” will be shown.
