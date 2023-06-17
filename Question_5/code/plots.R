ratings_plot <- function(data){

    category_df <- data %>% dplyr::select(App, Category, Rating, Type) %>%
        filter(Type=="Free"|Type=="Paid") %>%
        mutate(Type= ifelse(Type=="Free", 1,
                            ifelse(Type=="Paid", 0, "NA")))
    category_df$Type <- as.numeric(category_df$Type)
    category_df <-   category_df %>%
        group_by(Category) %>%
        summarise(Rating_avg=mean(Rating, na.rm=TRUE),
                  se_rat = sd(Rating, na.rm=TRUE) / sqrt(n()),
                  Prop_free=(sum(Type, na.rm=TRUE)/n())*100)

    avg_ratings_plot <- ggplot(category_df, aes(x=Category, y=Rating_avg, colour=Prop_free))+
        geom_point()+
        geom_errorbar(aes(ymin = Rating_avg - 1.96*se_rat, ymax = Rating_avg + 1.96*se_rat),
                      width = 0.2, position = position_dodge(0.9))+
        labs( title = "Average ratings by app category",
              x = "Categories",
              y = "Average rating of apps in specific category",
              colour="Proportion of apps\nin category that are free") +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))+
        theme(plot.title = element_text(hjust = 0.5))+
        theme(plot.title = element_text(hjust = 0.5, vjust=3))+
        theme(axis.title.y = element_text(margin = margin(r = 10)))+
        theme(axis.title.y = element_text(hjust = 0.5))+
        theme(axis.title.x = element_text(margin = margin(t = 10)))+
        theme(axis.title.x = element_text(hjust = 0.5))+
        theme(plot.margin = margin(15, 10, 15, 10))+
        theme(plot.title = element_text(size = 14, face="bold"),
              axis.text.x = element_text(size = 7),
              legend.title = element_text(size = 9))

    return(avg_ratings_plot)

}

pie_plotter <- function(install_number){


library(ggplot2)

installs_df <- playstore %>%
    filter(Installs== "10,000,000+"| Installs== "50,000,000+"| Installs== "100,000,000+") %>%
    group_by(Installs, Category) %>%
    summarise(cat_count=n()) %>%
    as.data.frame()

pie_plot <- installs_df %>%
    filter(Installs == install_number) %>%
    ggplot(data = ., aes(x = "", y = cat_count, fill = Category)) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar("y", start = 0) +
    labs(title = "Categories of apps with more than 100 000 000 installs",
         y = "Number of categories") +
    theme(plot.title = element_text(size = 14, face = "bold")) +
    theme_minimal()

return(pie_plot)
}

reviews_plot <- function(review_sentiment){


    reviews <- reviews %>% dplyr::select(App, Sentiment, Sentiment_Subjectivity)
    app_df <- playstore %>% dplyr::select(App, Category)
    apps_reviewed <- left_join(reviews, app_df, "App") %>%
        filter(Sentiment!="nan"|Category=="NA")

    merged_df <- left_join(playstore, reviews, "App") %>%
        dplyr::select(App, Category, Sentiment) %>%
        group_by(Category, Sentiment) %>%
        summarise(count=n()) %>%
        na.omit() %>%
        filter(Sentiment!="nan") %>%
        ungroup() %>%
        group_by(Category) %>%
        mutate(sum=sum(count)) %>%
        mutate(Percent=(count/sum)*100)


    review_sentiment <- ggplot(merged_df, aes(x=Category, y=Percent, fill=Sentiment))+
        geom_bar(stat="identity")+
        labs(title="App reviews classified according to sentiment by category",
             x="App category",
             y= "Percent")+
        theme(plot.title = element_text(hjust = 0.5, vjust=3))+
        theme(axis.title.y = element_text(margin = margin(r = 10)))+
        theme(axis.title.y = element_text(hjust = 0.5))+
        theme(axis.title.x = element_text(margin = margin(t = 10)))+
        theme(axis.title.x = element_text(hjust = 0.5))+
        theme(plot.margin = margin(15, 10, 15, 10))+
        theme(axis.text.x = element_text(angle = 45, hjust = 1))+
        scale_fill_brewer(palette = "Oranges")+
        theme(plot.title = element_text(size = 14, face="bold"),
              axis.text.x = element_text(size = 7))

    return(review_sentiment)
}

Subjective_sent <- function(sentiment_table){


    category_reviews <- reviews_plot(review_sentiment)
    category_reviews

    subj_df <- left_join(playstore, reviews, "App") %>%
        dplyr::select(App, Category, Sentiment_Subjectivity) %>%
        filter(Sentiment_Subjectivity!="nan") %>%
        na.omit() %>%
        group_by(Category) %>%
        summarise(mean=mean(Sentiment_Subjectivity)) %>%
        arrange(mean) %>%
        head(10)
    colnames(subj_df) <- c("App category", "Average sentiment subjectivity")

    library(xtable)
    sentiment_subj_table <- options(xtable.comment = FALSE) %>% as.data.frame()
    sentiment_table <- xtable(subj_df)
    return(sentiment_table)
}