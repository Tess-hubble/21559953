df_transformer <- function(data){


    temps <- data %>%
        select(year_month, DT00, DT32, DX32, DX70, EMXT) %>%
        mutate(year = year(year_month)) %>%
        group_by(year) %>%
        summarise(min_temp_lowest=sum(DT00),
                  min_temp_zero=sum(DT32),
                  max_temp_zero=sum(DX32),
                  max_temp_high=sum(DX70),
                  max_month_temp=mean(EMXT)) %>%
        gather(temp, value, min_temp_lowest, min_temp_zero, max_temp_zero, max_temp_high)

    return(temps)
}


density_plotter <- function(data){

library(ggplot2)
library(ggridges)

Temperature_plot <- ggplot(data, aes(y = temp, x = value, fill = temp)) +
    geom_density_ridges(scale = 2, alpha = 0.6) +
    labs(title = "",
         x = "Number of days within a year that fall into each temperature category",
         y = "Density",
         fill = "Temperature categories")+
    scale_fill_manual(values = c("#F8766D", "#7CAE00", "#00BFC4", "#C77CFF"),
                      breaks = c("max_temp_high", "max_temp_zero", "min_temp_lowest",
                                 "min_temp_zero"),
                      labels = c("Max temp < 21.1 degrees", "Max temp < 0 degrees",
                                 "Min temp < -17.8 degrees", "Min temp < 0"))+
    theme(axis.text.y = element_blank())+
    theme(plot.margin = margin(8, 8, 8, 8))+
    theme(legend.position = "bottom",
          legend.justification = "center")+
    theme(plot.title = element_text(hjust = 0.5, vjust = 2))+
    theme(legend.title = element_text(size = 10, margin = margin(b = 10)))

return(Temperature_plot)
}

line_plotter <- function(data){

    temp_avg_plot <- ggplot(data, aes(x=year, y=max_month_temp))+
        geom_line()+
        labs(title = "Average highest temperature between 1881 and 2023 ",
             x = "Year",
             y = "Average highest maximum temperature",
             fill = "Temperature categories")+
        theme(plot.title = element_text(hjust = 0.5, vjust=3))+
        theme(axis.title.y = element_text(margin = margin(r = 10)))+
        theme(axis.title.y = element_text(hjust = 0.5))+
        theme(axis.title.x = element_text(margin = margin(t = 10)))+
        theme(axis.title.x = element_text(hjust = 0.5))+
        theme(plot.margin = margin(15, 10, 15, 10))+
        scale_color_brewer(palette = "Oranges")+
        ylim(0,25)

    return(temp_avg_plot)
}


table_formatter <- function(london){

    london$date <- as.character(london$date)
    london$date <- as.Date(london$date, format="%Y%m%d")

    london_weather <- london %>%
        dplyr::select(date, cloud_cover, sunshine, precipitation) %>%
        group_by(year=year(date)) %>%
        mutate(Decade=ifelse(year>=1979 & year<1990, "1980s",
                             ifelse(year>=1990 & year<2000, "1990s",
                                    ifelse(year>=2000 & year<2010, "2000s",
                                           ifelse(year>=2010 & year<=2020, "2010s"))))) %>%
        ungroup() %>%
        group_by(Decade) %>%
        summarise(avg_cloud=mean(cloud_cover, na.rm=TRUE),
                  avg_sunshine=mean(sunshine, na.rm=TRUE),
                  avg_precip=mean(precipitation, na.rm=TRUE))

    library(xtable)

    Table_london <- options(xtable.comment = FALSE) %>% as.data.frame()
    Table_london <- xtable(london_weather)

    return(Table_london)
}