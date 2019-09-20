#===============================================================================
# 2019-09-19 -- sjrdata
# Deal with the downloaded data manually
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com
#===============================================================================

library(tidyverse)
library(magrittr)
library(janitor)
library(readxl)


### BELOW GOES DEPRICIATED CODE FOR DEALING WITH MANUALLY DOWNLOADED FILES

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

usethis::use_data(sjr_journals, overwrite = TRUE)

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

usethis::use_data(sjr_countries, overwrite = TRUE)

# save(sjr_countries, file = "data/sjr_countries.rda")
#
# system.time(load("data/sjr_countries.rda"))


sjr_countries_total <- read_xlsx(
    "data-raw/sjr-country-all-years/scimagojr-country-1996-2018.xlsx"
) %>% clean_names()

usethis::use_data(sjr_countries_total)

# save(sjr_countries_1996_2017, file = "data/sjr_countries_1996_2017.rda")
