# Environment setting
setwd('C:/Users/Winson/Documents/UNSW/ACTL4001/Case Study/Data/Cleaned')

#install.packages("pacman")
library("pacman")

p_load("dplyr","cluster", "dbscan", "fitdistrplus", "tibble")

# Load data
Hazard_Data_Raw <- read.csv("Hazard Data (Grouped).csv")
Economic_Data_Raw <- read.csv("Interest-Inflation.csv")
Region_Data_Raw <- read.csv("Demographic-Economic.csv")

# Economic_Data_Raw Data Fix, Row: Year = 2003, Column: Inflation
# The 2003 inflation rate is estimated by taking the average between the 2002 and 2004 inflation rates
Economic_Data_Raw$Inflation[Economic_Data_Raw$Year == 2003] <- 0.5*(Economic_Data_Raw$Inflation[Economic_Data_Raw$Year == 2002] + Economic_Data_Raw$Inflation[Economic_Data_Raw$Year == 2004])


# Define field data type
Hazard_Data_Work <- Hazard_Data_Raw
Hazard_Data_Work$Region <- as.factor(Hazard_Data_Raw$Region)
Hazard_Data_Work$Hazard.Event..Grouped. <- as.factor(Hazard_Data_Raw$Hazard.Event..Grouped.)

#Compute the cumulative inflation rate and store it in Economic_Data_Work
Economic_Data_Work <- data.frame(Year = 1960:2021, Cumulative_Inflation = rep(1,n=2021-1960+1)) 

for(i in Economic_Data_Raw$Year){
  Economic_Data_Work$Cumulative_Inflation[Economic_Data_Work$Year == i] <- Economic_Data_Work$Cumulative_Inflation[Economic_Data_Work$Year == i-1] * (1 + Economic_Data_Raw$Inflation[Economic_Data_Raw$Year == i])
}



#Compute the mean Property Value (based on Property Value distribution)
Property_Value_Distribution_Mean <- c(25000, 75000, 125000, 175000, 225000, 275000, 350000, 450000, 625000, 875000, 1250000, 1750000, 2250000)

Property_Value_Data <- Region_Data_Raw %>%
  filter(grepl("Property Value distribution*",Field))

#Change data type
Property_Value_Data$Region.1 <- as.numeric(Property_Value_Data$Region.1)
Property_Value_Data$Region.2 <- as.numeric(Property_Value_Data$Region.2)
Property_Value_Data$Region.3 <- as.numeric(Property_Value_Data$Region.3)
Property_Value_Data$Region.4 <- as.numeric(Property_Value_Data$Region.4)
Property_Value_Data$Region.5 <- as.numeric(Property_Value_Data$Region.5)
Property_Value_Data$Region.6 <- as.numeric(Property_Value_Data$Region.6)

Property_Value_Mean_by_Region <- data.frame(Region = 1:6, Mean_Property_Value = rep(0,n=6)) 

for(r in 1:6){
  x <- 0
  for(i in 1:13){
    x <- x + Property_Value_Data[i,r+1] * Property_Value_Distribution_Mean[i]
  }
  Property_Value_Mean_by_Region$Mean_Property_Value[r] <- x
}



Property_Count_Data_by_Region <- as.data.frame(t(Region_Data_Raw %>% 
                                                   filter(Field == "Housing Units"))) 

Property_Count_Data_by_Region <- rownames_to_column(Property_Count_Data_by_Region, "Region.Name") %>%
  filter(Region.Name != "Field") %>%
  mutate(Region = as.numeric(substring(Region.Name,nchar(Region.Name),nchar(Region.Name)))) %>%
  rename("Count" = "V1") %>%
  dplyr::select(!Region.Name)

Property_Count_Data_by_Region$Count <- as.numeric(Property_Count_Data_by_Region$Count)


Property_Data_by_Region <- Property_Value_Mean_by_Region %>% 
  left_join(Property_Count_Data_by_Region, by = "Region") %>%
  mutate(Total_Property_Value = Mean_Property_Value * Count) %>%
  dplyr::select(c("Region","Total_Property_Value"))

Property_Data_by_Region$Region <- as.factor(Property_Data_by_Region$Region)


Hazard_Data_Work <- Hazard_Data_Work %>% 
  mutate(Region_HazardEvent = paste0(Region,Hazard.Event..Grouped.)) %>%
  #Filter data entries with only positive Property.Damage
  filter(Property.Damage > 0) %>%
  #Left join Hazard_Data_Work with Economic_Data_Work
  left_join(Economic_Data_Work, by="Year") %>%
  left_join(Property_Data_by_Region, by="Region") %>%
  mutate(Property.Damage_Exposure = Property.Damage * Cumulative_Inflation / Total_Property_Value * 10^10) #to scale up the value to avoid error in MLE

# Hazard_Data_Work_Summary <- Hazard_Data_Work %>% 
#   group_by(Region_HazardEvent) %>%
#   summarise(
#     Count = n()
#     ,Mean_Property_Damage = mean(Property.Damage)
#   ) %>%
#   arrange(Mean_Property_Damage)





Hazard_Data_Cleaned <- Hazard_Data_Work %>% 
  dplyr::select(c("Region","Hazard.Event..Grouped.","Property.Damage_Exposure"))


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


# Exploratory Data Analysis by Region, Hazard Event (Grouped) & Cluster

Hazard_Data_EDA_Region <- Hazard_Data_H_Cluster %>%
  group_by(Region) %>%
  summarise(Count = n(),
            Total = sum(Property.Damage_Exposure)/10^10,
            Average = mean(Property.Damage_Exposure)/10^10,
            StandardDeviation = sd(Property.Damage_Exposure)/10^10)

Hazard_Data_EDA_HazardEvent <- Hazard_Data_H_Cluster %>%
  group_by(Hazard.Event..Grouped.) %>%
  summarise(Count = n(),
            Total = sum(Property.Damage_Exposure)/10^10,
            Average = mean(Property.Damage_Exposure)/10^10,
            StandardDeviation = sd(Property.Damage_Exposure))

Hazard_Data_EDA_Cluster <- Hazard_Data_H_Cluster %>%
  group_by(Cluster) %>%
  summarise(Count = n(),
            Total = sum(Property.Damage_Exposure)/10^10,
            Average = mean(Property.Damage_Exposure)/10^10,
            StandardDeviation = sd(Property.Damage_Exposure)/10^10)










# Fitting Gamma Distributions in R
# Cluster_1
Hazard_Data_H_Cluster_1 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 1) %>%
  arrange(Property.Damage_Exposure)

Hazard_Data_H_Cluster_1_fitdist <- fitdist(Hazard_Data_H_Cluster_1$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_1$Property.Damage_Exposure)/mean(Hazard_Data_H_Cluster_1$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Cluster_1$Property.Damage_Exposure)^2/var(Hazard_Data_H_Cluster_1$Property.Damage_Exposure)))
summary(Hazard_Data_H_Cluster_1_fitdist)
plot(Hazard_Data_H_Cluster_1_fitdist)

# Cluster_2
Hazard_Data_H_Cluster_2 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 2)

Hazard_Data_H_Cluster_2_fitdist <- fitdist(Hazard_Data_H_Cluster_2$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_2$Property.Damage_Exposure)/mean(Hazard_Data_H_Cluster_2$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Cluster_2$Property.Damage_Exposure)^2/var(Hazard_Data_H_Cluster_2$Property.Damage_Exposure)))
summary(Hazard_Data_H_Cluster_2_fitdist)
plot(Hazard_Data_H_Cluster_2_fitdist)

# Cluster_3
Hazard_Data_H_Cluster_3 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 3)

Hazard_Data_H_Cluster_3_fitdist <- fitdist(Hazard_Data_H_Cluster_3$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_3$Property.Damage_Exposure)/mean(Hazard_Data_H_Cluster_3$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Cluster_3$Property.Damage_Exposure)^2/var(Hazard_Data_H_Cluster_3$Property.Damage_Exposure)))
summary(Hazard_Data_H_Cluster_3_fitdist)
plot(Hazard_Data_H_Cluster_3_fitdist)

# Cluster_4
Hazard_Data_H_Cluster_4 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 4)

Hazard_Data_H_Cluster_4_fitdist <- fitdist(Hazard_Data_H_Cluster_4$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_4$Property.Damage_Exposure)/mean(Hazard_Data_H_Cluster_4$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Cluster_4$Property.Damage_Exposure)^2/var(Hazard_Data_H_Cluster_4$Property.Damage_Exposure)))
summary(Hazard_Data_H_Cluster_4_fitdist)
plot(Hazard_Data_H_Cluster_4_fitdist)

# Cluster_5
Hazard_Data_H_Cluster_5 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 5)

Hazard_Data_H_Cluster_5_fitdist <- fitdist(Hazard_Data_H_Cluster_5$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_5$Property.Damage_Exposure)/mean(Hazard_Data_H_Cluster_5$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Cluster_5$Property.Damage_Exposure)^2/var(Hazard_Data_H_Cluster_5$Property.Damage_Exposure)))
summary(Hazard_Data_H_Cluster_5_fitdist)
plot(Hazard_Data_H_Cluster_5_fitdist)


# Cluster_6
Hazard_Data_H_Cluster_6 <- Hazard_Data_H_Cluster %>%
  filter(Cluster == 6)

Hazard_Data_H_Cluster_6_fitdist <- fitdist(Hazard_Data_H_Cluster_6$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Cluster_6$Property.Damage_Exposure)/mean(Hazard_Data_H_Cluster_6$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Cluster_6$Property.Damage_Exposure)^2/var(Hazard_Data_H_Cluster_6$Property.Damage_Exposure)))
summary(Hazard_Data_H_Cluster_6_fitdist)
plot(Hazard_Data_H_Cluster_6_fitdist)





# Fitting Gamma Distributions in R
# Region_1
Hazard_Data_H_Region_1 <- Hazard_Data_H_Cluster %>%
  filter(Region == 1) %>%
  arrange(Property.Damage_Exposure)

Hazard_Data_H_Region_1_fitdist <- fitdist(Hazard_Data_H_Region_1$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Region_1$Property.Damage_Exposure)/mean(Hazard_Data_H_Region_1$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Region_1$Property.Damage_Exposure)^2/var(Hazard_Data_H_Region_1$Property.Damage_Exposure)))
summary(Hazard_Data_H_Region_1_fitdist)
plot(Hazard_Data_H_Region_1_fitdist)

# Region_2
Hazard_Data_H_Region_2 <- Hazard_Data_H_Cluster %>%
  filter(Region == 2)

Hazard_Data_H_Region_2_fitdist <- fitdist(Hazard_Data_H_Region_2$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Region_2$Property.Damage_Exposure)/mean(Hazard_Data_H_Region_2$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Region_2$Property.Damage_Exposure)^2/var(Hazard_Data_H_Region_2$Property.Damage_Exposure)))
summary(Hazard_Data_H_Region_2_fitdist)
plot(Hazard_Data_H_Region_2_fitdist)

# Region_3
Hazard_Data_H_Region_3 <- Hazard_Data_H_Cluster %>%
  filter(Region == 3)

Hazard_Data_H_Region_3_fitdist <- fitdist(Hazard_Data_H_Region_3$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Region_3$Property.Damage_Exposure)/mean(Hazard_Data_H_Region_3$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Region_3$Property.Damage_Exposure)^2/var(Hazard_Data_H_Region_3$Property.Damage_Exposure)))
summary(Hazard_Data_H_Region_3_fitdist)
plot(Hazard_Data_H_Region_3_fitdist)

# Region_4
Hazard_Data_H_Region_4 <- Hazard_Data_H_Cluster %>%
  filter(Region == 4)

Hazard_Data_H_Region_4_fitdist <- fitdist(Hazard_Data_H_Region_4$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Region_4$Property.Damage_Exposure)/mean(Hazard_Data_H_Region_4$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Region_4$Property.Damage_Exposure)^2/var(Hazard_Data_H_Region_4$Property.Damage_Exposure)))
summary(Hazard_Data_H_Region_4_fitdist)
plot(Hazard_Data_H_Region_4_fitdist)

# Region_5
Hazard_Data_H_Region_5 <- Hazard_Data_H_Cluster %>%
  filter(Region == 5)

Hazard_Data_H_Region_5_fitdist <- fitdist(Hazard_Data_H_Region_5$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Region_5$Property.Damage_Exposure)/mean(Hazard_Data_H_Region_5$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Region_5$Property.Damage_Exposure)^2/var(Hazard_Data_H_Region_5$Property.Damage_Exposure)))
summary(Hazard_Data_H_Region_5_fitdist)
plot(Hazard_Data_H_Region_5_fitdist)


# Region_6
Hazard_Data_H_Region_6 <- Hazard_Data_H_Cluster %>%
  filter(Region == 6)

Hazard_Data_H_Region_6_fitdist <- fitdist(Hazard_Data_H_Region_6$Property.Damage_Exposure, 
                                           distr = "gamma",
                                           method = "mle",
                                           start = list(scale = var(Hazard_Data_H_Region_6$Property.Damage_Exposure)/mean(Hazard_Data_H_Region_6$Property.Damage_Exposure), 
                                                        shape = mean(Hazard_Data_H_Region_6$Property.Damage_Exposure)^2/var(Hazard_Data_H_Region_6$Property.Damage_Exposure)))
summary(Hazard_Data_H_Region_6_fitdist)
plot(Hazard_Data_H_Region_6_fitdist)












# 
# #Silhouette Width Selection of Optimal Number of Clusters
# Silhouette <- c()
# Silhouette <- c(Silhouette, NA)
# 
# for(i in 2:10){
#   Pam_clusters <- pam(as.matrix(Gower_df),
#                      diss = TRUE,
#                      k = i)
#   Silhouette <- c(Silhouette, Pam_clusters$Silinfo$avg.width)
# }
# 
# plot(2:10, Silhouette,
#      xlab = "Clusters",
#      ylab = "Silhouette Width")
# lines(2:10, Silhouette)

# k <- 10
# set.seed(6)
# KMeans_Model <- kmeans(Hazard_Data_Cleaned, centers = k)
