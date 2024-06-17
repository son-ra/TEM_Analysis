summary(earth.vegc_ratio, digits = 2, style = "pmax")

# Install necessary packages if not already installed
# You can uncomment the next lines to install the required packages
# install.packages("ggplot2")
install.packages("sf")
install.packages("rnaturalearth")
install.packages("rnaturalearthdata")

# Load the necessary libraries
library(ggplot2)
library(sf)
library(rnaturalearth)

# Get the global coastline shapefile using rnaturalearth
world_coastline <- ne_coastline(returnclass = "sf")

# Assuming you have a dataframe 'data' with 'lat', 'lon', and 'value' columns
# data <- data.frame(lon = ..., lat = ..., value = ...)

# Sample data
set.seed(24) # For reproducibility
data <- data.frame(
  lon = runif(100, min=-180, max=180),
  lat = runif(100, min=-90, max=90),
  value = rnorm(100)
)

# Convert the data to an sf object
data_sf <- st_as_sf(data, coords = c("lon", "lat"), crs = st_crs(world_coastline))

# Base plot with ggplot2
gg <- ggplot() +
  geom_sf(data = world_coastline, fill = "transparent", color = "black") +
  geom_sf(data = data_sf, aes(size = value, color = value)) + 
  scale_color_gradient(low = "blue", high = "red") +  # Change colors as you like
  theme_minimal() +
  labs(title = "Value by Latitude and Longitude",
       color = "Value") +
  theme(legend.position = "bottom")

# If you're using R in an interactive environment, you can print the plot
print(gg)


###plot residuals by year

test_data <- model_data[-trainIndex,]
test_data[,pred:= y_pred]
test_data[,resid:= VEGC-y_pred]

plot(test_data$year, test_data$resid, 
     main = "Simple Scatterplot", # Title of the plot
     xlab = "X-axis Label",       # Label for the x-axis
     ylab = "Y-axis Label",       # Label for the y-axis
     col = "blue",                # Color of points
    
     pch = 16
     # ,                    # Type of points (16 is solid circle)
     # xlim = c(0, 6),              # X-axis limits
     # ylim = c(0, 7)               # Y-axis limits
)