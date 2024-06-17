library(dplyr)
library(purrr)
library(ggplot2)

min_count <- 50
cutoff <- .15
compute_acf <- function(df) {
  Acf <- acf(df$VEGC, plot = FALSE) # change 'value' to your actual column name with time series data
  # Turn the acf object into a data frame for future plotting or analysis
  data_frame(ACF = Acf$acf, lag = seq_along(Acf$acf) - 1)
}

return_acf_data <- function(df, min_count = 50, cutoff = .15) {
  grouped_data <- df %>%
  select(VEGC,lat, lon, ordinal_stand_age) %>%
  group_by(lat, lon, ordinal_stand_age) %>%
  filter(n() >= min_count) %>% # Filter out groups with fewer than min_count observations
  nest()

grouped_data <- grouped_data %>%
  mutate(acf_data = map(data, compute_acf))

grouped_data <- grouped_data %>%
  unnest(cols = c(acf_data)) %>%
  ungroup()

grouped_data <- grouped_data %>%
  select(-data)
grouped_data <- grouped_data %>%
  mutate(ACF = array(data = ACF, dim = c(length(ACF)))) %>%
  unnest(c(ACF))

grouped_data <- data.table(grouped_data)

}

summary(grouped_data)

grouped_data <- return_acf_data(boreal_model_data)
summary(grouped_data)

grouped_data %>%
  # filter(abs(ACF)>.3) %>%
  group_by(ordinal_stand_age) %>%
  mean(ACF)

grouped_data <- grouped_data %>%
  filter(abs(ACF)>cutoff )


grouped_data[, max_lag := max(lag), by = .(lat,lon, ordinal_stand_age)]


tt <- grouped_data %>%
  group_by(lat, lon, ordinal_stand_age) %>%
   max(ACF)


grouped_data$ACF <- unlist(grouped_data$ACF)
lapply(grouped_data$ACF, `[[`, "ACF")
purrr::flatten(grouped_data$ACF)


acf_plots <- grouped_data %>%
  mutate(acf_plot = map(acf_data, ~ggplot(data = .x, aes(x = lag, y = ACF)) + geom_bar(stat = "identity")))
