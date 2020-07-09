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

  check_arguments(year, month, state, wait)
}

navigate_to_site <- function(rd, wait = 10L) {
  rd$navigate(site)
  Sys.sleep(wait)
}

check_remote_driver <- function(rd) {
  if (is.null(rd) | !inherits(rd, "remoteDriver")) {
    rlang::abort("You need to provide a remoteDriver object
                 from `{RSelenium}` or equivalent.")
  }
}

check_arguments <- function(year, month, state, wait) {
  check_year(year)
  check_month(month)
  check_state(state)
  check_wait(wait)

}

check_year <- function(year, YEARS, rlang, abort) {
  if (as.character(year) %nin% YEARS) {
    rlang::abort("Year is not in the available range.")
  }
}

check_month <- function(month, rlang, abort, MONTHS) {
  if (!is.character(month)) {
    rlang::abort("Month should be a character.")
  } else if (month %nin% MONTHS) {
    rlang::abort(
      "Month is not valid.\n
           Check your spell and remember to capitalize
           the first letter of month name."
    )
  }
}

check_state <- function(state, rlang, abort, month, MONTHS) {
  if (!is.character(state)) {
    rlang::abort("State should be a character.")
  } else if (month %nin% MONTHS) {
    rlang::abort(
      "State is not valid.\n
           Check your spelling and remember to
           use title case in state name (eg.: 'Mato Grosso do Sul')"
    )
  }
}

check_wait <- function(wait, rlang, abort) {
  if (!is.numeric(wait)) {
    rlang::abort("Wait should be a number.")
  }
}
