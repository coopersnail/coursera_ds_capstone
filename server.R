# server.r
library(shiny)
library(wordcloud)
library(RColorBrewer)
source("predict.R")

options(shiny.maxRequestSize = -1)

shinyServer(function(input, output, session) {
        wordpredict <- reactive({
                input$predict
                wp <- predict(isolate(input$textbox))[, c('w', 'prob23')]
                withProgress(message = 'Prediction in progress',
                             detail = 'This may take a while...', value = 0, {
                                     for (i in 1:5) {
                                             incProgress(1/5)
                                             Sys.sleep(0.25)
                                     }
                        })
                return(wp)
                })

        
        output$caption <- renderText({
                input$textbox
        })
        
        
        output$top1 <- renderText({
                paste("My best guess is:", isolate(input$textbox), wordpredict()[1,1])
        })
        output$top2 <- renderText({
                paste("Top 2:", isolate(input$textbox), wordpredict()[2,1])
        })
        output$top3 <- renderText({
                paste("Top 3:", isolate(input$textbox), wordpredict()[3,1])
        })
        output$top4 <- renderText({
                paste("Top 4:", isolate(input$textbox), wordpredict()[4,1])
        })
        output$top5 <- renderText({
                paste("Top 5:", isolate(input$textbox), wordpredict()[5,1])
        })        
        output$wcloud_plot <- renderPlot({
                pal <- brewer.pal(9, "BuGn")
                pal <- pal[-(1:2)]
                wc <- wordcloud(wordpredict()$w, sqrt(wordpredict()$prob23), scale=c(4,.3),
                                min.freq=0.00000001, max.words=20, 
                                random.order=T, rot.per=.15, 
                                colors=pal, vfont=c("sans serif","plain"))
                
                withProgress(message = 'Making plot...',
                             detail = 'We are getting there...', value = 0, {
                                     for (i in 1:5) {
                                             incProgress(1/5)
                                             Sys.sleep(0.25)
                                     }
                             })
                
                return(wc)
        })

})
