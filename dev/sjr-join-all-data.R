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

devtools::use_data(df_jr, compress = "xz")


# countries

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

devtools::use_data(df_cr, compress = "xz")


# countries -- all years togetehr

tempi <- tempfile()
pathi <- paste0(tempi, ".xslx")
xlsxi <- download.file(
    url = country_url(
        "https://www.scimagojr.com/countryrank.php?out=xls"
    ),
    destfile = pathi, mode = "wb"
)

assign(
    paste0("df_cr_1996_", last_year),
    read_xlsx(pathi) %>% clean_names()
)

devtools::use_data(get(paste0("df_cr_1996_", last_year)), compress = "xz")



### BELOW GOES DEPRICIATED CODE FOR DEALING WITH MANUALLY DPWNLOADED FILES

# SJR journal ranking -----------------------------------------------------

jr_dir <- "data-raw/sjr-journal/"

jr_files <- list.files(jr_dir)

df_jr <- list()

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
    df_jr[[i]] <- dfi
    # name the df in the list
    names(df_jr)[i] <- jr_files[i] %>% str_extract("[0-9]+")
}

df_jr <- df_jr %>% bind_rows(.id = "year")

devtools::use_data(df_jr, compress = "xz")

# save(df_jr, file = "data/df_jr.rda", compress = "xz")
#
# system.time(load("data/df_jr.rda"))




# SJR country ranking -----------------------------------------------------

cr_dir <- "data-raw/sjr-country/"

cr_files <- list.files(cr_dir)

df_cr <- list()

for (i in seq_along(cr_files)) {
    # load specific year's data
    dfi <- suppressMessages(
        read_xlsx(path = paste0(cr_dir, cr_files[i]))
    ) %>% clean_names()
    # write the temp df into the list
    df_cr[[i]] <- dfi
    # name the df in the list
    names(df_cr)[i] <- cr_files[i] %>% str_extract("[0-9]+")
}

df_cr <- df_cr %>% bind_rows(.id = "year")

devtools::use_data(df_cr, compress = "xz")

# save(df_cr, file = "data/df_cr.rda", compress = "xz")
#
# system.time(load("data/df_cr.rda"))


df_cr_1996_2017 <- read_xlsx(
    "data-raw/sjr-country-all-years/scimagojr-country-1996-2017.xlsx"
) %>% clean_names()

devtools::use_data(df_cr_1996_2017, compress = "xz")

# save(df_cr_1996_2017, file = "data/df_cr_1996_2017.rda", compress = "xz")
