# ..........................................................
# 2024-04-22 -- sjrdata
# Illustrate the package using some demographic journals                -----------
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com
# ..........................................................
# UPD 2025-07-04

library(tidyverse)
library(hrbrthemes)
library(sjrdata)

library(showtext)
sysfonts::font_add_google("Atkinson Hyperlegible", "ah")
showtext_auto()

# set ggplot2 theme
devtools::source_gist("653e1040a07364ae82b1bb312501a184")
theme_set(theme_ik())

# assign to have in the global environment
df <- sjr_journals



# Nature vs Science -------------------------------------------------------

df |>
    filter(title %in% c("Nature", "Science")) |>
    ggplot(aes(citations_doc_2years, sjr, color = title))+
    geom_path(size = 1, alpha = .5)+
    geom_label(aes(label = year |> str_sub(3, 4)),
              size = 3, label.padding = unit(.15, "line"))+
    scale_color_viridis_d(NULL, begin = .2, end = .9, option = "H")+
    scale_x_continuous(position = "top")+
    labs(x = "2-year citation per document (JIF analogue)",
         y = "SJR index",
         title = "Nature vs Science",
         subtitle = "SCImago Journal Rank, 1999--2024",
         caption = "ikashnitsky.github.io")

ggsave("/rout/sjr-nature-science.pdf", width = 6, height = 4.5)


df |>
    filter(title %in% c(
        "Demography",
        "Population and Development Review",
        "European Journal of Population",
        "Population Studies",
        "Demographic Research",
        "Genus"
    )) |>
    ggplot(aes(citations_doc_2years, sjr, color = title))+
    geom_point()+
    stat_ellipse(size = .25)+
    geom_text(
        data = . %>% filter(year == 2024) %>% distinct(title),
        aes(label = title),
        x = -.5, y = seq(3.2, 2.5, length.out = 6),
        hjust = 0, size = 4, fontface = 2
    )+
    scale_color_viridis_d(NULL, begin = .26, end = .92, option = "H")+
    coord_cartesian(expand = F)+
    theme(legend.position  = "none")+
    labs(x = "2-year citation per document (JIF analogue)",
         y = "SJR index",
         title = "Selected demographic journals",
         subtitle = "SCImago Journal Rank, 1999--2024",
         caption = "ikashnitsky.github.io")

ggsave("/rout/sjr-dem-vs-2years-cite.pdf", width = 8, height = 6)



# hand-picked demographic journals ----------------------------------------
df |>
    filter(title %in% c(
        "Demography",
        "Population and Development Review",
        "European Journal of Population",
        "Population, Space and Place",
        "Demographic Research",
        "Genus"
    )) |>
    mutate(year = year |> as.numeric()) |>
    ggplot(aes(year, sjr, color = title))+
    geom_hline(yintercept = 0, size = .75, color = "#3a3a3a")+
    geom_point(aes(size = total_docs_year), alpha = .5)+
    stat_smooth(se = F, span = .75)+
    geom_text(
        data = . %>% filter(year == 2024) %>% distinct(title),
        aes(label = title),
        x = 1998, y = seq(3.7, 2.7, length.out = 6),
        hjust = 0, size = 4, fontface = 2
    )+
    scale_color_viridis_d(NULL, begin = .26, end = .92, option = "H")+
    scale_y_continuous(limits = c(0, 3.7), position = "right")+
    theme(
        legend.position = "none",
        plot.title = element_text(face = 2)
    )+
    labs(
        x = NULL,
        y = "SJR index",
        title = "Selected demographic journals",
        subtitle = "SCImago Journal Rank, 1999-2024, via #rstats {sjrdata}",
        caption = "Ilya Kashnitsky @ikashnitsky.phd"
    )

ggsave("/rout/sjr-dem-journals.pdf", width = 8, height = 6)



# explore percentage women ------------------------------------------------

df |>
    filter(title %in% c(
        "Demography",
        "Population and Development Review",
        "European Journal of Population",
        "Population, Space and Place",
        "Demographic Research",
        "Genus"
    )) |>
    mutate(year = year |> as.numeric()) |>
    ggplot(aes(year, percent_female, color = title))+
    geom_hline(yintercept = 0, size = .75, color = "#3a3a3a")+
    geom_hline(yintercept = 50, size = .75, color = "#f0f")+
    # geom_path()
    geom_point(aes(size = total_docs_year), alpha = .5)+
    stat_smooth(se = F, span = .75)+
    scale_size_area(max_size = 3)+
    geom_text(
        data = . %>% filter(year == 2024) %>% distinct(title),
        aes(label = title),
        x = 1998, y = seq(67, 52, length.out = 6),
        hjust = 0, size = 4, fontface = 2
    )+
    scale_color_viridis_d(NULL, begin = .26, end = .92, option = "H")+
    scale_y_continuous(limits = c(0, 67), position = "right")+
    theme(
        legend.position = "none",
        plot.title = element_text(face = 2)
    )+
    labs(
        x = NULL,
        y = "Percentage female",
        title = "Selected demographic journals",
        subtitle = "SCImago Journal Rank, 1999-2024, via #rstats {sjrdata}",
        caption = "Ilya Kashnitsky @ikashnitsky.phd"
    )

ggsave("/rout/sjr-dem-perc-female.pdf", width = 8, height = 6)

# convert to png ----------------------------------------------------------

# convert pdf to png
devtools::source_gist("c7037e2b1bc6d0d6e38fc4a41de9a8c7")
convert_pdf_to_png("/rout")
