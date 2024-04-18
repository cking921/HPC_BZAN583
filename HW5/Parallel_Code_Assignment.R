start <- Sys.time()

# Function to read and process a single parquet file
process_parquet <- function(parquet_file) {
  # Read parquet file
  data <- arrow::read_parquet(parquet_file)
  
  # Convert datetime column
  data$datetime <- as.POSIXct(paste(data[,1], sprintf("%04d", data[,2]), sep = " "), format = "%Y-%m-%d %H%M", tz = "UTC")
  colnames(data)[8] <- "Temp"
  
  # Arrange by datetime and take the last 10%
  data <- data[order(data$datetime), ]
  data <- tail(data, round(nrow(data) * 0.01))
  
  # Create tsibble
  df <- tsibble::tsibble(data[, c(20, 8)])
  df$Temp[is.na(df$Temp)] <- mean(df$Temp, na.rm = TRUE)
  
  # Split into train and test sets
  train <- dplyr::slice_head(.data = df, n = nrow(df) - 24) 
  test <- dplyr::slice_tail(.data = df, n = 24)
  
  # Fit models
  fit <- fabletools::model(.data = train, ets = fable::ETS(Temp), arima = fable::ARIMA(Temp))
  
  # Forecast
  forecast_values <- fabletools::forecast(fit, h = 24, times = 0)
  
  # Calculate accuracy
  accuracy <- fabletools::accuracy(forecast_values, test)
  
  # Return accuracy
  return(accuracy)
}


setwd("/projects/bckj/Team4/Data/partitioned_data")

# Pulling list of parquets and setting up file for reading
parquet_files <- list.files()
parquet_files <- paste0(parquet_files,"/part-0.parquet")

# Parallel processing using mclapply
nc = as.numeric(commandArgs(TRUE)[2])
accuracy_results <- parallel::mclapply(parquet_files[1:16], process_parquet, mc.cores = nc)

# Combine accuracy results
combined_accuracy <- do.call(rbind, accuracy_results)
print(combined_accuracy)

print(Sys.time() - start)