library(RSelenium)

rs <- rsDriver(browser = "firefox")
rd <- rs$client

(a <- get_deaths(rd, year = 2019, wait = 1))

rd$quit()
rs$server$stop()
