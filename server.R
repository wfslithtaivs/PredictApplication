library(shiny)
library(ggplot2)
source("algo.R")

# By default, the file size limit is 5MB. It can be changed by
# setting this option. Here we'll raise limit to 15MB.
options(shiny.maxRequestSize = 15*1024^2)

predict <- function(x){ 
        
# BackOff
        d3 <- subset(fullDict, first == x[1, 2] & second == x[1, 3], select = c(third, freq))
        d2 <- subset(fullDict, first == NA & second == x[1, 3], select = c(third, freq))
        return(rbind(d3, d2))
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
        output$testprediction <- renderTable({data.frame(fullDict)})  
        output$realprediction <- renderTable({predict(preprocess(input$sentence))})
        
        }
)