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

# TODO
check_arguments <- function(year, month, region, state, wait, verbose) {
  TRUE
}


