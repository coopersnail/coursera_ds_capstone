# ui.r
library(shiny)
# shinyUI(
#         
#         pageWithSidebar(
#         headerPanel("Test"),
#         
#         sidebarPanel(
#                 #selectInput("options", "options", choices=c('abc','def')),
# #                 textInput("textbox",
# #                           h5("What's the next word for my sentence? Input here:"),
# #                           "How are you"),
#                 tags$textarea(id="textbox", rows=5, cols=50, "How are you"),
# #                 tags$textarea(id="textbox", rows=5, cols=50, "new york city"),
#                 #textInput("textbox", "Text", ""),
#                 actionButton("predict","Submit")
#                 #submitButton('Submit')
#         ),
#         
#         mainPanel(
#                 textOutput("caption"),
#                 textOutput("word1"),
#                 textOutput("word2"),
#                 textOutput("word3"),
#                 tableOutput("view")
#         )
# ))

shinyUI(
        fluidPage(
                # Application title
                titlePanel("Word Predition App"),
                fluidRow(
                        p('This app takes in a sentence and predicts the last word. Please put in a sentence in the text box on the left.'),
                        tags$ol(
                                tags$li("Word Predictor tab: takes in a phrase and predicts the next word. This version aims at predicting the 
                                        last word of sentences"), 
                                tags$li("About the Algorithm tab: briefly describe the predition algorithm."), 
                                tags$li("About the Data tab: presents an exploratory analysis of the training data set.")
                        ),
                        strong('The prediction may take a few moments. Please be patient. Recent versions of Chrome or Firefox are recommended
                           browswers for this app.')
                        
                ),
                sidebarPanel(
                        strong("Text Input: "),
                        tags$textarea(id="textbox", rows=5, cols=20, "How are you"),
                        #textInput("textbox", "Text", ""),
                        actionButton("predict","SUBMIT"),
                        hr(),
                        p('Instruction: Please type in a sentence then press SUBMIT to predict the next word.'),
                        br(),
                        strong('Input at least one word'),
                        br(),
                        p('Predictions will be presented a few moments after you press SUBMIT. They will be presented on the right. 
                          An example "How are you" is provided to demonstrate usage of the app.'),
                        br(),
                        h6("Contact the author:"),
                        a("CS", href = "mailto:coopersnail@procida.us")
                        
                ),
                
                mainPanel(
                        tabsetPanel(
                                tabPanel("Word Predictor", 
                                         h4("The sentence you typed is: "),
                                         textOutput("caption"),
                                         hr(),
                                         h4("Magic 8 ball, tell me the next word... "),
                                         span(h4(textOutput('top1')),style = "color:red"),
                                         br(),
                                         h5('Other top runners:'),
                                         span(h5(textOutput('top2')),style = "color:green"),
                                         span(h5(textOutput('top3')),style = "color:green"),
                                         span(h5(textOutput('top4')),style = "color:green"),
                                         span(h5(textOutput('top5')),style = "color:green"),
                                         br(),
                                         h4('Here is a plot of the top 20 words:'),
                                         p('The size of the words reflects my level of confidence in the prediction.'),
                                         plotOutput("wcloud_plot"),
                                         #tableOutput("word_table")#,
#                                          plotOutput("rate_plot"),
                                         helpText("This app is built for the ", 
                                                  a("Coursera Data Science Capstone Project 2014",target="_blank",
                                                    href="http://www.coursera.org/course/dsscapstone", ".")
                                         )
                                ), 
                                tabPanel("About the Algorithm", 
                                         h4("Word Prediction Modeling Workflow"),
                                         h5("Original training dataset"),
                                         p("Data was based on the ", a("HC Copora", href = "http://www.corpora.heliohost.org/aboutcorpus.html"),
                                           'downloadable at ', a("here", href = "https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip"), 
                                           ". The data include blog, news, and twitter feeds in the English language." ),
                                         h5("Data sampling"),
                                         p("After filtering out special characters. Ten percent of the blog, news, and twitter corpora is randomly
                                           selected to build the model."),
                                         h5("Data cleaning and processing"),
                                         p("The dataset was cleaned via Python scripts. Python is more efficient in text mining than R.
                                           Some of the packages used are ", code("nltk"), " and ", code("re"), ". Cleanning include replacement or removal of 
                                           numbers, most punctuations, repeated words."),
                                         h5("Build the model"),
                                         p("The model is a combination of ", a("n-grams (max order = 3)", href = "http://en.wikipedia.org/wiki/N-gram"),
                                           'and a ', a("4-skip-bigram", href = "hhttp://en.wikipedia.org/wiki/N-gram#Skip-Gram"), 
                                           "." ),
                                         p("Smoothing inspired by the ", a("Modified Kneser-Ney technique", href = "http://www.ee.columbia.edu/~stanchen/papers/h015a-techreport.pdf"),
                                           'was used for estimating and discount the n-gram probabilities based on preceding context. Probabilities of unnown words
                                           not in the sampled corpus are estimated using words with only one occurrence.' ),
                                         p("The n-gram and skip-gram probabilities are saved as zipped .csv files and will be loaded when the app runs."),
                                         br(),
                                         h5("App prediction"),
                                         p("The text input is cleaned and pre-processed similarly as mentioned above except the process is now done by R. 
                                           A combination of weighed aggregation of the different gram models and a variation of the ", 
                                           a("back-off techniques", href = "http://en.wikipedia.org/wiki/Katz%27s_back-off_model"), ".")#,
#                                          helpText("Historical data on annual personal saving rate is obtained from the 
#                                                   website of the Federal Reserve Bank of St Louis and can be downloaded ", 
#                                                   a("here.",
#                                                     target="_blank",
#                                                     href="http://research.stlouisfed.org/fred2/series/PSAVERT/f")
#                                                   )
                                ),
                                tabPanel("About the Data", 
                                         includeHTML("capstone_wordpredict_eda.html")
                                )
                        ) 
                )                  
        )
)