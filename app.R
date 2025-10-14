#
# 
#

library(shiny)
library(dplyr)
library(ggplot2)

#Data sets
arod.td <- read.csv('arod.td.csv')
#subset of arod.td
good.receivers.df <- read.csv("good.receivers.csv")

ui <- fluidPage(

    # App title
    titlePanel('Aaron Rodgers Regular Season Touchdowns'),

    # Sidebar and main panels 
    sidebarLayout(
        sidebarPanel(
          
        #Input here is deciding which variable the user wants to look at
          selectInput("variable", label = h3("Choose Variable"), 
                        choices=list("Opponents"=1,"Home and Away"=2, "Quarter"=3, "Receivers with more than 1 touchdown" = 4, "Week" =5), 
                        selected = 1),
          
    #Radio Button input to choose which color you want for the graph
    radioButtons("button", label=h3("Color"),
                 choices=list("Green"= 'forestgreen',"Gold"='gold',"Blue"='navyblue'), 
                 selected = 'forestgreen'),
    
    #Slider input allows you to choose how many touchdowns you want displayed in the data, and they are arranged in order so you can see first 200 tds for example.
    sliderInput("touchdowns",
                "How many Touchdowns",
                min = 1,
                max = 475,
                value = 475),
    
    # This checkbox input allows you to if selected, see the minimum for each variable. 
    checkboxInput("min", label="Display Minimum", value=FALSE),
        
    hr()),
    
    
    #Main panel
    #This is the web image address 
    mainPanel(img(src = "data:image/jpeg;base64,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"),
                  p("Aaron Rodgers PHOTO : MIKE ROEMER/ASSOCIATED PRESS", style ="font-size: 10px"),
                  hr(),
          plotOutput("plot"),
          hr(),
          
          # Here the statistic that we chose to output for each variable is shown
          p('Statistic:'),
          fluidRow(column(7, verbatimTextOutput("stat"))),
          
          #Here if the checkbox is checked the minimum value of each variable is shown
          p('Minimum:'),
          fluidRow(column(7, verbatimTextOutput("stat2")))
         
        )
        
    )
)


# Define server function (blank for now)
server <- function(input, output) {
   
  #Outputs selected histogram based on the input selected in the variables column
    output$plot <- renderPlot({
  
# This graph displays the Opponent variable
      if(input$variable==1){
        ggplot(slice(arod.td,1:input$touchdowns), aes(x= Opp)) + geom_histogram(stat = "count", fill = input$button)+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+ labs(title = "Aaron Rodgers TDs by Team", x = "Opponents", y= "Touchdowns")}
      
      
# This graph displays the amount of touchdowns based on if it came at home or away
      else if(input$variable==2){
        ggplot(slice(arod.td,1:input$touchdowns), aes(x= home.away)) + geom_histogram(stat = "count", fill = input$button)+ labs(title = "Aaron Rodgers TDs Home vs. Away", x = "Location", y= "Touchdowns")}
      
# This graph displays the amount of touchdowns by Quarter
      else if(input$variable==3){
        ggplot(slice(arod.td,1:input$touchdowns), aes(x = Quarter)) +
          geom_histogram(stat = "count", fill = input$button)+ labs(title = "Aaron Rodger's TDs by Quarter", x = "Quarter", y= "Touchdowns")}
      
# This graph shows the amount of touchdowns by receivers who caught more than 1
      else if(input$variable==4){
        ggplot(slice(good.receivers.df,1:input$touchdowns), aes(receiver)) + geom_histogram(stat = "count", fill = input$button)+theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+ labs(title = "Aaron Rodgers' Receivers With More than Two Touchdowns",x= "Receivers", y= "Touchdowns")}

# This graph shows the amount of touchdowns based on the week 
      else if(input$variable==5){
        ggplot(slice(arod.td,1:input$touchdowns), aes(x = Week)) +
          geom_histogram(stat = "count", fill = input$button)+ labs(title = "Aaron Rodgers TDs by Week", x = "week", y= "Touchdowns")}
    })
    
    
# This output is to displays the appropriate statistic for each variable
  output$stat <- renderPrint({
  # This shows the most touchdowns he had against one team 
    if(input$variable==1){paste('The max value is',max(table(arod.td$Opp)))}
    
  # This shows the range of the data from home and away
    else if(input$variable==2){paste('The range of touchdowns is',diff(range(table(arod.td$home.away))))}
    
  # This shows the most touchdowns he had in one quarter
    else if(input$variable==3){paste('The max value is',max(table(arod.td$Quarter)))}
    
  # This shows the most touchdowns caught by one receiver 
    else if(input$variable==4){paste('The max value is',max(table(good.receivers.df$receiver)))}
  
  # This shows the most touchdowns he had in one week  
    else if(input$variable==5){paste('The max value is',max(table(arod.td$Week)))}
  })
  
  
  # This output is to displays the appropriate statistic for each variable
  output$stat2 <- renderPrint({
    # This shows the least amount of touchdowns he had against one opponent 
    if(input$variable==1 &input$min == TRUE){min(table(arod.td$Opp))}
    
    # This shows the amount of touchdowns he had in total at away games
    else if(input$variable==2 &input$min == TRUE){min(table(arod.td$home.away))}
    
    # This shows the least amount touchdowns he had in one quarter
    else if(input$variable==3 &input$min == TRUE){min(table(arod.td$Quarter))}
    
    # This shows the least amount of touchdowns by one receiver who had more than 1 
    else if(input$variable==4 &input$min == TRUE){min(table(good.receivers.df$receiver))}
    
    # This shows the least touchdowns he had the least amount of touchdowns 
    else if(input$variable==5 &input$min == TRUE){min(table(arod.td$Week))}
  })
  
    
}


# Run the app
shinyApp(ui = ui, server = server)


