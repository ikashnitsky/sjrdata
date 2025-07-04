#===============================================================================
# 2019-09-19 -- bibliometrics
# Get SJR data for the last year from the web
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com
#===============================================================================
# UPD 2022-05-18
# UPD 2023-12-06 # incremental updates
# UPD 2024-04-22
# UPD 2025-07-04 back to batch downloading
# in this update I revert back to downloading all the data yearly. This came out of a productive discussion with Mark Hanson, in which he pointed out that SciMago group sometimes changes the data backwards in their update, and that it is better to have a fresh copy of the data every year. Starting from this year I will save a copy of the data for each year in a parquet format.

library(tidyverse)
library(magrittr)
library(janitor)
library(readxl)
library(fs)
library(arrow)


# check which years are available -----------------------------------------

# list available years
# country starts at 1996
fs::dir_ls("data-raw/sjr-country/") %>% str_extract_all("[0-9]+") %>% unlist()
# journal starts at 1999
fs::dir_ls("data-raw/sjr-journal/") %>% str_extract_all("[0-9]+") %>% unlist()




# journals ----------------------------------------------------------------

get_journal <- function(year) {
    the_url <- paste0(
        "https://www.scimagojr.com/journalrank.php?year=",
        year,
        "&out=xls"
    )
    download.file(
        url = the_url,
        destfile = paste0(
            "data-raw/sjr-journal/scimagojr-journal-", year, ".csv"
        )
    )
    print(year)
}

# # batch download
# 1999:2021 %>% map(get_journal)

# incremental
# # UPD  2022-05-18
# # 2021
# get_journal(2021)

# UPD  2023-12-06
# 2022
get_journal(2022)
# UPD  2024-04-22
# 2023
get_journal(2023)




# function to read these csv and correct on the fly
read_journal <- function(path) {
    # load specific year's data
    out <- suppressMessages(suppressWarnings(
        read_csv2(path)
    )) %>%
        clean_names()
    # fix the uniquely named column of total docs
    colnames(out)[9] <-
        colnames(out)[9] %>%
        str_replace("[0-9]+", "year")
    return(out)
}

# read in all the journal years
sjr_journals <- map_dfr(
    .x = dir_ls("data-raw/sjr-journal/"),
    .f = read_journal,
    .id = "year"
) %>%
    mutate(year = year %>% str_extract_all("[0-9]+") %>% unlist())

# save the merged output
usethis::use_data(sjr_journals, overwrite = T)



# countries ---------------------------------------------------------------

get_country <- function(year) {
    the_url <- paste0(
        "https://www.scimagojr.com/countryrank.php?year=",
        year,
        "&out=xls"
    )
    download.file(
        url = the_url,
        destfile = paste0(
            "data-raw/sjr-country/scimagojr-country-", year, ".xlsx"
        )
    )
    print(year)
}

# # batch download
# 1999:2021 %>% map(get_country)

# incremental
# # UPD  2022-05-18
# # 2021
# get_country(2021)

# UPD  2023-12-06
# 2022
get_country(2022)
# UPD  2024-04-22
# 2023
get_country(2023)



# read in all the country years
sjr_countries <- map_dfr(
    .x = dir_ls("data-raw/sjr-country/"),
    .f = read_xlsx,
    .id = "year"
) %>%
    clean_names() %>%
    mutate(year = year %>% str_extract_all("[0-9]+") %>% unlist())

# save the merged output
usethis::use_data(sjr_countries, overwrite = T)



# countries -- all years together -----------------------------------------

get_all_countries <- function(last_year) {
    download.file(
        url = paste0(
            "https://www.scimagojr.com/countryrank.php?out=xls"
        ),
        destfile = paste0(
            "data-raw/sjr-country-all-years/scimagojr-country-1996-",
            last_year, ".xlsx"
        ),
        mode = "wb"
    )
}

# # UPD  2022-05-18
# # 2021
# get_all_countries(2021)

# UPD  2023-12-06
# 2022
# get_all_countries(2022)

# UPD  2024-04-22
# 2023
get_all_countries(2023)

# read all countries total data
sjr_countries_total <- read_xlsx(
    dir_ls("data-raw/sjr-country-all-years/") %>% last
) %>%
    clean_names()

usethis::use_data(sjr_countries_total , overwrite = T)



# DEV LINES ---------------------------------------------------------------

devtools::document()

# devtools::build()  # click button instead

devtools::check()
