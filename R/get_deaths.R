#' Retrieves the number of deaths from the specified
#' city or state.
#'
#' @param rd An RSelenium remote driver.
#' @param year An year.
#' @param month A month.
#' @param state A state.
#' @param wait Waiting time in seconds before attempting to
#' retrieve data.
#'
#' @return A data frame containing the required data.
#' @export
#'
#' @examples
#' \dontrun{
#' get_deaths(rd, "2015", "Junho")
#' }
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
