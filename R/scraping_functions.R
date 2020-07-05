# AUXILIARY FUNCTIONS AND SCRIPTS----------------------------------------------

# This file contains auxiliary scripts and functions used by
# the main script (scraper.R)

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

is_table_correct <- function(rd, caller, year, month, state) {
  is_table_contents_correct(rd, caller, year, month, state) &
    is_table_present(rd)
}

is_table_contents_correct <- function(rd, year, month, state, caller) {
  card <-
    rd$findElement(using = "class", value = "mb-1")$getElementText()

  card_components <- card %>% stringr::str_split(" - ") %>% unlist()

  card_query <- card_components[1]

  card_state <- card_components[2]

  card_dates <-
    card_components[3] %>% stringr::str_split("/") %>% unlist()

  card_year <- NULL

  card_month <- NULL

  if (length(card_dates) == 2) {
    card_month <- card_dates[1]
    card_year <- card_dates[2]
  }  else {
    card_year <- card_dates[1]
  }

  query_correct <- FALSE

  month_correct <- FALSE

  year_correct <- FALSE

  state_correct <- FALSE

  if (caller == "all" & card_query == "Registros") {
    query_correct <- TRUE
  } else if (caller == "births" & card_query == "Nascimentos") {
    query_correct <- TRUE
  } else if (caller == "marriages" & card_query == "Casamentos") {
    query_correct <- TRUE
  } else if (caller == "deaths" & card_query == "Óbitos") {
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

wait_for_table <- function(rd) {
  while (!is_table_present(rd)) {
    Sys.sleep(10)
  }
}


#' @importFrom magrittr %>%
scrape_table <- function(rd, year, month, state, caller) {

  data <- xml2::read_html(rd$getPageSource()[[1]]) %>%
    rvest::html_node("table") %>%
    rvest::html_table() %>%
    # tibble() %>%
    dplyr::mutate(
      Ano = as.character(year),
      Mês = as.character(month)
    )
  if (state != "Todos") {
    data <- dplyr::mutate(data, Estado = as.character(state))
  }
  data
}

post_query <- function(rd, year, month, state, caller) {
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

scrape_data <-
  function(rd, year, month, state, caller) {
    data <- data.frame()

    post_query(rd, year, month, state, caller)

    if (!is_table_present(rd)) {
      wait_for_table(rd)
    } else if (is_data_available(rd)) {
      data <- scrape_table(rd, year, month, state, caller) %>%
        rbind(data)
    }

    while (is_next_btn_avail(rd)) {

      next_btn <-
        rd$findElement(using = "xpath",
                       value = "//a[@aria-label= 'Goto next page']")

      suppressMessages(next_btn$clickElement())

      if (!is_table_present(rd)) {
        wait_for_table(rd)
      } else if (is_data_available(rd)) {
        Sys.sleep(0.75)
        data <- scrape_table(rd, year, month, state, caller) %>%
          rbind(data)
      }
    }
    dplyr::arrange(data, data[[1]])
  }
