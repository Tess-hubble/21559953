
genres <- function(data, Terms = c("documentation", 'crime', 'drama', 'fantasy', 'comedy', 'horror', 'thriller', 'action', 'animation', 'romance', 'family', 'western', 'war', 'history', 'scifi', 'reality')){

    genre_freq <-
        data %>%
        group_by(release_year) %>% summarise(Percent = sum( grepl( paste(Terms, collapse = "|"), genres )) / n()) %>%
        mutate(Term = glue::glue_collapse(Terms, sep = ", ", last = " and ") )

    genre_freq

}

transformer_df <- function(type_title){

    df <- titles %>% filter(type==type_title) %>%
        arrange(desc(imdb_score)) %>%
        filter(imdb_score>8) %>%
        select(title, release_year, genres, imdb_score)

genre_df <- bind_rows(genres(df, Terms = c("documentation")),
                      genres(df, Terms = c("crime")),
                      genres(df, Terms = c("drama")),
                      genres(df, Terms = c("fantasy")),
                      genres(df, Terms = c("comedy")),
                      genres(df, Terms = c("horror")),
                      genres(df, Terms = c("thriller")),
                      genres(df, Terms = c("action")),
                      genres(df, Terms = c("animation")),
                      genres(df, Terms = c("romance")),
                      genres(df, Terms = c("family")),
                      genres(df, Terms = c("western")),
                      genres(df, Terms = c("war")),
                      genres(df, Terms = c("history")),
                      genres(df, Terms = c("scifi")),
                      genres(df, Terms = c("reality"))) %>%
    mutate(Percent = (round(Percent*100, 3))) %>%
    as.data.frame()

return(genre_df)
}


genre_plotter <- function(data, graph_title){

data %>% filter(release_year>=2010) %>%
    ggplot(aes(x=release_year, y=Percent, fill=Term))+
    geom_bar(stat="identity", position="dodge")+
    labs( title = graph_title,
          x = "Release year",
          y = "Proportion") +
    theme(plot.title = element_text(hjust = 0.5, vjust = 3))+
    theme(axis.title.y = element_text(margin = margin(r = 10)))+
    theme(axis.title.y = element_text(hjust = 0.5))+
    theme(axis.title.x = element_text(margin = margin(t = 10)))+
    theme(axis.title.x = element_text(hjust = 0.5))+
    theme(plot.margin = margin(15, 10, 15, 10))

}

popular_actors <- function(popular_actors){

    credits <- credits %>% dplyr::select(id, name, character)
    titles_actors <- left_join(titles, credits, "id") %>%
        dplyr::select(title, imdb_score, name, production_countries) %>%
        group_by(name) %>%
        summarise(imdb_avg=mean(imdb_score)) %>%
        na.omit() %>%
        arrange(desc(imdb_avg)) %>%
        head(20)
    colnames(titles_actors) <- c("Name", "Average imdb score")

    top_movies <- left_join(titles, credits, "id") %>%
        dplyr::select(title, imdb_score, name, title, type, release_year) %>%
        group_by(name) %>%
        arrange(desc(imdb_score)) %>%
        slice(1) %>%
        rename(Name=name)

    final_actor_df <- inner_join(titles_actors, top_movies, "Name") %>%
        dplyr::select(-imdb_score)
    colnames(final_actor_df) <- c("Name", "Average imdb score", "Highest rated movie/series", "Type", "Release year")

    library(xtable)
    popular_actors <- options(xtable.comment = FALSE) %>% as.data.frame()
    popular_actors <- xtable(final_actor_df)

    return(popular_actors)
}
