library(shiny)
library(shinydashboard)

dashboardPage(
  title = "ISI WSC 2019",
  skin  = "blue",
  dashboardHeader(
    title = "ISI WSC 2019 Scheduler"
  ),

  # Dashboard Sidebar -------------------------------------------------------
  dashboardSidebar(
    "WSC19 Schedule",
    disable = TRUE
  ),

  dashboardBody(
    includeCSS("www/isi.css"),
    fluidRow(
      box(
        width = 12,
        tags$span(
          "This small shiny app provides an alternative copy of the ISI WSC 2019's offical scientific programme (",
          tags$a("https://www.isi2019.org/scientific-programme-2/", href = "https://www.isi2019.org/scientific-programme-2/"),
          ")."
        ),
        tags$br(),
        tags$span(
          "While I've done my best to ensure that the app accurately represents the schedule, you should check with the official scientific programme."
        ),
        tags$br(),
        tags$span(
          "The start and end times for talks provided in this table assume that each talk within a session has an equal allocation of time. ",
          tags$b("This is a not always the correct!"),
          "So be wary that the times for specific talks may not be entirely accurate."
        ),
        tags$br(),
        tags$br(),
        tags$span(
          "The table below allows you to search for talks and add the event to your Google Calendar by double clicking."
        ),
        shiny::checkboxInput("btn_oldEvents", label = "Include talks from the past", value = Sys.Date() > as.Date("2019-08-23"))
      ),
      box(
        width = 12,
        DT::DTOutput("tbl_schedule")
      )
    )
  )
)
