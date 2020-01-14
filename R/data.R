library(rvest)
library(tidyverse)
library(lubridate)
library(glue)

web <- read_html("https://www.isi2019.org/scientific-programme-2/")
days <- html_nodes(web, ".insert-page")

schedule <- days %>% 
  set_names(c("2019-08-19", "2019-08-20", "2019-08-21", "2019-08-22", "2019-08-23")) %>% 
  map_dfr(function(x){
    html_nodes(x, ".sow-accordion-panel") %>% 
      map_dfr(function(y){
        title <- html_text(html_nodes(y, ".sow-accordion-title > .ac-main"))
        upper <- html_text(html_nodes(y, ".sow-accordion-panel-border > .ac-upper"))
        if(is_empty(upper)) upper <- ""
        lower <- html_nodes(y, ".sow-accordion-panel-border > .ac-lower")
        
        map_dfr(lower, ~ tibble(Title = html_text(html_nodes(., ".ac-topic")),
                                Name = html_text(html_nodes(., ".sp-name")))) %>% 
          mutate(
            Time = title[1], id = title[2], Session = title[3], Location = title[4],
            Meta = upper
          )
      })
  }, .id = "Date")

schedule %>% 
  separate(Name, into = c("Name", "Organisation", "Country"), sep = ", ", 
           extra = "drop", fill = "right") %>% 
  separate(Time, c("Start", "End")) %>% 
  mutate(
    Start = ymd_hm(paste(Date, Start), tz = "Asia/Kuala_Lumpur"),
    End = ymd_hm(paste(Date, End), tz = "Asia/Kuala_Lumpur"),
    Day = wday(Start, label = TRUE, abbr = FALSE)
  ) %>% 
  group_by(id) %>% 
  mutate(
    Start = Start + (End-Start)/n()*(row_number()-1),
    End = Start + min(End-Start),
    gcal = gsub(
      " ", "%20",
      glue("https://www.google.com/calendar/render?action=TEMPLATE&&text={gsub(' ', '+', Title)}&&details={Session}+({id})%0A{Name},+{Organisation},+{Country}&&location=Kuala+Lumpur+Convention+Centre,+{gsub(' ', '+', Location)}&&dates={format(Start, format = '%Y%m%dT%H%M%SZ', tz = 'GMT')}%2F{format(End, format = '%Y%m%dT%H%M%SZ', tz = 'GMT')}")
    )
  ) %>% 
  ungroup() %>% 
  mutate(
    end_time = End,
    Start = as.numeric(format(Start, "%H%M")),
    End = as.numeric(format(End, "%H%M"))
  ) %>% 
  select(end_time, gcal, Day, Start, End, Title, Name, Organisation, Country, Session, Location, id, Meta) %>% 
  readr::write_rds("app/data/schedule.Rda")


