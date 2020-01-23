library(DT)
library(lubridate)
library(dplyr)
library(stringr)
schedule <- readr::read_rds("data/sessions.Rda")

function(session, input, output) {
  dt_schedule <- reactive({
    if(!input$btn_oldEvents) schedule <- schedule[schedule$end_time > Sys.time(),]
    schedule %>% 
      transmute(
        gcal,
        text = paste("<div>", str_replace_all(text, "\n", "<br>"), "</div>"),
        Day = format(start_time, format = "%A", tz = "US/Pacific"),
        Start = format(start_time, format = "%H%M", tz = "US/Pacific"),
        End = format(end_time, format = "%H%M", tz = "US/Pacific"),
        Title = title,
        Speakers = speakers,
        Room = location,
        Category = category
      )
  })
  
  output$tbl_schedule <- renderDT({
    datatable(
      dt_schedule(),
      rownames = FALSE,
      filter = "top", 
      escape = -2,
      options = list(
        autoWidth = TRUE,
        paging = FALSE,
        scrollY = "75vh",
        columnDefs = list(
          list(visible = FALSE, targets = 0:1)
        ),
        sDom  = '<"top">lrt<"bottom">ip'
      ),
      callback = JS("
        /* code for text on click */
        table.on('click', 'td', function() {
          var row = table.row( this );
          if (row.child.isShown()) {
            row.child.hide();
          } else {
            row.child(row.data()[1]).show();
          }
        });
        
        /* code for gcal on doubleclick */
        table.on('dblclick', 'td', function() {
            var row = table.row( this ).data();
            window.open(row[0].replace(/&amp;&amp;/g, '&'));
        });
      ")
    )
  })
}
