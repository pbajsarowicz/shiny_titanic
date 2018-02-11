library(shiny)

shinyUI(fluidPage(
  titlePanel("Sprawdź czy przeżyjesz na Titanicu"),
  sidebarLayout(
    sidebarPanel(
      h4("Uzupełnij formularz"),
      textInput("first_name", "Imię"),
      textInput("last_name", "Nazwisko"),
      selectInput("sex", "Płeć", c("male", "female")),
      sliderInput("age", "Wiek", 0.1, 90, value = 20, step = 1),
      numericInput("ticket_class", "Wybierz klasę (1, 2 lub 3):", value = 3, min = 1, max = 3, step = 1),
      submitButton("Sprawdź")
    ),
    mainPanel(
      h2("Oto Twój wynik"),
      p("Prawdopodobieństwo przeżycia wynosi: ", strong(textOutput("survived_estimation", inline = TRUE))),
      p("Co oznacza, że ", strong(textOutput("survived_message", inline = TRUE))),
      p("Cena biletu: ", strong(textOutput("fare_estimation", inline = TRUE)))
    )
  )
))
