


# example top journals ----------------------------------------------------

library(tidyverse)
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

