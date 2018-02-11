library(caret)
library(dplyr)
library(shiny)


trim <- function (x) gsub("^\\s+|\\s+$", "", x)

ctrl <- trainControl(
  method = "repeatedcv",
  number = 2,
  repeats = 5
)

get_titanic_data <- function() {
  titanic_data <- read.csv('titanic.csv') %>% mutate(
    FirstName = sapply(strsplit(as.character(Name), ","), function(x) trim(gsub("Mrs.|Miss.|Mr.|Master.", "", x[[2]]))),
    LastName = sapply(strsplit(as.character(Name), ","), function(x) x[[1]])
  ) %>% select(FirstName, LastName, Sex, Age, Pclass, Survived, Fare)
  
  titanic_data <- titanic_data %>%
    group_by(Pclass, Sex) %>%
    mutate(
      Age = ifelse(
        is.na(Age),
        round(mean(Age, na.rm=TRUE)),
        Age
      )
    )
  
  titanic_data %>% ungroup()
}

fit_survived <- function(titanic_data) {
  titanic_data_survived = select(titanic_data, Sex, Age, Pclass, Survived)
  titanic_partition_survived <- createDataPartition(y = titanic_data_survived$Survived, p = .75, list = FALSE)
  titanic_training_survived <- titanic_data_survived[ titanic_partition_survived,]
  titanic_testing_survived  <- titanic_data_survived[-titanic_partition_survived,]

  train(Survived ~ ., data = titanic_training_survived, method = "rf", trControl = ctrl, ntree = 10)
}

fit_fare <- function(titanic_data) {
  titanic_data_fare = select(titanic_data, Sex, Age, Pclass, Fare)
  titanic_partition_fare <- createDataPartition(y = titanic_data_fare$Fare, p = .75, list = FALSE)
  titanic_training_fare <- titanic_data_fare[ titanic_partition_fare,]
  titanic_testing_fare  <- titanic_data_fare[-titanic_partition_fare,]
  
  train(Fare ~ ., data = titanic_training_fare, method = "rf", trControl = ctrl, ntree = 10)
}

shinyServer(function(input, output) {
  titanic_data <- get_titanic_data()
  
  fit_titanic_survived <- fit_survived(titanic_data)
  fit_titanic_fare <- fit_fare(titanic_data)

  survived_estimation <- reactive({
    data_ <- data.frame(
      'Sex' = factor(input$sex),
      'Age' = input$age,
      'Pclass' = input$ticket_class
    )
    predict(fit_titanic_survived, data_)
  })
  
  fare_estimation <- reactive({
    data_ <- data.frame(
      'Sex' = factor(input$sex),
      'Age' = input$age,
      'Pclass' = input$ticket_class
    )
    round(predict(fit_titanic_fare, data_), digits = 2)
  })
  survived_message <- reactive({
    ifelse(survived_estimation() > 0.5, "przeżyjesz", "nie przeżyjesz")
  })
  
  output$survived_estimation <- renderText({
    survived_estimation()
  })
  output$survived_message <- renderText({
    survived_message()
  })
  output$fare_estimation <- renderText({
    paste("$", fare_estimation(), sep="")
  })
})
