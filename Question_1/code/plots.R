data_transformer <- function(data){

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

    return(evolution_covid)
}

plotter <- function(data, y_value, plot_title, y_title){

        library(RColorBrewer)


    continent_plot <- ggplot(data, aes(x=year_month, y=y_value, fill=continent))+
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
        theme(plot.title = element_text(size = 14, face="bold"),
              axis.text.x = element_text(size = 6))

    return(continent_plot)

}


vulnerability_transformations <- function(data){

    country_covid <- data %>% dplyr::select(iso_code, continent, location, date,
                                               stringency_index, population_density, aged_70_older,
                                               extreme_poverty, diabetes_prevalence,
                                               life_expectancy) %>%
        group_by(iso_code,location) %>%
        summarise(stringency_avg=sum(stringency_index, na.rm=TRUE)/n(),
                  pop_density_avg=sum(population_density, na.rm=TRUE)/n(),
                  age_70_older_avg= sum(aged_70_older, na.rm=TRUE)/n(),
                  pov_avg=sum(extreme_poverty, na.rm=TRUE)/n(),
                  diabetes_prev_avg=sum(diabetes_prevalence, na.rm=TRUE)/n(),
                  life_exp_avg= sum(life_expectancy, na.rm=TRUE)/n()) %>%
        rename(Entity=location) %>%
        rename(Code=iso_code)

    country_covid_stats <- data %>% dplyr::select(iso_code, continent, location, date,
                                                     total_cases_per_million, total_deaths_per_million) %>%
        group_by(iso_code, location) %>%
        slice(n()) %>%
        rename(Entity=location) %>%
        rename(Code=iso_code)

    countries <- inner_join(country_covid, country_covid_stats, c("Code", "Entity"))
    countries <- countries %>% mutate(Aged_population=ifelse(age_70_older_avg<5, "Less than 5 percent",
                                                             ifelse(age_70_older_avg>=5 & age_70_older_avg<10, "Between 5 and 10 percent",
                                                                    ifelse(age_70_older_avg>=10 & age_70_older_avg<15, "Between 10 and 15 percent",
                                                                           ifelse(age_70_older_avg>=15, "Above 15 percent", "NA"))))) %>%
        mutate(poverty=ifelse(pov_avg<5, "Less than 5 percent",
                              ifelse(pov_avg>=5 & pov_avg<10, "Between 5 and 10 percent",
                                     ifelse(pov_avg>=10 & pov_avg<15, "Between 10 and 15 percent",
                                            ifelse(pov_avg>=15, "Above 15 percent", "NA"))))) %>%
        mutate(diabetes=ifelse(diabetes_prev_avg<5, "Less than 5 percent",
                               ifelse(diabetes_prev_avg>=5 & diabetes_prev_avg<10,
                                      "Between 5 and 10 percent",
                                      ifelse(diabetes_prev_avg>=10 & diabetes_prev_avg<15,
                                             "Between 10 and 15 percent",
                                             ifelse(diabetes_prev_avg>=15, "Above 15 percent", "NA")))))

    return(countries)
}


density_plotter <- function(data, filler, graph_title, filler_title){

    library(ggplot2)

    covid_vulnerability <- ggplot(data, aes(x = total_deaths_per_million, fill = filler)) +
        geom_density(alpha = 0.65) +
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
        theme(plot.title = element_text(size = 14, face="bold"))

    return(covid_vulnerability)

}

hospital_resp <- function(region, graph_title){

    covid_resp <- owid_df %>% dplyr::select(iso_code, continent, location, date,
                                            weekly_icu_admissions_per_million,
                                            weekly_hosp_admissions_per_million,
                                            hosp_patients_per_million, icu_patients_per_million) %>%
        mutate(date=as.Date(date)) %>%
        mutate(year_month=format(date, "%Y-%m")) %>%
        group_by(continent, year_month) %>%
        summarise(icu_admission=sum(weekly_icu_admissions_per_million, na.rm=TRUE)/n(),
                  hosp_admission=sum(weekly_hosp_admissions_per_million, na.rm=TRUE)/n(),
                  hosp_patients=sum(hosp_patients_per_million, na.rm=TRUE)/n(),
                  icu_patients=sum(icu_patients_per_million, na.rm=TRUE)/n()) %>%
        gather(indicator, value, icu_admission, hosp_admission, hosp_patients, icu_patients)


admissions <- covid_resp %>% filter(continent==region) %>%
    ggplot(aes(x = year_month, y = value, colour = indicator, group=indicator)) +
    geom_line(size=0.6, na.rm = TRUE)+
    labs(title= graph_title,
         x="Date",
         y= "Admissions per million",
         colour= "Type of admission")+
    theme(plot.title = element_text(hjust = 0.5, vjust=3))+
    theme(axis.title.y = element_text(margin = margin(r = 10)))+
    theme(axis.title.y = element_text(hjust = 0.5))+
    theme(axis.title.x = element_text(margin = margin(t = 10)))+
    theme(axis.title.x = element_text(hjust = 0.5))+
    theme(plot.margin = margin(15, 10, 15, 10))+
    theme(axis.text.x = element_text(angle = 45, hjust = 1))+
    scale_color_brewer(palette = "Set2")+
    theme(plot.title = element_text(size = 14, face="bold"),
          axis.text.x = element_text(size = 5))

return(admissions)
}

