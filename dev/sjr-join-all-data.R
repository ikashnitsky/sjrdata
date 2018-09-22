################################################################################
#
# bibliometrics 2018-09-21
# SJR data -- load and combine all files
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com
#
################################################################################

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

# As of today, 2018-09-21, the last data year is 2017
# TO be updated once a year
last_year <- 2017


# get the data automatically ----------------------------------------------


# journals
years_j <- 1999:last_year

sjr_journals <- list()

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
    sjr_journals[[i]] <- dfi
    # name the df in the list
    names(sjr_journals)[i] <- years_j[i]
}

sjr_journals <- sjr_journals %>% bind_rows(.id = "year")

devtools::use_data(sjr_journals, overwrite = T)


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

devtools::use_data(sjr_countries, overwrite = T)


# countries -- all years togetehr

tempi <- tempfile()
pathi <- paste0(tempi, ".xslx")
xlsxi <- download.file(
    url = country_url(
        "https://www.scimagojr.com/countryrank.php?out=xls"
    ),
    destfile = pathi, mode = "wb"
)

df_name <- paste0("sjr_countries_1996_", last_year)

assign(
    df_name,
    read_xlsx(pathi) %>% clean_names()
)

devtools::use_data(sjr_countries_1996_2017 , overwrite = T)



### BELOW GOES DEPRICIATED CODE FOR DEALING WITH MANUALLY DPWNLOADED FILES

# SJR journal ranking -----------------------------------------------------

jr_dir <- "data-raw/sjr-journal/"

jr_files <- list.files(jr_dir)

sjr_journals <- list()

for (i in seq_along(jr_files)) {
    # load specific year's data
    dfi <- suppressMessages(
        read_csv2(file = paste0(jr_dir, jr_files[i]))
    ) %>% clean_names()
    # fix the uniquiely named column of total docs
    colnames(dfi)[9] <-
        colnames(dfi)[9] %>%
        str_replace("[0-9]+", "year")
    # write the temp df into the list
    sjr_journals[[i]] <- dfi
    # name the df in the list
    names(sjr_journals)[i] <- jr_files[i] %>% str_extract("[0-9]+")
}

sjr_journals <- sjr_journals %>% bind_rows(.id = "year")

devtools::use_data(sjr_journals)

# save(sjr_journals, file = "data/sjr_journals.rda")
#
# system.time(load("data/sjr_journals.rda"))




# SJR country ranking -----------------------------------------------------

cr_dir <- "data-raw/sjr-country/"

cr_files <- list.files(cr_dir)

sjr_countries <- list()

for (i in seq_along(cr_files)) {
    # load specific year's data
    dfi <- suppressMessages(
        read_xlsx(path = paste0(cr_dir, cr_files[i]))
    ) %>% clean_names()
    # write the temp df into the list
    sjr_countries[[i]] <- dfi
    # name the df in the list
    names(sjr_countries)[i] <- cr_files[i] %>% str_extract("[0-9]+")
}

sjr_countries <- sjr_countries %>% bind_rows(.id = "year")

devtools::use_data(sjr_countries)

# save(sjr_countries, file = "data/sjr_countries.rda")
#
# system.time(load("data/sjr_countries.rda"))


sjr_countries_1996_2017 <- read_xlsx(
    "data-raw/sjr-country-all-years/scimagojr-country-1996-2017.xlsx"
) %>% clean_names()

devtools::use_data(sjr_countries_1996_2017)

# save(sjr_countries_1996_2017, file = "data/sjr_countries_1996_2017.rda")
