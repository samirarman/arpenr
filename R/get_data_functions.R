#' Retrieves the number of registries in ARPEN website.
#'
#' @description
#' Retrieves the number of the recorded vital events (all, births,
#' marriages, and deaths) available at the ARPEN website
#' \url{https://transparencia.registrocivil.org.br/registros}
#' according to the
#' arguments provided.
#'
#' The functions work by navigating to the ARPEN website and
#' filling the form in order to generate a scrapable webpage.
#'
#' The functions take a pre-initialized webDriver from the \link{RSelenium}
#' package (see example).
#'
#' * `get_all_registries()` Retrieves the number off all registries.
#' * `get_births()` Retrieves the number of registered births.
#' * `get_marriages()` Retrieves the number of registered marriages.
#' * `get_deaths()` Retrieves the number of registered deaths.
#'
#' @param rd An initialized RSelenium webdriver.
#' @param year A numerical or character representing the year
#' you want to retrieve the registries from.
#' @param month A character representing the month name in Portuguese
#' or "Todos" for retrieving data from all the months in the
#' selected year.
#' @param state A character representing the State name in Portuguese or
#' "Todos" for retrieving data from all states.
#' @param wait An integer representing how long to wait before starting
#' the scraping operation after reaching
#' the Brazilian Association of Civil Registries website.
#'
#' @return A data frame containing the requested data.
#' If no data was found, an empty data frame is returned.
#' @export
#'
#' @examples
#' \dontrun{
#' rs <- RSelenium::rsDriver(browser = "firefox")
#' rd <- rs$client
#'
#' get_all_registries(rd, "2018", "Janeiro", "Acre")
#' get_deaths(rd, "2020", "Maio", "Todos")
#'
#' rd$quit()
#' rd$server$stop()
#' }
get_all_registries <-
  function(rd = NULL,
           year = "2020",
           month = "Todos",
           state = "Todos",
           wait = 10L) {

    check_remote_driver(rd)
    check_arguments(rd, year, month, state, wait)

    if (rd$getCurrentUrl() != site) {
      navigate_to_site(rd, wait)
    }

    deaths_radio_button <-
      rd$findElements(using = "class",
                      value = "custom-control")[[4]]

    deaths_radio_button$clickElement()

    scrape_data(rd, year, month, state, query = queries$all)

  }

#' @rdname get_all_registries
#' @export
get_births <-
  function(rd = NULL,
           year = "2020",
           month = "Todos",
           state = "Todos",
           wait = 10L) {

    check_remote_driver(rd)
    check_arguments(rd, year, month, state, wait)

    if (rd$getCurrentUrl() != site) {
      navigate_to_site(rd, wait)
    }

    deaths_radio_button <-
      rd$findElements(using = "class",
                      value = "custom-control")[[2]]

    deaths_radio_button$clickElement()

    scrape_data(rd, year, month, state, query = queries$births)

  }

#' @rdname get_all_registries
#' @export
get_marriages <-
  function(rd = NULL,
           year = "2020",
           month = "Todos",
           state = "Todos",
           wait = 10L) {

    check_remote_driver(rd)
    check_arguments(rd, year, month, state, wait)

    if (rd$getCurrentUrl() != site) {
      navigate_to_site(rd, wait)
    }

    deaths_radio_button <-
      rd$findElements(using = "class",
                      value = "custom-control")[[3]]

    deaths_radio_button$clickElement()

    scrape_data(rd, year, month, state, query = queries$marriages)

  }

#' @rdname get_all_registries
#' @export
get_deaths <-
  function(rd = NULL,
           year = "2020",
           month = "Todos",
           state = "Todos",
           wait = 10L) {

    check_remote_driver(rd)
    check_arguments(rd, year, month, state, wait)

    if (rd$getCurrentUrl() != site) {
      navigate_to_site(rd, wait)
    }

    deaths_radio_button <-
      rd$findElements(using = "class",
                      value = "custom-control")[[4]]

    deaths_radio_button$clickElement()

    scrape_data(rd, year, month, state, query = queries$deaths)

  }
