## ui.R ##
library(shiny)
library(shinythemes)

# Initial block

shinyUI(fluidPage(
                # theme = "bootstrap.css",

                tags$head(
                        tags$style(HTML("
                        @import url('//fonts.googleapis.com/css?family=Lobster|Cabin:400,700');
                        h1 {
                        font-family: 'Lobster';
                        font-weight: 400;
                        line-height: 1.1;
                        color: #ad1d28;
                        }
                        h4 {
                        font-family: 'Lobster';
                        font-weight: 400;
                        line-height: 1.1;
                        color: #cd5c5c;
                        }
                        body {
                        background-color: #ffebcd;
                        }
                        text/css", ".span8 .well { background-color: #ff4040; }
                        "))
                ),

                  headerPanel("Next Word Prediction"),

                  sidebarPanel(
                          withTags({
                                  div(class="header", checked=NA, style = "color:grey",
                                      p("Enter the word or sentence, don't forget about symbols and numbers, press the Submit button and enjoy the artificial intelligence")
                                  )
                          }),

                          textInput("sentence", "Input here:", value = "Keep typing ..."),

                          submitButton('Submit'),

                          withTags({
                                        div(class="header", checked=NA, style = "color:grey",
                                        p(""),
                                        p("Please, peer me softly and ---->"),
                                        a(href="https://github.com/wfslithtaivs/PredictApplication", "Review code here")
                                )
                        })
                  ),


                  mainPanel(
                          h4('You entered:'),
                          verbatimTextOutput("sentence"),
                          h4('Sentence stat:'),
                          verbatimTextOutput("takeSome"),
                          h4('Top 5 predicted:'),
                          tableOutput("testprediction"),
                          h4('Top 5 predicted:'),
                          tableOutput("realprediction")


                  )

        )
)
