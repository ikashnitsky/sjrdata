# ..........................................................
# 2024-04-22 -- sjrdata
# Illustrate the package using some demographic journals                -----------
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com
# ..........................................................
# UPD 2025-07-04

library(tidyverse)
library(hrbrthemes)
library(sjrdata)

df <- sjr_journals

df %>%
    filter(title %in% c("Nature", "Science")) %>%
    ggplot(aes(citations_doc_2years, sjr, color = title))+
    geom_path(size = 1, alpha = .5)+
    geom_label(aes(label = year %>% str_sub(3, 4)),
              size = 3, label.padding = unit(.15, "line"))+
    scale_color_viridis_d(NULL, end = .4, option = "B")+
    theme_minimal()+
    labs(x = "2-year citation per document (JIF analogue)",
         y = "SJR index",
         title = "Nature vs Science",
         subtitle = "SCImago Journal Rank, 1999--2017",
         caption = "ikashnitsky.github.io")




df %>%
    filter(title %in% c(
        "Demography",
        "Population and Development Review",
        "European Journal of Population",
        "Population Studies",
        "Demographic Research",
        "Genus"
    )) %>%
    ggplot(aes(citations_doc_2years, sjr, color = title))+
    geom_point()+
    stat_ellipse()+
    scale_color_brewer(NULL, palette = "Dark2")+
    coord_cartesian(expand = F)+
    theme_minimal()+
    theme(legend.position  = c(.3, .75))+
    labs(x = "2-year citation per document (JIF analogue)",
         y = "SJR index",
         title = "Selected demographic journals",
         subtitle = "SCImago Journal Rank, 1999--2017",
         caption = "ikashnitsky.github.io")

# UPD 2022-05-18
# UPD 2023-12-06
# UPD 2025-07-04

library(showtext)
sysfonts::font_add_google("Atkinson Hyperlegible", "ah")
showtext_auto()

# set ggplot2 theme
devtools::source_gist("653e1040a07364ae82b1bb312501a184")
theme_set(theme_ik())


df %>%
    filter(title %in% c(
        "Demography",
        "Population and Development Review",
        "European Journal of Population",
        "Population, Space and Place",
        "Demographic Research",
        "Genus"
    )) %>%
    mutate(year = year %>% as.numeric) %>%
    ggplot(aes(year, sjr, color = title))+
    geom_hline(yintercept = 0, size = .75, color = "#3a3a3a")+
    geom_point(aes(size = total_docs_year), alpha = .5)+
    stat_smooth(se = F, span = .75)+
    geom_text(
        data = . %>% filter(year == 2022),
        aes(label = title),
        x = 1998, y = seq(3.7, 2.7, length.out = 6),
        hjust = 0, size = 4, fontface = 2
    )+
    scale_color_brewer(NULL, palette = "Dark2")+
    scale_y_continuous(limits = c(0, 3.7), position = "right")+
    theme(
        legend.position = "none",
        plot.title = element_text(face = 2)
    )+
    labs(
        x = NULL,
        y = "SJR index",
        title = "Selected demographic journals",
        subtitle = "SCImago Journal Rank, 1999-2022, via #rstats {sjrdata}",
        caption = "Ilya Kashnitsky @ikashnitsky.phd"
    )

ggsave("/rout/sjr-demography.pdf", width = 8, height = 6)

# convert pdf to png
devtools::source_gist("c7037e2b1bc6d0d6e38fc4a41de9a8c7")
convert_pdf_to_png(
    "/rout"
)
