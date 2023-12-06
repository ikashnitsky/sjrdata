#===============================================================================
# 2022-05-18 -- sjrdata
# Illustrate the package using some demographic journals
# Ilya Kashnitsky, ilya.kashnitsky@gmail.com, @ikashnitsky
#===============================================================================

library(tidyverse)
library(hrbrthemes)
library(sjrdata)

df <- sjr_journals

df %>%
    filter(title %in% c("Nature", "Science")) %>%
    ggplot(aes(cites_doc_2years, sjr, color = title))+
    geom_path(size = 1, alpha = .5)+
    geom_label(aes(label = year %>% str_sub(3, 4)),
              size = 3, label.padding = unit(.15, "line"))+
    scale_color_viridis_d(NULL, end = .4, option = "B")+
    theme_minimal(base_family = "mono")+
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
    ggplot(aes(cites_doc_2years, sjr, color = title))+
    geom_point()+
    stat_ellipse()+
    scale_color_brewer(NULL, palette = "Dark2")+
    coord_cartesian(expand = F)+
    theme_minimal(base_family = "mono")+
    theme(legend.position = c(.8, .2))+
    labs(x = "2-year citation per document (JIF analogue)",
         y = "SJR index",
         title = "Selected demographic journals",
         subtitle = "SCImago Journal Rank, 1999--2017",
         caption = "ikashnitsky.github.io")

# UPD  2022-05-18 ------------------------------
# UPD  2023-12-06 ------------------------------

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

ggsave("~/Downloads/sjr-demography.pdf", width = 6, height = 4.5)

sjr_countries %>% view
