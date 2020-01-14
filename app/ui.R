library(shiny)
library(shinydashboard)

dashboardPage(
  title = "rstudio::conf(2020)",
  skin  = "blue",
  dashboardHeader(
    title = "rstudio::conf(2020) agenda"
  ),

  # Dashboard Sidebar -------------------------------------------------------
  dashboardSidebar(
    "rsc(2020) agenda",
    disable = TRUE
  ),

  dashboardBody(
    includeCSS("www/rsc.css"),
    fluidRow(
      box(
        width = 12,
        tags$span(
          "This small shiny app provides an alternative copy of the rstudio::conf(2020) offical agenda (",
          tags$a("https://cvent.me/7rKGW", href = "https://cvent.me/7rKGW"),
          ")."
        ),
        tags$br(),
        tags$span(
          "While I've done my best to ensure that the app accurately represents the agenda, you should check with the official agenda."
        ),
        tags$br(),
        tags$br(),
        tags$span(
          "The table below allows you to search for talks and add the event to your Google Calendar by double clicking."
        ),
        shiny::checkboxInput("btn_oldEvents", label = "Include talks from the past", value = Sys.time() > as.POSIXct("2020-01-31", tz = "PST"))
      ),
      box(
        width = 12,
        DT::DTOutput("tbl_schedule")
      )
    )
  )
)
