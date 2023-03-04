# Environment Setting
setwd('C:/Users/Winson/Documents/UNSW/ACTL4001/Case Study/Data/Cleaned')

#install.packages("pacman")
library("pacman")

p_load("dplyr","cluster", "dbscan", "fitdistrplus")

# Load Data
Hazard_Data_Raw <- read.csv("Hazard Data (Grouped).csv")

# Define Field Data Type
Hazard_Data_Work <- Hazard_Data_Raw
Hazard_Data_Work$Region <- as.factor(Hazard_Data_Raw$Region)
Hazard_Data_Work$Hazard.Event..Grouped. <- as.factor(Hazard_Data_Raw$Hazard.Event..Grouped.)

Hazard_Data_Work <- Hazard_Data_Work %>% mutate(Region_HazardEvent = paste0(Region,Hazard.Event..Grouped.)) %>%
  filter(Property.Damage > 0)

# Hazard_Data_Work_Summary <- Hazard_Data_Work %>% 
#   group_by(Region_HazardEvent) %>%
#   summarise(
#     Count = n()
#     ,Mean_Property_Damage = mean(Property.Damage)
#   ) %>%
#   arrange(Mean_Property_Damage)


Hazard_Data_Cleaned <- Hazard_Data_Work %>% 
  dplyr::select(c("Region","Hazard.Event..Grouped.","Property.Damage"))


row.names(Hazard_Data_Cleaned) <- Hazard_Data_Work$Hazard.Unique.Identifier
#Hazard_Data_Cleaned_Test <- Hazard_Data_Cleaned[1:5,]


# Compute Gower's Dissimilarity
# https://rstudio-pubs-static.s3.amazonaws.com/423873_adfdb38bce8d47579f6dc916dd67ae75.html
set.seed(6)
Gower_df <- daisy(x = Hazard_Data_Cleaned,
                  metric = "gower",
                  stand = TRUE,
                  type = list(logratio = 3))


# Hierarchical Clustering
# https://www.r-bloggers.com/2016/01/hierarchical-clustering-in-r-2/
# Set Number of Clusters
n <- 6
H_Cluster <- hclust(Gower_df)
plot(H_Cluster)
summary(H_Cluster)

# Output Hierarchical Clustering Results
H_Clusters_Cut <- cutree(H_Cluster,n)
table(H_Clusters_Cut, Hazard_Data_Cleaned$Region)
table(H_Clusters_Cut, Hazard_Data_Cleaned$Hazard.Event..Grouped.)

# Append the Clustering Results back to Original Data 
Hazard_Data_H_Cluster <- Hazard_Data_Cleaned %>% mutate(Cluster = H_Clusters_Cut)


# Fitting Gamma Distributions in R
# Cluster_1
Hazard_Data_H_Cluster_1 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 1)

Hazard_Data_H_Cluster_1_fitdist <- fitdist(Hazard_Data_H_Cluster_1$Property.Damage, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_1$Property.Damage)/mean(Hazard_Data_H_Cluster_1$Property.Damage), 
                                                        shape = mean(Hazard_Data_H_Cluster_1$Property.Damage)^2/var(Hazard_Data_H_Cluster_1$Property.Damage)))
summary(Hazard_Data_H_Cluster_1_fitdist)
plot(Hazard_Data_H_Cluster_1_fitdist)

# Cluster_2
Hazard_Data_H_Cluster_2 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 2)

Hazard_Data_H_Cluster_2_fitdist <- fitdist(Hazard_Data_H_Cluster_2$Property.Damage, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_2$Property.Damage)/mean(Hazard_Data_H_Cluster_2$Property.Damage), 
                                                        shape = mean(Hazard_Data_H_Cluster_2$Property.Damage)^2/var(Hazard_Data_H_Cluster_2$Property.Damage)))
summary(Hazard_Data_H_Cluster_2_fitdist)
plot(Hazard_Data_H_Cluster_2_fitdist)

# Cluster_3
Hazard_Data_H_Cluster_3 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 3)

Hazard_Data_H_Cluster_3_fitdist <- fitdist(Hazard_Data_H_Cluster_3$Property.Damage, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_3$Property.Damage)/mean(Hazard_Data_H_Cluster_3$Property.Damage), 
                                                        shape = mean(Hazard_Data_H_Cluster_3$Property.Damage)^2/var(Hazard_Data_H_Cluster_3$Property.Damage)))
summary(Hazard_Data_H_Cluster_3_fitdist)
plot(Hazard_Data_H_Cluster_3_fitdist)

# Cluster_4
Hazard_Data_H_Cluster_4 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 4)

Hazard_Data_H_Cluster_4_fitdist <- fitdist(Hazard_Data_H_Cluster_4$Property.Damage, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_4$Property.Damage)/mean(Hazard_Data_H_Cluster_4$Property.Damage), 
                                                        shape = mean(Hazard_Data_H_Cluster_4$Property.Damage)^2/var(Hazard_Data_H_Cluster_4$Property.Damage)))
summary(Hazard_Data_H_Cluster_4_fitdist)
plot(Hazard_Data_H_Cluster_4_fitdist)

# Cluster_5
Hazard_Data_H_Cluster_5 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 5)

Hazard_Data_H_Cluster_5_fitdist <- fitdist(Hazard_Data_H_Cluster_5$Property.Damage, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_5$Property.Damage)/mean(Hazard_Data_H_Cluster_5$Property.Damage), 
                                                        shape = mean(Hazard_Data_H_Cluster_5$Property.Damage)^2/var(Hazard_Data_H_Cluster_5$Property.Damage)))
summary(Hazard_Data_H_Cluster_5_fitdist)
plot(Hazard_Data_H_Cluster_5_fitdist)
