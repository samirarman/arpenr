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

navigate_to_site <- function(rd, wait = 10L) {
  rd$navigate(site)
  Sys.sleep(wait)
}

check_remote_driver <- function(rd) {
  if (is.null(rd)) {
    stop("You need to provide an RSelenium client in order\n
         to retrieve data.")
  }
}

check_arguments <- function(year, month, region, state, wait, query) {
  TRUE
}

site <- "https://transparencia.registrocivil.org.br/registros"

queries <- c(
  all = "all",
  births = "births",
  marriages = "marriages",
  deaths = "deaths"
)


