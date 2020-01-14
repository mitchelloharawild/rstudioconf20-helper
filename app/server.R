library(DT)
schedule <- readr::read_rds("data/schedule.Rda")

function(session, input, output) {
  dt_schedule <- reactive({
    if(input$btn_oldEvents) schedule[,-1] else schedule[schedule$end_time > Sys.time(),-1]
  })
  
  output$tbl_schedule <- renderDT({
    datatable(
      dt_schedule(),
      rownames = FALSE,
      filter = "top", 
      options = list(
        autoWidth = TRUE,
        paging = FALSE,
        scrollY = "650px",
        columnDefs = list(
          list(visible = FALSE, targets = 0)
        ),
        sDom  = '<"top">lrt<"bottom">ip'
      ),
      callback = JS("
        /* code for columns on doubleclick */
        table.on('dblclick', 'td', function() {
            var schedule_data = table.row( this ).data();
            window.open(schedule_data[0].replace(/&amp;&amp;/g, '&'));
        });"
      )
    )
  })
}
