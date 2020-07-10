scrape_data <- function(rd, year, month, state, query) {
  data <- data.frame()

  is_ok_for_scraping <- FALSE

  while (!is_ok_for_scraping) {
    post_query(rd, year, month, state, query)
    wait_for_table(rd)
    is_ok_for_scraping <-
      is_table_correct(rd, year, month, state, query)
  }

  if (is_data_available(rd)) {
    data <- scrape_table(rd) %>%
      rbind(data)
  }

  while (is_next_btn_avail(rd)) {
    next_btn <-
      rd$findElement(using = "xpath",
                     value = "//a[@aria-label= 'Goto next page']")

    next_btn$clickElement()
    wait_for_table(rd)

    if (is_data_available(rd)) {
      data <- scrape_table(rd) %>%
        rbind(data)
    }
  }

  if (nrow(data) > 1) {
    dplyr::arrange(data, data[[1]])
  } else {
    data
  }

}

scrape_table <- function(rd) {
  card_elements <- scrape_card(rd)

  table_data <-
    xml2::read_html(rd$getPageSource()[[1]]) %>%
    rvest::html_node("table") %>%
    rvest::html_table() %>%
    dplyr::mutate(
      Ano = as.character(card_elements$year),
      "M\u00eas" = ifelse(is.null(card_elements$month), "Todos", card_elements$month)
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
  radio_buttons <- rd$findElements(using = "class",
                                   value = "custom-control")
  selected_radio_button <- switch(
    query,
    all = radio_buttons[[1]],
    births = radio_buttons[[2]],
    marriages = radio_buttons[[3]],
    deaths = radio_buttons[[4]]
  )
  selected_radio_button$clickElement()

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

  if (check_filled_correctly(rd, year, month, state, query)) {
    search_btn$clickElement()
    Sys.sleep(2)
  } else {
    rlang::abort("Problems filling query on webpage.")
  }

}

wait_for_table <- function(rd) {
  while (!is_table_present(rd)) {
    Sys.sleep(5)
  }
}

is_table_correct <- function(rd, year, month, state, query) {
  is_table_present(rd) &
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
    } else if (query == queries$births &
               card_query == "Nascimentos") {
      query_correct <- TRUE
    } else if (query == queries$marriages &
               card_query == "Casamentos") {
      query_correct <- TRUE
    } else if (query == queries$deaths &
               card_query == "\u00d3bitos") {
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

    if (state == "Todos" & card_state == "Brasil") {
      state_correct <- TRUE
    } else if (state == card_state) {
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
  ! table[1, 1] == "N\u00e3o h\u00e1 resultados a serem exibidos."
}

is_table_present <- function(rd) {
  table <- suppressMessages(tryCatch(
    rd$findElement(using = "class",
                   value = "table-responsive"),
    error = function(x) {
      return(NULL)
    }
  ))
  ! is.null(table)
}

is_next_btn_avail <- function(rd) {
  btn <- suppressMessages(tryCatch(
    rd$findElement(using = "xpath",
                   value = "//a[@aria-label= 'Goto next page']"),
    error = function(x) {
      return(NULL)
    }
  ))
  ! is.null(btn)
}

check_filled_correctly <- function(rd, year, month, state, query) {
  all_radio_button <-
    rd$findElement(using = "css selector",
                   value = "#__BVID__29__BV_radio_0_opt_")

  births_radio_button <-
    rd$findElement(using = "css selector",
                   value = "#__BVID__29__BV_radio_1_opt_")

  marriages_radio_button <-
    rd$findElement(using = "css selector",
                   value = "#__BVID__29__BV_radio_2_opt_")

  deaths_radio_button <-
    rd$findElement(using = "css selector",
                   value = "#__BVID__29__BV_radio_3_opt_")

  radio_button_correct <- FALSE

  if (query == queries$all &
      deaths_radio_button$isElementSelected()[[1]]) {
    radio_button_correct <- TRUE
  } else if (query == queries$births &
             births_radio_button$isElementSelected()[[1]]) {
    radio_button_correct <- TRUE
  } else if (query == queries$marriages &
             births_radio_button$isElementSelected()[[1]]) {
    radio_button_correct <- TRUE
  } else if (query == queries$deaths &
             deaths_radio_button$isElementSelected()[[1]]) {
    radio_button_correct <- TRUE
  }

  fields <-
    rd$findElements(using = "class", value = "multiselect__single")

  year_field <- fields[[1]]
  month_field <- fields[[2]]
  state_field <- fields[[4]]

  fields_correct <- (
    year_field$getElementText() == year &
      month_field$getElementText() == month &
      state_field$getElementText() == state
  )

  radio_button_correct & fields_correct

}
