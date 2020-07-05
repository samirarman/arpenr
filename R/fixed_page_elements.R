#
#
# pkg.env$all_radio_button <<- RSelenium::webElement
# pkg.env$births_radio_button <<- RSelenium::webElement
# pkg.env$marriages_radio_button <<- RSelenium::webElement
# pkg.env$deaths_radio_button <<- RSelenium::webElement
#
# pkg.env$year_field <<- RSelenium::webElement
# pkg.env$month_field <<- RSelenium::webElement
# pkg.env$region_field <<- RSelenium::webElement
# pkg.env$state_field <<- RSelenium::webElement
#
# pkg.env$search_button <<- RSelenium::webElement

set_common_elements <- function(rd) {
  pkg_env <- new.env(parent = emptyenv())

  radio_buttons <- rd$findElements(using = "class",
                                   value = "custom-control")

  pkg_env$all_radio_button <- radio_buttons[[1]]
  pkg_env$births_radio_button <- radio_buttons[[2]]
  pkg_env$marriages_radio_button <- radio_buttons[[3]]
  pkg_env$deaths_radio_button <- radio_buttons[[4]]

  fields <- rd$findElements(using = "class", value = "multiselect__input")

  pkg_env$year_field <- fields[[1]]
  pkg_env$month_field <- fields[[2]]
  pkg_env$region_field <- fields[[3]]
  pkg_env$state_field <- fields[[4]]

  pkg_env$search_btn <-
    rd$findElement(using = "class", value = "btn-success")
  invisible(rd)
}
