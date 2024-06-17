library(earth)
library(caret)
library(dplyr)
library(tidyr)
library(zoo)
library(data.table)
library(stats)
library(corrplot)
# Set seed for reproducibility
set.seed(42)


plot_kde_with_means <- function(data, var1, var2, var1_label, var2_label) {
  # Capture the variable expressions
  var1_expr <- enquo(var1)
  var2_expr <- enquo(var2)
  
  # Calculate the means
  mean_var1 <- mean(data[[quo_name(var1_expr)]], na.rm = TRUE)
  mean_var2 <- mean(data[[quo_name(var2_expr)]], na.rm = TRUE)
  quantile25_var1 <- quantile(data[[quo_name(var1_expr)]], .25, na.rm = TRUE)
  quantile25_var2 <- quantile(data[[quo_name(var2_expr)]], .25, na.rm = TRUE)
  quantile75_var1 <- quantile(data[[quo_name(var1_expr)]], .75, na.rm = TRUE)
  quantile75_var2 <- quantile(data[[quo_name(var2_expr)]], .75, na.rm = TRUE)
  fill_colors <- setNames(c("maroon4", "deepskyblue4"), c(var1_label, var2_label))
  
  # Create the plot
  ggplot(data) +
    # Density plot for the first variable with some transparency
    geom_density(aes(x = !!var1_expr, fill = var1_label), alpha = 0.9, adjust = 1) +
    # Density plot for the second variable with some transparency
    geom_density(aes(x = !!var2_expr, fill = var2_label), alpha = 0.5, adjust = 1) +
    
    # Vertical line for the mean of the first variable
    geom_vline(aes(xintercept = mean_var1), linetype = "dashed", color = "maroon4") +
    # Vertical line for the mean of the second variable
    geom_vline(aes(xintercept = mean_var2), linetype = "dashed", color = "deepskyblue4") +
    
    # Vertical line for the mean of the first variable
    geom_vline(aes(xintercept = quantile25_var1), linetype = "dashed", color = "maroon4") +
    # Vertical line for the mean of the second variable
    geom_vline(aes(xintercept = quantile25_var2), linetype = "dashed", color = "deepskyblue4") +
    
    # Vertical line for the mean of the first variable
    geom_vline(aes(xintercept = quantile75_var1), linetype = "dashed", color = "maroon4") +
    # Vertical line for the mean of the second variable
    geom_vline(aes(xintercept = quantile75_var2), linetype = "dashed", color = "deepskyblue4") +
    
    scale_fill_manual(values = fill_colors) +    # Add labels and title if needed
    labs(fill = "Variable", title = paste("KDE of" , var1_label) ) +
    
    # Custom legend for the vertical lines
    guides(color = guide_legend(title = "Mean")) +
    
    # Make the background theme clean
    theme_minimal()
}



plot_stand_age_range <- function(data) {
  
summary_functions <- function(x) {
  list(
    mean = mean(x),
    q25 = quantile(x, 0.25),
    q75 = quantile(x, 0.75)
  )
}
result <- data[, sapply(.SD, summary_functions), 
                 by = stand_age_interval_min, 
                 .SDcols = c("VEGC", "vegc_pred")]

# Rename the columns to include the metrics
setnames(result, names(result), 
         c("stand_age_interval_min", 
           "VEGC_Mean", "VEGC_Q25", "VEGC_Q75", 
           "vegc_pred_Mean", "vegc_pred_Q25", "vegc_pred_Q75"))

# Reshape the data.table to long format
custom_colors <- c("Simulated" = "maroon4", "Emulated" = "deepskyblue4")

ggplot() +
  # VEGC shaded area
  geom_ribbon(data = result, aes(x = stand_age_interval_min, ymin = VEGC_Q25, ymax = VEGC_Q75, fill = "Simulated"), alpha = 0.3) +
  # VEGC mean line
  geom_line(data = result, aes(x = stand_age_interval_min, y = VEGC_Mean, color = "Simulated")) +
  # vegc_pred shaded area
  geom_ribbon(data = result, aes(x = stand_age_interval_min, ymin = vegc_pred_Q25, ymax = vegc_pred_Q75, fill = "Emulated"), alpha = 0.3) +
  # vegc_pred mean line
  geom_line(data = result, aes(x = stand_age_interval_min, y = vegc_pred_Mean, color = "Emulated")) +
  # Labels and themes
  scale_fill_manual(values = custom_colors) +
  scale_color_manual(values = custom_colors) +
  
  labs(title = "VEGC and VEGC Predictions by Stand Age Interval",
       x = "Stand Age Interval",
       y = "Vegetation Carbon (gC/m2)",
       fill = "Variable",
       color = "Variable") +
  theme_minimal()
}


generate_stand_age_predictions <- function(group, model, grid, group_label) {
  # 1. Create the stand_ages data.table
  stand_ages <- data.table(ordinal_stand_age = 0:22)
  stand_ages[, dummy_key := 1]
  
  # 2. Filter the input data for the specified years (group)
  group_input <- input_data[year %in% group]
  
  # 3. Merge the filtered input data with the grid data
  group_input <- group_input[grid, on = .(lon, lat)]
  
  # 4. Add a dummy key to the filtered input data
  group_input[, dummy_key := 1]
  
  # 5. Perform the cross join with the stand_ages data.table and remove the dummy key
  group_input <- group_input[stand_ages, on = "dummy_key", allow.cartesian = TRUE][, dummy_key := NULL]
  
  # 6. Predict using the specified model
  group_input$VEGC_pred <- predict(model, group_input[, ..clm_features])
  
  # 7. Print the summary of the predictions
  print(summary(group_input$VEGC_pred))
  
  # 8. Replace negative predictions with 0
  group_input$VEGC_pred[group_input$VEGC_pred < 0] <- 0
  group_input$VEGC_pred[group_input$VEGC_pred >30000 ] <- 30000
  
  # 9. Calculate the mean predictions by ordinal_stand_age
  group_sa <- group_input[, .(mean_VEGC_pred = mean(VEGC_pred)), by = .(ordinal_stand_age)]
  
  # 10. Add the label column with the group label
  group_sa[, label := group_label]
  
  # 11. Return the result
  return(group_sa)
}


plot_clm_var_cor <- function(data,cor_features = c("nirr_avg", "nirr_min", "nirr_max", "prec_avg",
                                                    "prec_min", "prec_max", "tair_avg", "tair_min", "tair_max",
                                                    "trange_avg", "trange_min", "trange_max", "vpr_avg",
                                                    "vpr_min", "vpr_max", "wind_avg", "wind_min",
                                                    "wind_max" ,"s1" ,"s2" , "s3" ,  
                                                    "elev" ,  "co2" , "AOT40_rcp45_avg" ,"AOT40_rcp45_min",
                                                    "AOT40_rcp45_max", "Ndep_rcp45"     ,
                                                    "Nfer_crop"    ,   "Nfer_pas" ,
                                                    "ordinal_stand_age","VEGC", "SOILORGC","NPP", "VSM","AVAILN")
){

tt <- cor(data[AVAILN<1200,..cor_features])
corrplot(tt, method = "color", type = "upper", order = "hclust",
         tl.col = "black", tl.srt = 45, # Text label color and rotation
         addCoef.col = "black"
         ,number.digits = 1
         ,number.cex = .6) # Add correlation coefficients to the plot
}

