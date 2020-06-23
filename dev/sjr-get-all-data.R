#===============================================================================
# 2019-09-19 -- bibliometrics
# Get all SJR data from the web
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com
#===============================================================================

library(tidyverse)
library(magrittr)
library(janitor)
library(readxl)


# functions to get data ---------------------------------------------------

journal_url <- function(year) {
    paste0(
        "https://www.scimagojr.com/journalrank.php?year=",
        year,
        "&out=xls"
    )
}


country_url <- function(year) {
    paste0(
        "https://www.scimagojr.com/countryrank.php?year=",
        year,
        "&out=xls"
    )
}



# set last available year -------------------------------------------------

# As of today, 2020-06-21, the last data year is 2019
# To be updated once a year
last_year <- 2019


# get the data automatically ----------------------------------------------


# journals
years_j <- 1999:last_year

sjr_journals <- list()

for (i in seq_along(years_j)) {
    # load specific year's data
    dfi <- suppressMessages(suppressWarnings(
        read_csv2(url(journal_url(years_j[i])))
    )) %>% clean_names()
    # fix the uniquely named column of total docs
    colnames(dfi)[9] <-
        colnames(dfi)[9] %>%
        str_replace("[0-9]+", "year")
    # write the temp df into the list
    sjr_journals[[i]] <- dfi
    # name the df in the list
    names(sjr_journals)[i] <- years_j[i]
}

sjr_journals <- sjr_journals %>% bind_rows(.id = "year")

usethis::use_data(sjr_journals, overwrite = T)


# countries

years_c <- 1996:last_year

sjr_countries <- list()

for (i in seq_along(years_c)) {
    tempi <- tempfile()
    pathi <- paste0(tempi, ".xslx")
    xlsxi <- download.file(
        url = country_url(years_c[i]),
        destfile = pathi, mode = "wb"
    )
    # load specific year's data
    dfi <- suppressMessages(suppressWarnings(
        read_xlsx(path = pathi, sheet = 1)
    )) %>% clean_names()
    # write the temp df into the list
    sjr_countries[[i]] <- dfi
    # name the df in the list
    names(sjr_countries)[i] <- years_c[i]
}

sjr_countries <- sjr_countries %>% bind_rows(.id = "year")

usethis::use_data(sjr_countries, overwrite = T)


# countries -- all years togetehr

tempi <- tempfile()
pathi <- paste0(tempi, ".xslx")
xlsxi <- download.file(
    url = country_url(
        "https://www.scimagojr.com/countryrank.php?out=xls"
    ),
    destfile = pathi, mode = "wb"
)

sjr_countries_total <- read_xlsx(pathi) %>% clean_names()


usethis::use_data(sjr_countries_total , overwrite = T)
