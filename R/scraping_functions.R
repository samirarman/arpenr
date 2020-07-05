scrape_data <- function(rd, year, month, state, query) {
  data <- data.frame()

  is_ok_for_scraping <- FALSE

  while (!is_ok_for_scraping) {
    post_query(rd, year, month, state, query)
    wait_for_table(rd)
    is_ok_for_scraping <-
      is_table_correct(rd, year, month, state, query)
  }

  data <- scrape_table(rd) %>%
    rbind(data)


  while (is_next_btn_avail(rd)) {
    next_btn <-
      rd$findElement(using = "xpath",
                     value = "//a[@aria-label= 'Goto next page']")

    suppressMessages(next_btn$clickElement())
    wait_for_table()
    data <- scrape_table(rd) %>%
      rbind(data)
  }

  dplyr::arrange(data, data[[1]])

}

scrape_table <- function(rd) {
  card_elements <- scrape_card(rd)

  table_data <-
    xml2::read_html(rd$getPageSource()[[1]]) %>%
    rvest::html_node("table") %>%
    rvest::html_table() %>%
    dplyr::mutate(
      Ano = as.character(card_elements$year),
      Mês = ifelse(is.null(card_elements$month), "Todos", card_elements$month)
    )
}

scrape_card <- function(rd) {
  elements <- list()

  card <-
    rd$findElement(using = "class", value = "mb-1")$getElementText()

  card_components <-
    card %>% stringr::str_split(" - ") %>% unlist()

  elements$query <- card_components[1]

  elements$state <- card_components[2]

  dates <-
    card_components[3] %>% stringr::str_split("/") %>% unlist()

  elements$year <- NULL

  elements$month <- NULL

  if (length(dates) == 2) {
    elements$month <- dates[1]
    elements$year <- dates[2]
  }  else {
    elements$year <- dates[1]
  }

  elements
}

post_query <- function(rd, year, month, state, query) {
  deaths_radio_button <- rd$findElements(using = "class",
                                         value = "custom-control")[[4]]
  deaths_radio_button$clickElement()

  fields <-
    rd$findElements(using = "class", value = "multiselect__input")
  year_field <- fields[[1]]
  month_field <- fields[[2]]
  state_field <- fields[[4]]

  search_btn <-
    rd$findElement(using = "class", value = "btn-success")

  year_field$sendKeysToElement(list(as.character(year)))
  year_field$sendKeysToElement(list("", key = "enter"))

  month_field$sendKeysToElement(list(month))
  month_field$sendKeysToElement(list("", key = "enter"))

  if (state == "Mato Grosso") {
    state_field$sendKeysToElement(list("mat", key = "down_arrow"))
    state_field$sendKeysToElement(list("", key = "enter"))
  } else {
    state_field$sendKeysToElement(list(paste(state, " ", sep = "")))
    state_field$sendKeysToElement(list("", key = "enter"))
  }
  Sys.sleep(1)

  search_btn$clickElement()
  Sys.sleep(2)
}

wait_for_table <- function(rd) {
  while (!is_table_present(rd)) {
    Sys.sleep(5)
  }
}

is_table_correct <- function(rd, year, month, state, query) {
  is_table_present(rd) &
    is_data_available(rd) &
    is_table_contents_correct(rd, year, month, state, query)
}

is_table_contents_correct <-
  function(rd, year, month, state, query) {
    elements <- scrape_card(rd)

    card_query <- elements$query

    card_state <- elements$state

    card_year <- elements$year

    card_month <- elements$month

    query_correct <- FALSE

    month_correct <- FALSE

    year_correct <- FALSE

    state_correct <- FALSE

    if (query == queries$all & card_query == "Registros") {
      query_correct <- TRUE
    } else if (query == queries$births & card_query == "Nascimentos") {
      query_correct <- TRUE
    } else if (query == queries$marriages & card_query == "Casamentos") {
      query_correct <- TRUE
    } else if (query == queries$deaths & card_query == "Óbitos") {
      query_correct <- TRUE
    }

    if (month == "Todos" & is.null(card_month)) {
      month_correct <- TRUE
    } else if (month == card_month) {
      month_correct <- TRUE
    }

    if (year == card_year) {
      year_correct <- TRUE
    }

    if (state == card_state) {
      state_correct <- TRUE
    }

    query_correct &
      month_correct &
      year_correct &
      state_correct
  }

is_data_available <- function(rd) {
  table <- xml2::read_html(rd$getPageSource()[[1]]) %>%
    rvest::html_node("table") %>%
    rvest::html_table()
  ! table[1, 1] == "Não há resultados a serem exibidos."
}

is_table_present <- function(rd) {
  table <- tryCatch(
    rd$findElement(using = "class",
                   value = "table-responsive"),
    error = function(x) {
      return(NULL)
    }
  )
  ! is.null(table)
}

is_next_btn_avail <- function(rd) {
  btn <- tryCatch(
    rd$findElement(using = "xpath",
                   value = "//a[@aria-label= 'Goto next page']"),
    error = function(x) {
      return(NULL)
    }
  )
  ! is.null(btn)
}