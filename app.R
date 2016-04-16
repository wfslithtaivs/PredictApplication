## app.R ##
library(shinythemes)

navbarPage("United",
           theme = shinytheme("cerulean"),
           tabPanel("Plot", "Plot tab contents..."),
           navbarMenu("More",
                      tabPanel("Summary", "Summary tab contents..."),
                      tabPanel("Table", "Table tab contents...")
           )
)