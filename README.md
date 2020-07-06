
# arpenr

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![Travis build status](https://travis-ci.com/samirarman/arpenr.svg?branch=master)](https://travis-ci.com/samirarman/arpenr)
<!-- badges: end -->

The goal of `{arpenr}` package is to ease the access to Brazil's Civil Registration data.

It works by providing a set of convenience functions to be used with a `remoteDriver` object from package `{RSelenium}` or an equivalent framework.

## Installation

You can install the development version with:

``` r
# install.packages("devtools")
devtools::install_github("samirarman/arpenr")
```

## Example

Basic example of usage:

``` r
library(arpenr)

rs <- RSelenium::rsDriver(browser = "firefox", verbose = FALSE)
rd <- rs$client

# Retrieves all deaths registred in 2019 in "Goiás" state
get_deaths(rd, year = "2019", month = "Todos", state =  "Goiás")

# Retrieving all births in each city of São Paulo state, in March / 2019
get_births(rd, year = "2019", month = "Março", state = "São Paulo")

# Clean up
rd$quit()
rs$server$stop()

```

