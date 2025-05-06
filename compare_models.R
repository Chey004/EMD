# Comparison of SIR and SEIR Epidemiological Models

# Load required packages
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("reshape2")) install.packages("reshape2")
if (!require("gridExtra")) install.packages("gridExtra")

library(ggplot2)
library(reshape2)
library(gridExtra)

# Load model functions
source("sir_model.R")
source("seir_model.R")

# ===== Basic Comparison of SIR and SEIR Models =====
cat("\n===== Basic Comparison of SIR and SEIR Models =====\n")

# Run models with default parameters
sir_results <- sir_model()
seir_results <- seir_model()

# Create plots
sir_plot <- plot_sir(sir_results) + ggtitle("SIR Model")
seir_plot <- plot_seir(seir_results) + ggtitle("SEIR Model")

# Display side by side
grid.arrange(sir_plot, seir_plot, ncol = 2)

# Print key metrics
cat("SIR Model:\n")
cat("Peak infectious cases:", round(max(sir_results$infectious)), 
    "at day", sir_results$time[which.max(sir_results$infectious)], "\n")
cat("Final recovered (total infected):", round(tail(sir_results$recovered, 1)), "\n\n")

cat("SEIR Model:\n")
cat("Peak infectious cases:", round(max(seir_results$infectious)), 
    "at day", seir_results$time[which.max(seir_results$infectious)], "\n")
cat("Final recovered (total infected):", round(tail(seir_results$recovered, 1)), "\n\n")

# ===== Effect of Incubation Period (1/sigma) =====
cat("\n===== Effect of Incubation Period (1/sigma) =====\n")

# Short incubation period (2 days)
short_incubation <- seir_model(sigma = 0.5)  # 1/0.5 = 2 days
short_plot <- plot_seir(short_incubation) + 
  ggtitle("Short Incubation Period (2 days)")

# Medium incubation period (5 days)
medium_incubation <- seir_model(sigma = 0.2)  # 1/0.2 = 5 days
medium_plot <- plot_seir(medium_incubation) + 
  ggtitle("Medium Incubation Period (5 days)")

# Long incubation period (10 days)
long_incubation <- seir_model(sigma = 0.1)  # 1/0.1 = 10 days
long_plot <- plot_seir(long_incubation) + 
  ggtitle("Long Incubation Period (10 days)")

# Display side by side
grid.arrange(short_plot, medium_plot, long_plot, ncol = 3)

# Print key metrics
cat("Effect of incubation period on epidemic timing:\n")
cat("Short incubation (2 days): Peak at day", 
    short_incubation$time[which.max(short_incubation$infectious)], "\n")
cat("Medium incubation (5 days): Peak at day", 
    medium_incubation$time[which.max(medium_incubation$infectious)], "\n")
cat("Long incubation (10 days): Peak at day", 
    long_incubation$time[which.max(long_incubation$infectious)], "\n\n")

# ===== Intervention Comparison Between Models =====
cat("\n===== Intervention Comparison Between Models =====\n")

# SIR with intervention
sir_intervention <- simulate_intervention(
  beta_before = 0.3,
  beta_after = 0.15,
  intervention_time = 40
)

# SEIR with intervention
seir_intervention <- simulate_seir_intervention(
  beta_before = 0.3,
  beta_after = 0.15,
  intervention_time = 40
)

# Create plots
sir_int_plot <- plot_sir(sir_intervention) + 
  ggtitle("SIR Model with Intervention") +
  geom_vline(xintercept = 40, linetype = "dashed")

seir_int_plot <- plot_seir(seir_intervention) + 
  ggtitle("SEIR Model with Intervention") +
  geom_vline(xintercept = 40, linetype = "dashed")

# Display side by side
grid.arrange(sir_int_plot, seir_int_plot, ncol = 2)

# Print reduction in peak cases
cat("Intervention effectiveness:\n")

# SIR model comparison
sir_no_int <- sir_model()
sir_peak_no_int <- max(sir_no_int$infectious)
sir_peak_with_int <- max(sir_intervention$infectious)
sir_reduction <- (sir_peak_no_int - sir_peak_with_int) / sir_peak_no_int * 100

# SEIR model comparison
seir_no_int <- seir_model()
seir_peak_no_int <- max(seir_no_int$infectious)
seir_peak_with_int <- max(seir_intervention$infectious)
seir_reduction <- (seir_peak_no_int - seir_peak_with_int) / seir_peak_no_int * 100

cat("SIR model: Peak reduction =", round(sir_reduction), "% with intervention\n")
cat("SEIR model: Peak reduction =", round(seir_reduction), "% with intervention\n")

# ===== Creating a Combined Plot of All Compartments =====
cat("\n===== Creating a Combined Plot of All Compartments =====\n")

# Function to create a stacked area plot for SEIR model
plot_seir_stacked <- function(seir_data) {
  # Reshape data for plotting
  plot_data <- melt(seir_data, id.vars = "time", 
                    variable.name = "compartment", 
                    value.name = "count")
  
  # Set factor levels to ensure correct stacking order
  plot_data$compartment <- factor(plot_data$compartment, 
                                 levels = c("recovered", "infectious", "exposed", "susceptible"))
  
  # Create stacked area plot
  p <- ggplot(plot_data, aes(x = time, y = count, fill = compartment)) +
    geom_area(alpha = 0.8) +
    scale_fill_manual(values = c("susceptible" = "blue", 
                               "exposed" = "orange",
                               "infectious" = "red", 
                               "recovered" = "green"),
                    labels = c("Susceptible", "Exposed", "Infectious", "Recovered")) +
    labs(title = "SEIR Model - Population Compartments Over Time",
         x = "Time (days)",
         y = "Number of individuals",
         fill = "Compartment") +
    theme_minimal()
  
  return(p)
}

# Create stacked area plot
seir_stacked <- plot_seir_stacked(seir_results)
print(seir_stacked)

# ===== Calculating R0 and Epidemic Threshold =====
cat("\n===== Calculating R0 and Epidemic Threshold =====\n")

# Function to calculate R0 for SIR model
calculate_r0_sir <- function(beta, gamma) {
  return(beta / gamma)
}

# Function to calculate R0 for SEIR model
calculate_r0_seir <- function(beta, sigma, gamma) {
  return(beta / gamma * (sigma / (sigma + gamma)))
}

# Calculate R0 for different parameter sets
beta_values <- seq(0.1, 0.5, by = 0.1)
gamma <- 0.1
sigma <- 0.2

cat("R0 values for different transmission rates (beta):\n")
cat("beta\tSIR R0\tSEIR R0\n")
for (beta in beta_values) {
  sir_r0 <- calculate_r0_sir(beta, gamma)
  seir_r0 <- calculate_r0_seir(beta, sigma, gamma)
  cat(sprintf("%.1f\t%.2f\t%.2f\n", beta, sir_r0, seir_r0))
}

cat("\nEpidemic threshold: R0 > 1 is required for an epidemic to occur.\n")