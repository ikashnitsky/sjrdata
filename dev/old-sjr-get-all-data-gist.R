################################################################################
#
# bibliometrics 2018-09-22
# SJR data -- load and combine all files -- GIST
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com
#
################################################################################

library(tidyverse)
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

# As of today, 2019-09-19, the last data year is 2018
# TO be updated once a year
last_year <- 2018


# get and tidy the data -- journals ---------------------------------------

years_j <- 1999:last_year

df_jr <- list()

for (i in seq_along(years_j)) {
    # load specific year's data
    dfi <- suppressMessages(suppressWarnings(
        read_csv2(url(journal_url(years_j[i])))
    )) %>% clean_names()
    # fix the uniquiely named column of total docs
    colnames(dfi)[9] <-
        colnames(dfi)[9] %>%
        str_replace("[0-9]+", "year")
    # write the temp df into the list
    df_jr[[i]] <- dfi
    # name the df in the list
    names(df_jr)[i] <- years_j[i]
}

df_jr <- df_jr %>% bind_rows(.id = "year")

# consider saving the data!
# save(df_jr, file = "df_jr.rda")



# get and tidy the data -- countries year-by-year -------------------------

years_c <- 1996:last_year

df_cr <- list()

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
    df_cr[[i]] <- dfi
    # name the df in the list
    names(df_cr)[i] <- years_c[i]
}

df_cr <- df_cr %>% bind_rows(.id = "year")

# consider saving the data!
# save(df_cr, file = "df_cr.rda")

# get and tidy the data -- countries all years togetehr --------------------

tempi <- tempfile()
pathi <- paste0(tempi, ".xslx")
xlsxi <- download.file(
    url = country_url(
        "https://www.scimagojr.com/countryrank.php?out=xls"
    ),
    destfile = pathi, mode = "wb"
)

df_cr_total <- read_xlsx(pathi) %>% clean_names()

# consider saving the data!
# save(df_cr_total, file = "df_cr_total.rda")
