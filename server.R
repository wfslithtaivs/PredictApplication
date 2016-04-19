library(shiny)
library(ggplot2)
source("algo.R")

# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 15MB.
options(shiny.maxRequestSize = 15*1024^2)

predict <- function(x){

# Simple BackOff with geometric progression coeffitient - initial level no coeff,
        # level 1 - 0.4, level 2 - 0.16 etc.
        res <- data.frame("third" = "the", probs = 1)
        d3 <- subset(fullDict, first == x[1, 2] & second == x[1, 3], select = c(third, probs))
        d2 <- subset(fullDict, first == NA & second == x[1, 3], select = c(third, probs))
        if (length(d2$third) != 0) {res$probs <- res$probs*0.16; d2$probs <- d2$probs*0.4; res <- rbind(d2, res)}
        if ((length(d3$third) != 0) & (length(d2$third) != 0)) {res <- rbind(d3, res)}
        if ((length(d3$third) != 0) & (length(d2$third) == 0)) {res$probs <- res$probs*0.16; res <- rbind(d3, res)}
        return(res)
}

takeTheLastSome <- function(x){
        k <- preprocess(x)
        return(k)
}

shinyServer(function(input, output) {

        values <- reactive({
              takeTheLastSome(input$sentence)
        })

        output$sentence <- renderPrint({preprocess(input$sentence)})
        output$takeSome <- renderPrint({values()})
        output$testprediction <- renderTable({data.frame(head(fullDict))})
        output$realprediction <- renderTable({predict(preprocess(input$sentence))})

        }
)
