#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

'%nin%' <- Negate('%in%')

init <- function(rd, year, month, state, wait) {
  check_remote_driver(rd)

  if (rd$getCurrentUrl() != site) {
    navigate_to_site(rd, wait)
  }

  check_arguments(rd, year, month, state, wait)
}

navigate_to_site <- function(rd, wait = 10L) {
  rd$navigate(site)
  Sys.sleep(wait)
}

check_remote_driver <- function(rd) {
  if (is.null(rd)) {
    rlang::abort("You need to provide a webDriver object
                 from `{RSelenium}` or equivalent.")
  }
}

check_arguments <- function(rd, year, month, state, wait) {
  if (as.character(year) %nin% read_years(rd)) {
    rlang::abort("Year is not in the available range.")
  }

  if (!is.character(month)) {
    rlang::abort("Month should be a character.")
  } else if (month %nin% MONTHS) {
    rlang::abort(
      "Month is not valid.\n
         Check your spell and remember to capitalize
         the first letter of month name."
    )
  }

  if (!is.character(state)) {
    rlang::abort("State should be a character.")
  } else if (month %nin% MONTHS) {
    rlang::abort(
      "State is not valid.\n
         Check your spelling and remember to
         use title case in state name (eg.: 'Mato Grosso do Sul')"
    )
  }

  if (!is.numeric(wait)) {
    rlang::abort("Wait should be a number.")
  }

}

read_years <- function(rd) {
  input_year_field <-
    rd$findElements(using = "class", value = "multiselect__input")[[1]]
  input_year_field$sendKeysToElement(list(""))

  content_fields <-
    rd$findElements(using = "class", value = "multiselect__content")

  content_year_field <-
    content_fields[[1]]$findChildElements(using = "class", value = "multiselect__element")

  input_year_field$sendKeysToElement(list("", key = "enter"))

  years <- list()

  for (i in seq_along(content_year_field)) {
    years[i] <- content_year_field[[i]]$getElementText()
  }

  unlist(years)

}
