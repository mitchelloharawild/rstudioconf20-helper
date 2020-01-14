library(jsonlite)
library(tidyverse)
library(lubridate)
library(glue)

event <- read_json("R/event.json")
speakers <- map_dfr(event$speakerInfoSnapshot$speakers, ~ as_tibble(.x[c("id", "firstName", "lastName", "company", "title", "biography")])) %>% 
  distinct() %>% 
  mutate(name = glue("{firstName} {lastName}"))

event$products$sessionContainer

read_json("R/products.json")

products <- read_json("R/products.json")

keys <- imap_dfr(products$sortKeys, function(x, id){
  tibble(id = id, category = x[[4]])
})

products <- imap_dfr(products$sessionProducts, function(x, id){
  tibble(
    id = id,
    start_time = as_datetime(x$startTime, tz = "PST"),
    end_time = as_datetime(x$endTime, tz = "PST"),
    categoryId = x$categoryId,
    capacityId = x$waitlistCapacityId,
    speakers = glue_collapse(speakers$name[speakers$id %in% names(x$speakerIds)], ", "),
    title = x$name,
    location = x$locationName %||% "",
    text = glue_collapse(fromJSON(x$richTextDescription%||%"{}")$content$blocks$text, "\n\n")
  )
})

left_join(
  products,
  keys,
  by = "id"
) %>% 
  mutate(
    gcal = gsub(
      " ", "%20",
      glue("https://www.google.com/calendar/render?action=TEMPLATE&&text={gsub(' ', '+', title)}&&details=Speakers:+{speakers})%0A{text}&&location=Hilton+San+Francisco+Union+Square,+{gsub(' ', '+', location)}&&dates={format(start_time, format = '%Y%m%dT%H%M%SZ', tz = 'PST')}%2F{format(end_time, format = '%Y%m%dT%H%M%SZ', tz = 'PST')}")
    )
  ) %>% 
  write_rds("app/data/sessions.Rda")
