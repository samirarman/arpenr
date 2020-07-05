#' Retrieves the number of all registered events
#' (births, marriages, and deaths) according to the
#' arguments provided
#'
#' @param rd An RSelenium webdriver.
#' @param year Year
#' @param month Month
#' @param state State
#' @param wait Waiting
#'
#' @return A data frame.
#' @export
#'
#' @examples
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
