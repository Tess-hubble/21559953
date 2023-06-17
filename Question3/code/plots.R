# creating a dataframe without live albums and then creating a bubble plot of respecitve albums by different components

df_transformation <- function(data){

    band_df <- data %>% dplyr::select(name, album_name, energy, instrumentalness, tempo, valence,
                                      popularity, tempo, duration, danceability, band) %>%
        filter(!grepl("live|Live", name)) %>%
        filter(!grepl("live|Live", album_name))
    return(band_df)
}

album_plotter <- function(data, album_title){

    library("viridis")

    album_attrib <- ggplot(data, aes(x=energy, y=valence, size = instrumentalness, color = album_name)) +
        geom_point(alpha=0.7) +
        scale_color_viridis(discrete=TRUE)+
        labs(title=album_title,
             x="Energy",
             y= "Valence",
             size = "Instrumentalness",
             color = "Album name")+
        theme(plot.title = element_text(hjust = 0.5, vjust=3, face="bold"))+
        theme(axis.title.y = element_text(margin = margin(r = 10)))+
        theme(axis.title.y = element_text(hjust = 0.5))+
        theme(axis.title.x = element_text(margin = margin(t = 10)))+
        theme(axis.title.x = element_text(hjust = 0.5))+
        theme(plot.margin = margin(20,20, 20,20))+
        theme(legend.text = element_text(size = 7))

    return(album_attrib)

}

# Merging two datasets and comparing bands directly against 

direct_comparison <- function(bands_plot){

    all_bands <- rbind(songs_coldplay, songs_metallica)

    bands_plot <- ggplot(all_bands, aes(y= danceability, x=tempo, colour=band, group=band))+
        geom_point()+
        scale_color_viridis(discrete=TRUE)+
        labs(title="Comparing Coldplay and Metallica songs by danceability and tempo",
             x="Tempo",
             y= "Danceability",
             color = "Band")+
        theme(plot.title = element_text(hjust = 0.5, vjust=3, face="bold"))+
        theme(axis.title.y = element_text(margin = margin(r = 10)))+
        theme(axis.title.y = element_text(hjust = 0.5))+
        theme(axis.title.x = element_text(hjust = 0.5))+
        theme(plot.margin = margin(20,20, 20,20))

    return(bands_plot)
}

# Determining the industry average valence etc for bands in same genre as metallica and coldplay

genre_comparison <- function(genre_bar){

    genre_comp_df <- spotify %>%
        dplyr::select(name, artist, year, energy, instrumentalness, tempo, valence) %>%
        filter(grepl("rock|alternative|indie", spotify$tags)) %>%
        arrange(year) %>%
        group_by(year) %>%
        summarise(avg_energy=mean(energy),
                  avg_instrumentalness=mean(instrumentalness),
                  avg_valence=mean(valence)) %>%
        gather(Indicator, value, avg_energy, avg_instrumentalness, avg_valence) %>%
        filter(year>2000)

    genre_bar <-  genre_comp_df %>%
        ggplot(aes(x=year, y=value, fill=Indicator))+
        geom_bar(stat="identity", position="dodge")+
        labs(title="Average energy, instrumentalness and valence within the
         rock/alternative/indie genre",
             x="Year",
             y= "Value",
             fill= "Musical component")+
        theme(plot.title = element_text(hjust = 0.5, vjust=3, face="bold"))+
        theme(axis.title.y = element_text(margin = margin(r = 10)))+
        theme(axis.title.y = element_text(hjust = 0.5))+
        theme(axis.title.x = element_text(margin = margin(t = 10)))+
        theme(axis.title.x = element_text(hjust = 0.5))+
        theme(plot.margin = margin(20, 20, 30, 20, "pt"))+
        scale_fill_viridis(discrete=TRUE)

    return(genre_bar)
}

# plotting albums by popularity

popular_album_plotter <- function(data, graph_title){

    album_plot <- ggplot(data, aes(x=album_name, y=mean))+
        geom_point()+
        geom_errorbar(aes(ymin = mean - 1.96*se, ymax = mean + 1.96*se),
                      width = 0.2, position = position_dodge(0.9))+
        scale_fill_brewer(palette="Dark2") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))+
        labs( title = graph_title,
              x = "Albums",
              y = "Average popularity")+
        theme(plot.title = element_text(hjust = 0.5, face="bold"))+
        theme(plot.margin = margin(15, 10, 15, 10))

    return(album_plot)
}
