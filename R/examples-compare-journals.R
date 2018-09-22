


# example top journals ----------------------------------------------------

library(tidyverse)
library(sjrdata)

df <- df_jr

df %>%
    filter(title %in% c("Nature", "Science")) %>%
    ggplot(aes(cites_doc_2years, sjr, color = title))+
    geom_path(size = 1, alpha = .5)+
    geom_label(aes(label = year %>% str_sub(3, 4)),
              size = 3, label.padding = unit(.15, "line"))


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
    geom_path(arrow = arrow(type = "closed", length = unit(.15, "cm")))+
    facet_wrap(~title, ncol = 3)


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
    scale_color_brewer(palette = "Dark2")+
    coord_cartesian(expand = F)

