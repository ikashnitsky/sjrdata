# ..........................................................
# 2026-06-06 -- sjrdata
# Download yearly all SJR data           -----------
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com
# ..........................................................

# UPD 2022-05-18 # incremental updates
# UPD 2023-12-06
# UPD 2024-04-22
# UPD 2025-07-04 back to batch downloading
# in this update I revert back to downloading all the data yearly. This came out of a productive discussion with Mark Hanson, in which he pointed out that SciMago group sometimes changes the data backwards in their update, and that it is better to have a fresh copy of the data every year. Starting from this year I will save a copy of the data for each year in a parquet format.
# UPD 2026-06-05

library(tidyverse)
library(magrittr)
library(janitor)
library(readxl)
library(fs)
library(arrow)
library(httr2)
library(nanoarrow)


# check which years are available -----------------------------------------

# list available years
# country starts at 1996
fs::dir_ls("data-raw/sjr-country/") |> str_extract_all("[0-9]+") |> unlist()
# journal starts at 1999
fs::dir_ls("data-raw/sjr-journal/") |> str_extract_all("[0-9]+") |> unlist()


# journals ----------------------------------------------------------------

# UPD 2026-05-26 new download functions that can bypass the cloudflare screen introduced at SJR website

# Pattern: https://www.scimagojr.com/journalrank.php?out=xls&year=YYYY
# (despite the "xls" param, it actually returns semicolon-separated CSV)

download_sjr_year <- function(year) {
  url <- paste0(
    "https://www.scimagojr.com/journalrank.php",
    "?out=xls&year=",
    year
  )

  out <- httr2::request(url) |>
    httr2::req_headers(
      `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
      `Accept` = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      `Accept-Language` = "en-US,en;q=0.5",
      `Referer` = "https://www.scimagojr.com/"
    ) |>
    httr2::req_retry(max_tries = 3, backoff = ~10) |>
    httr2::req_perform() |>
    httr2::resp_body_string() |>
    readr::read_delim(delim = ";", show_col_types = FALSE)

  # fix the uniquely named column of total docs
  colnames(out)[9] <-
    colnames(out)[9] |>
    str_replace("[0-9]+", "year")

  out <- out |>
    clean_names()

  return(out)
}

sjr_raw <- purrr::map(
  1999:2025,
  download_sjr_year,
  .progress = TRUE
)

sjr_journals_merged <- sjr_raw |>
  set_names(1999:2025) |>
  bind_rows(.id = "year") |>
  # fix names for the yearly changing col name
  unite(
    col = "total_docs_year",
    starts_with(c("total_docs_1", "total_docs_2")),
    remove = TRUE,
    na.rm = TRUE
  ) |>
  # fix double publisher column
  rename(publisher = publisher_6) |>
  select(-publisher_23) |>
  # as numeric
  mutate(
    year = year |> as.numeric(),
    sjr = sjr |>
      str_replace(",", ".") |>
      as.numeric(),
    total_docs_year = total_docs_year |>
      as.numeric(),
    total_docs_3years = total_docs_3years |>
      as.numeric(),
    citations_doc_2years = citations_doc_2years |>
      str_replace(",", ".") |>
      as.numeric(),
    ref_doc = ref_doc |>
      str_replace(",", ".") |>
      as.numeric(),
    percent_female = percent_female |>
      str_replace(",", ".") |>
      as.numeric()
  )

# fix one problematic journal entry
problemaric_wei <- sjr_journals |>
  filter(issn == "10008020") |>
  select(year:publisher) |>
  separate(
    publisher,
    into = colnames(sjr_journals)[7:26],
    sep = ";"
  ) |>
  mutate(
    coverage = "1997-2016",
    categories = "Medicine",
    areas = "Medicine (miscellaneous)",
    # same format fixes
    sjr = sjr |>
      str_replace(",", ".") |>
      as.numeric(),
    h_index = h_index |>
      str_replace(",", ".") |>
      as.numeric(),
    total_docs_year = total_docs_year |>
      as.numeric(),
    total_docs_3years = total_docs_3years |>
      as.numeric(),
    total_refs = total_refs |>
      as.numeric(),
    total_citations_3years = total_citations_3years |>
      as.numeric(),
    citable_docs_3years = citable_docs_3years |>
      as.numeric(),
    overton = overton |>
      as.numeric(),
    citations_doc_2years = citations_doc_2years |>
      str_replace(",", ".") |>
      as.numeric(),
    ref_doc = ref_doc |>
      str_replace(",", ".") |>
      as.numeric(),
    percent_female = percent_female |>
      str_replace(",", ".") |>
      as.numeric()
  )

# apply patch
sjr_journals <- sjr_journals_merged |>
  rows_update(
    problemaric_wei,
    by = c("year", "issn")
  )

## save the yearly raw data in a parquet format ----

# # this one saves 2024 update data
# sjr_journals |>
#     write_parquet("data-raw/sjr-journal/sjr_journals-2024.parquet")

# # UPD 2025-07-04
# sjr_journals |>
#     write_parquet("data-raw/sjr-journal/sjr_journals-2025.parquet")

# UPD 2026-06-05
sjr_journals |>
  write_parquet("data-raw/sjr-journal/sjr_journals-2026.parquet")

# purge the temp directory
if (dir_exists("data-raw/sjr-journal/tmp")) {
  dir_delete("data-raw/sjr-journal/tmp")
}

# save the merged output to be used in the package update
usethis::use_data(sjr_journals, overwrite = T)


# countries ---------------------------------------------------------------

# a function to download the country data for a specific year
download_sjr_country <- function(year) {
  url <- str_glue(
    "https://www.scimagojr.com/countryrank.php?year={year}&out=xls"
  )

  tmp <- str_glue("data-raw/sjr-country/scimagojr-country-{year}.xlsx")
  on.exit(fs::file_delete(tmp), add = TRUE)

  httr2::request(url) |>
    httr2::req_headers(
      `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
      `Accept` = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      `Accept-Language` = "en-US,en;q=0.5",
      `Referer` = "https://www.scimagojr.com/"
    ) |>
    httr2::req_retry(max_tries = 3, backoff = ~10) |>
    httr2::req_perform() |>
    httr2::resp_body_raw() |>
    writeBin(tmp)

  out <- readxl::read_excel(tmp) |>
    clean_names()

  return(out)
}

# batch download
# UPD 2026-06-05
sjr_countries_raw <- purrr::map(
  1996:2025,
  download_sjr_country,
  .progress = TRUE
)

sjr_countries <- sjr_countries_raw |>
  set_names(1996:2025) |>
  bind_rows(.id = "year") |>
  mutate(year = year |> as.numeric())


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

download_sjr_country_total <- function() {
  url <- "https://www.scimagojr.com/countryrank.php?out=xls"

  tmp <- "data-raw/sjr-country/scimagojr-country-total.xlsx"
  on.exit(fs::file_delete(tmp), add = TRUE)

  httr2::request(url) |>
    httr2::req_headers(
      `User-Agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
      `Accept` = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      `Accept-Language` = "en-US,en;q=0.5",
      `Referer` = "https://www.scimagojr.com/"
    ) |>
    httr2::req_retry(max_tries = 3, backoff = ~10) |>
    httr2::req_perform() |>
    httr2::resp_body_raw() |>
    writeBin(tmp)

  out <- readxl::read_excel(tmp) |>
    clean_names()

  return(out)
}
# UPD 2026-06-05
sjr_countries_total <- download_sjr_country_total()

usethis::use_data(sjr_countries_total, overwrite = T)


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
