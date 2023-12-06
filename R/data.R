# Data --------------------------------------------------------------------

#' SCImago Journal Rank
#'
#' SCImago Journal Rank for all journals indexed by Scopus in 1999--2022
#'
#' @format
#'   A tibble with 648,453 rows and 22 variables:
#'   \describe{
#'     \item{year}{Year of SCImago Journal Ranking calculation.}
#'     \item{rank}{Rank of the journal among all journals.}
#'     \item{sourceid}{Database ID of the journal.}
#'     \item{title}{Journal's title.}
#'     \item{type}{Type: "journal", "book series", "trade journal", or "conference and proceedings"}
#'     \item{issn}{ISSN journal identifier.}
#'     \item{sjr}{SCImago Journal Rank indicator. It expresses the average number of weighted citations received in the selected year by the documents published in the selected journal in the three previous years, --i.e. weighted citations received in year X to documents published in the journal in years X-1, X-2 and X-3. See [detailed description of SJR](https://www.scimagojr.com/SCImagoJournalRank.pdf) (PDF).}
#'     \item{sjr_best_quartile}{Highest quartile of the journal among all categories it belongs to.}
#'     \item{h_index}{Hirsch index of the journal. The h index expresses the journal's number of articles (h) that have received at least h citations. It quantifies both journal scientific productivity and scientific impact and it is also applicable to scientists, countries, etc. ([see H-index Wikipedia definition](http://en.wikipedia.org/wiki/Hirsch_number)).}
#'     \item{total_docs_year}{Total number of published documents within a specific year. All types of documents are considered, including citable and non citable documents.}
#'     \item{total_docs_3years}{Published documents in the three previous years (selected year documents are excluded), i.e.when the year X is selected, then X-1, X-2 and X-3 published documents are retrieved. All types of documents are considered, including citable and non citable documents.}
#'     \item{total_refs}{Total number of citations received by a journal to the documents published within a specific year.}
#'     \item{total_cites_3years}{Number of citations received in the selected year by a journal to the documents published in the three previous years, --i.e. citations received in year X to documents published in years X-1, X-2 and X-3. All types of documents are considered.}
#'     \item{citable_docs_3years}{Number of citable documents published by a journal in the three previous years (selected year documents are excluded). Exclusively articles, reviews and conference papers are considered..}
#'     \item{cites_doc_2years}{Average citations per document in a 2 year period. It is computed considering the number of citations received by a journal in the current year to the documents published in the two previous years, --i.e. citations received in year X to documents published in years X-1 and X-2. Comparable to Journal Impact Factor.}
#'     \item{ref_doc}{Average number of references per document in the selected year..}
#'     \item{country}{Country of the publisher.}
#'     \item{region}{Region of the publisher.}
#'     \item{publisher}{Publisher of the journal.}
#'     \item{coverage}{Years covered.}
#'     \item{categories}{Categories the journal belongs to.}
#'     \item{area}{Areas of science. Only appeared in 2022.}
#'   }
#'
#' @source
#'   SCImago, (n.d.). SJR — SCImago Journal & Country Rank [Portal]. Retrieved 2023-12-06, from http://www.scimagojr.com
#'   \url{https://www.scimagojr.com/journalrank.php}
#'
#' @examples
#'
#' \dontrun{
#' library(tidyverse)
#' library(sjrdata)
#'
#' # Nature VS Science
#' sjr_journals %>%
#'     filter(title %in% c("Nature", "Science")) %>%
#'     ggplot(aes(cites_doc_2years, sjr, color = title))+
#'     geom_path(size = 1, alpha = .5)+
#'     geom_label(aes(label = year %>% str_sub(3, 4)),
#'                size = 3, label.padding = unit(.15, "line"))
#'
#' # Demographic journals
#' sjr_journals %>%
#'     filter(title %in% c(
#'         "Demography",
#'         "Population and Development Review",
#'         "European Journal of Population",
#'         "Population Studies",
#'         "Demographic Research",
#'         "Genus"
#'     )) %>%
#'     ggplot(aes(cites_doc_2years, sjr, color = title))+
#'     geom_point()+
#'     stat_ellipse()+
#'     scale_color_brewer(palette = "Dark2")+
#'     coord_cartesian(expand = F)
#' }
"sjr_journals"


#' SCImago Country Rank
#'
#' SCImago Country Rank for all papers indexed by Scopus in 1996--2022. Calculations year-by-year.
#'
#' @format
#'   A tibble with 6094 rows and 10 variables:
#'   \describe{
#'     \item{year}{Year of SCImago Country Ranking calculation.}
#'     \item{rank}{Rank of the country in a given year.}
#'     \item{country}{Name of country.}
#'     \item{region}{Region of the world.}
#'     \item{documents}{Number of documents published during the selected year. It is usually called the country's scientific output.}
#'     \item{citable_documents}{Selected year citable documents. Exclusively articles, reviews and conference papers are considered.}
#'     \item{citations}{Number of citations by the documents published during the source year, --i.e. citations in years X, X+1, X+2, X+3... to documents published during year X. When referred to the period 1996-2022, all published documents during this period are considered.}
#'     \item{self_citations}{Country self-citations. Number of self-citations of all dates received by the documents published during the source year, --i.e. self-citations in years X, X+1, X+2, X+3... to documents published during year X. When referred to the period 1996-2022, all published documents during this period are considered.}
#'     \item{citations_per_document}{Average citations per document published during the source year, --i.e. citations in years X, X+1, X+2, X+3... to documents published during year X. When referred to the period 1996-2022, all published documents during this period are considered.}
#'     \item{h_index}{Hirsch index of the country's scientific output.}
#'   }
#'
#' @source
#'   SCImago, (n.d.). SJR — SCImago Journal & Country Rank [Portal]. Retrieved 2023-12-06, from http://www.scimagojr.com
#'   \url{https://www.scimagojr.com/countryrank.php}
"sjr_countries"


#' SCImago Country Rank
#'
#' SCImago Country Rank for all papers indexed by Scopus in 1996--2022. Calculations for the whole period.
#'
#' @format
#'   A tibble with 243 rows and 9 variables:
#'   \describe{
#'     \item{rank}{Rank of the country in a given year.}
#'     \item{country}{Name of country.}
#'     \item{region}{Region of the world.}
#'     \item{documents}{Number of documents published during the selected year. It is usually called the country's scientific output.}
#'     \item{citable_documents}{Selected year citable documents. Exclusively articles, reviews and conference papers are considered.}
#'     \item{citations}{Number of citations by the documents published during the source year, --i.e. citations in years X, X+1, X+2, X+3... to documents published during year X. When referred to the period 1996-2022, all published documents during this period are considered.}
#'     \item{self_citations}{Country self-citations. Number of self-citations of all dates received by the documents published during the source year, --i.e. self-citations in years X, X+1, X+2, X+3... to documents published during year X. When referred to the period 1996-2022, all published documents during this period are considered.}
#'     \item{citations_per_document}{Average citations per document published during the source year, --i.e. citations in years X, X+1, X+2, X+3... to documents published during year X. When referred to the period 1996-2022, all published documents during this period are considered.}
#'     \item{h_index}{Hirsch index of the country's scientific output.}
#'   }
#'
#' @source
#'   SCImago, (n.d.). SJR — SCImago Journal & Country Rank [Portal]. Retrieved 2023-12-06, from http://www.scimagojr.com
#'   \url{https://www.scimagojr.com/countryrank.php}
"sjr_countries_total"
