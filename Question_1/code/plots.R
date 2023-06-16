plotter <- function(data, y_value, plot_title, y_title){

    library(tidyverse)
    library(RColorBrewer)

    evolution_covid <- data %>% dplyr::select(iso_code, continent, location,
                                                 date, new_cases_per_million,
                                                 new_deaths_per_million, excess_mortality) %>%
        mutate(date=as.Date(date)) %>%
        mutate(year_month=format(date, "%Y-%m")) %>%
        group_by(continent, year_month) %>%
        summarise(new_cases_mil=sum(new_cases_per_million, na.rm=TRUE),
                  new_deaths_mil=sum(new_deaths_per_million, na.rm=TRUE),
                  excess_mort=sum(excess_mortality, na.rm=TRUE)/n()) %>%
        na.omit() %>%
        mutate(new_cases_mil=new_cases_mil/1000000)

    continent_plot <- ggplot(evolution_covid, aes(x=year_month, y=y_value, fill=continent))+
        geom_bar(stat="identity")+
        labs(title=plot_title,
             x="Date",
             y= y_title,
             fill= "Continent")+
        theme(plot.title = element_text(hjust = 0.5, vjust=3))+
        theme(axis.title.y = element_text(margin = margin(r = 10)))+
        theme(axis.title.y = element_text(hjust = 0.5))+
        theme(axis.title.x = element_text(margin = margin(t = 10)))+
        theme(axis.title.x = element_text(hjust = 0.5))+
        theme(plot.margin = margin(15, 10, 15, 10))+
        theme(axis.text.x = element_text(angle = 45, hjust = 1))+
        scale_color_brewer(palette = "Set2")+
        theme(plot.title = element_text(size = 14),
              axis.text.x = element_text(size = 6))

    return(continent_plot)

}



covid_vulnerability <- ggplot(countries, aes(x = total_deaths_per_million, fill = filler)) +
    geom_density(alpha = 0.5) +
    labs(title=graph_title,
         x="Total deaths per million",
         y= "Density",
         fill= filler_title)+
    theme(plot.title = element_text(hjust = 0.5, vjust=3))+
    theme(axis.title.y = element_text(margin = margin(r = 10)))+
    theme(axis.title.y = element_text(hjust = 0.5))+
    theme(axis.title.x = element_text(margin = margin(t = 10)))+
    theme(axis.title.x = element_text(hjust = 0.5))+
    theme(plot.margin = margin(15, 10, 15, 10))+
    scale_color_brewer(palette = "Set2")+
    theme(plot.title = element_text(size = 14))
