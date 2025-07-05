# ..........................................................
# 2025-07-04 -- sjrdata
# Download yearly all SJR data           -----------
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com
# ..........................................................

# UPD 2022-05-18 # incremental updates
# UPD 2023-12-06
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
fs::dir_ls("data-raw/sjr-country/") |> str_extract_all("[0-9]+") |> unlist()
# journal starts at 1999
fs::dir_ls("data-raw/sjr-journal/") |> str_extract_all("[0-9]+") |> unlist()




# journals ----------------------------------------------------------------

# create a temp directory for the raw csv files -- to be repacked in a parquet format

if (!dir_exists("data-raw/sjr-journal/tmp")) {
    dir_create("data-raw/sjr-journal/tmp")
}

# a function to download the journal data for a specific year
get_journal <- function(year) {
    the_url <- paste0(
        "https://www.scimagojr.com/journalrank.php?year=",
        year,
        "&out=xls"
    )
    download.file(
        url = the_url,
        destfile = paste0(
            "data-raw/sjr-journal/tmp/scimagojr-journal-", year, ".csv"
        )
    )
    print(year)
}

# # batch download
# UPD 2025-07-04
1999:2024 |> map(get_journal)



# function to read these csv and correct on the fly
read_journal <- function(path) {
    # load specific year's data
    out <- suppressMessages(suppressWarnings(
        read_csv2(path, col_types = "ddcccdcdddddddddddcccccc")
    )) |>
        clean_names()
    # fix the uniquely named column of total docs
    colnames(out)[9] <-
        colnames(out)[9] |>
        str_replace("[0-9]+", "year")
    return(out)
}

# read in all the journal years
sjr_journals <- map_dfr(
    .x = dir_ls("data-raw/sjr-journal/tmp"),
    .f = read_journal,
    .id = "year"
) |>
    mutate(
        year = year |>
            str_extract_all("[0-9]+") |>
            unlist() |>
            as.numeric()
    )


# save the yearly raw data in a parquet format

# # this one saves 2024 update data
# sjr_journals |>
#     write_parquet("data-raw/sjr-journal/sjr_journals-2024.parquet")

# UPD 2025-07-04
sjr_journals |>
    write_parquet("data-raw/sjr-journal/sjr_journals-2025.parquet")

# purge the temp directory
if (dir_exists("data-raw/sjr-journal/tmp")) {
    dir_delete("data-raw/sjr-journal/tmp")
}

# save the merged output to be used in the package update
usethis::use_data(sjr_journals, overwrite = T)



# countries ---------------------------------------------------------------

# create a temp directory for the raw csv files -- to be repacked in a parquet format

if (!dir_exists("data-raw/sjr-country/tmp")) {
    dir_create("data-raw/sjr-country/tmp")
}

# a function to download the country data for a specific year
get_country <- function(year) {
    the_url <- paste0(
        "https://www.scimagojr.com/countryrank.php?year=",
        year,
        "&out=xls"
    )
    download.file(
        url = the_url,
        destfile = paste0(
            "data-raw/sjr-country/tmp/scimagojr-country-", year, ".xlsx"
        ),
        mode = "wb"
    )
    print(year)
}

# batch download
# UPD 2025-07-04
1999:2024 |> map(get_country)

# read in all the country years
sjr_countries <- map_dfr(
    .x = dir_ls("data-raw/sjr-country/tmp/"),
    .f = read_excel,
    .id = "year"
) |>
    clean_names() |>
    mutate(
        year = year |>
            str_extract_all("[0-9]+") |>
            unlist() |>
            as.numeric()
    )


# save the yearly raw data in a parquet format

# # this one saves 2024 update data
# sjr_countries |>
#     write_parquet("data-raw/sjr-country/sjr_countries-2024.parquet")

# UPD 2025-07-04
sjr_countries |>
    write_parquet("data-raw/sjr-country/sjr_countries-2025.parquet")

# purge the temp directory
if (dir_exists("data-raw/sjr-country/tmp")) {
    dir_delete("data-raw/sjr-country/tmp")
}

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

# UPD 2025-07-04
# 2024
get_all_countries(2024)

# read all countries total data
sjr_countries_total <- read_xlsx(
    dir_ls("data-raw/sjr-country-all-years/") |> last()
) |>
    clean_names()

usethis::use_data(sjr_countries_total , overwrite = T)



# DEV LINES ---------------------------------------------------------------

devtools::document()

# devtools::build()  # click button instead

devtools::check()


# explore zap -------------------------------------------------------------


pak::pak("coolbutuseless/zap")

library(zap)
sjr_journals |>
    zap_write("data-raw/sjr-journal/sjr_journals-2025.zap")


# this is a test to see how fast the zap format is
microbenchmark::microbenchmark(
    prquect = sjr_journals |>
        write_parquet("data-raw/sjr-journal/sjr_journals-2025.parquet"),
    zap = sjr_journals |>
        zap_write("data-raw/sjr-journal/sjr_journals-2025.zap"),
    times = 10
)


# this is a test to see how fast the zap format is at reading back
microbenchmark::microbenchmark(
    prquect = read_parquet("data-raw/sjr-journal/sjr_journals-2025.parquet"),
    zap = zap_read(src = "data-raw/sjr-journal/sjr_journals-2025.zap"),
    times = 10
)
