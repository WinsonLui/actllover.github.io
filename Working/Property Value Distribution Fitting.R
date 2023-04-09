#Reference: http://freerangestats.info/blog/2019/08/25/fitting-bins
#Environment Setting:

library(pacman)

p_load(tidyverse
       ,multidplyr
       ,fitdistrplus
       ,knitr
       ,readxl
       ,kableExtra
       ,clipr)

Property_Value_Distribution_bin_RAW <- read.csv("C:/Users/Winson/Documents/UNSW/ACTL4001/Case Study/Data/Cleaned/Property Value Distribution.csv")


Property_Value_Distribution_bin_WORK <- Property_Value_Distribution_bin_RAW %>%
  mutate(left = case_when(
    Field == "Property Value distribution <Ꝕ50K" ~ 0,
    Field == "Property Value distribution Ꝕ50K-Ꝕ99K" ~ 50000,
    Field == "Property Value distribution Ꝕ100K-Ꝕ149K" ~ 100000,
    Field == "Property Value distribution Ꝕ150K-Ꝕ199K" ~ 150000,
    Field == "Property Value distribution Ꝕ200K-Ꝕ249K" ~ 200000,
    Field == "Property Value distribution Ꝕ250K-Ꝕ299K" ~ 250000,
    Field == "Property Value distribution Ꝕ300K-Ꝕ399K" ~ 300000,
    Field == "Property Value distribution Ꝕ400K-Ꝕ499K" ~ 400000,
    Field == "Property Value distribution Ꝕ500K-Ꝕ749K" ~ 500000,
    Field == "Property Value distribution Ꝕ750K-Ꝕ999K" ~ 750000,
    Field == "Property Value distribution Ꝕ1M-Ꝕ1.499K" ~ 1000000,
    Field == "Property Value distribution Ꝕ1.5M-Ꝕ1.99M" ~ 1500000,
    Field == "Property Value distribution >=Ꝕ2M" ~ 2000000
  )) %>%
  mutate(right = case_when(
    Field == "Property Value distribution <Ꝕ50K" ~ 50000,
    Field == "Property Value distribution Ꝕ50K-Ꝕ99K" ~ 100000,
    Field == "Property Value distribution Ꝕ100K-Ꝕ149K" ~ 150000,
    Field == "Property Value distribution Ꝕ150K-Ꝕ199K" ~ 200000,
    Field == "Property Value distribution Ꝕ200K-Ꝕ249K" ~ 250000,
    Field == "Property Value distribution Ꝕ250K-Ꝕ299K" ~ 300000,
    Field == "Property Value distribution Ꝕ300K-Ꝕ399K" ~ 400000,
    Field == "Property Value distribution Ꝕ400K-Ꝕ499K" ~ 500000,
    Field == "Property Value distribution Ꝕ500K-Ꝕ749K" ~ 750000,
    Field == "Property Value distribution Ꝕ750K-Ꝕ999K" ~ 1000000,
    Field == "Property Value distribution Ꝕ1M-Ꝕ1.499K" ~ 1500000,
    Field == "Property Value distribution Ꝕ1.5M-Ꝕ1.99M" ~ 2000000,
    Field == "Property Value distribution >=Ꝕ2M" ~ NA
  )) 


#Filter for Region 1
Property_Value_Distribution_bin_Region_1 <- Property_Value_Distribution_bin_WORK %>%
  filter(Region == 1) %>%
  dplyr::select(Value,left,right)

Property_Value_Distribution_estimate_Region_1 <- Property_Value_Distribution_bin_WORK %>%
  filter(Region == 1) %>%
  #Assume uniform distribution to estimate the mean and variance of the distribution
  mutate(estimate_mean = case_when(
    Field == "Property Value distribution >=Ꝕ2M" ~ 2500000,
    TRUE ~ (left+right)/2
  )) %>%
  mutate(estimate_var = case_when(
    Field == "Property Value distribution >=Ꝕ2M" ~ (2500000-2000000)^2/12,
    TRUE ~ (right-left)^2/12
  )) %>%
  mutate(estimate_weighted_mean = estimate_mean*Value) %>%
  mutate(estimate_weighted_var = estimate_var*Value^2)

#Estimate the mean and variance of the distribution
Property_Value_mean_Region_1 <- sum(Property_Value_Distribution_estimate_Region_1$estimate_weighted_mean)
Property_Value_var_Region_1 <- sum(Property_Value_Distribution_estimate_Region_1$estimate_weighted_var)


##Fit Gamma Distribution
Gamma_Distribution_Region_1 <- fitdistcens(censdata = Property_Value_Distribution_bin_Region_1
                                           ,distr = "gamma"
                                           ,start = list(scale = Property_Value_var_Region_1/Property_Value_mean_Region_1,
                                                         shape = Property_Value_mean_Region_1^2/Property_Value_var_Region_1))

summary(Gamma_Distribution_Region_1)

##Fit Exponential Distribution
Exp_Distribution_Region_1 <- fitdistcens(censdata = Property_Value_Distribution_bin_Region_1
                                           ,distr = "exp")

summary(Exp_Distribution_Region_1)


##Fit Normal Distribution
Norm_Distribution_Region_1 <- fitdistcens(censdata = Property_Value_Distribution_bin_Region_1
                                           ,distr = "norm")
summary(Norm_Distribution_Region_1)


##Fit Log-normal Distribution
Lnorm_Distribution_Region_1 <- fitdistcens(censdata = Property_Value_Distribution_bin_Region_1
                                          ,distr = "lnorm")
summary(Lnorm_Distribution_Region_1)

ggplot(Property_Value_Distribution_bin_Region_1) +
  geom_density(aes(x = Value)) +
  stat_function(fun = dlnorm, args = Lnorm_Distribution_Region_1$estimate, colour = "blue")





