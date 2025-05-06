# Example Scenarios for SIR Epidemiological Model

# Load the SIR model functions
source("sir_model.R")

# Load required packages
if (!require("ggplot2")) install.packages("ggplot2")
if (!require("reshape2")) install.packages("reshape2")
if (!require("gridExtra")) install.packages("gridExtra")

library(ggplot2)
library(reshape2)
library(gridExtra)

# ===== Scenario 1: Basic SIR Model =====
cat("\n===== Scenario 1: Basic SIR Model =====\n")
basic_sir <- sir_model()
basic_plot <- plot_sir(basic_sir)
print(basic_plot)

# Calculate key metrics
max_infectious <- max(basic_sir$infectious)
time_to_peak <- basic_sir$time[which.max(basic_sir$infectious)]
final_recovered <- tail(basic_sir$recovered, 1)

cat("Basic SIR Model (β = 0.3, γ = 0.1):\n")
cat("Peak infectious cases:", round(max_infectious), "\n")
cat("Time to peak (days):", time_to_peak, "\n")
cat("Final recovered (total infected):", round(final_recovered), "\n\n")

# ===== Scenario 2: Different R0 Values =====
cat("\n===== Scenario 2: Different R0 Values =====\n")

# Low R0 (R0 = 1.5)
low_r0 <- sir_model(beta = 0.15, gamma = 0.1)
low_r0_plot <- plot_sir(low_r0) + ggtitle("Low Transmission (R0 = 1.5)")

# Medium R0 (R0 = 3.0) - same as basic model
medium_r0 <- sir_model(beta = 0.3, gamma = 0.1)
medium_r0_plot <- plot_sir(medium_r0) + ggtitle("Medium Transmission (R0 = 3.0)")

# High R0 (R0 = 5.0)
high_r0 <- sir_model(beta = 0.5, gamma = 0.1)
high_r0_plot <- plot_sir(high_r0) + ggtitle("High Transmission (R0 = 5.0)")

# Arrange plots
grid.arrange(low_r0_plot, medium_r0_plot, high_r0_plot, ncol = 3)

# Print metrics for each R0 scenario
cat("Comparison of different R0 values:\n")
cat("Low R0 (1.5): Peak infectious =", round(max(low_r0$infectious)), 
    "at day", low_r0$time[which.max(low_r0$infectious)], "\n")
cat("Medium R0 (3.0): Peak infectious =", round(max(medium_r0$infectious)), 
    "at day", medium_r0$time[which.max(medium_r0$infectious)], "\n")
cat("High R0 (5.0): Peak infectious =", round(max(high_r0$infectious)), 
    "at day", high_r0$time[which.max(high_r0$infectious)], "\n\n")

# ===== Scenario 3: Effect of Initial Conditions =====
cat("\n===== Scenario 3: Effect of Initial Conditions =====\n")

# Few initial cases
few_initial <- sir_model(I0 = 1)
few_initial_plot <- plot_sir(few_initial) + ggtitle("1 Initial Case")

# More initial cases
more_initial <- sir_model(I0 = 10)
more_initial_plot <- plot_sir(more_initial) + ggtitle("10 Initial Cases")

# Many initial cases
many_initial <- sir_model(I0 = 50)
many_initial_plot <- plot_sir(many_initial) + ggtitle("50 Initial Cases")

# Arrange plots
grid.arrange(few_initial_plot, more_initial_plot, many_initial_plot, ncol = 3)

# ===== Scenario 4: Intervention Timing =====
cat("\n===== Scenario 4: Intervention Timing =====\n")

# Early intervention (day 20)
early_intervention <- simulate_intervention(intervention_time = 20)
early_plot <- plot_sir(early_intervention) + 
  ggtitle("Early Intervention (Day 20)") +
  geom_vline(xintercept = 20, linetype = "dashed")

# Medium intervention (day 40)
medium_intervention <- simulate_intervention(intervention_time = 40)
medium_plot <- plot_sir(medium_intervention) + 
  ggtitle("Medium Intervention (Day 40)") +
  geom_vline(xintercept = 40, linetype = "dashed")

# Late intervention (day 60)
late_intervention <- simulate_intervention(intervention_time = 60)
late_plot <- plot_sir(late_intervention) + 
  ggtitle("Late Intervention (Day 60)") +
  geom_vline(xintercept = 60, linetype = "dashed")

# Arrange plots
grid.arrange(early_plot, medium_plot, late_plot, ncol = 3)

# Print metrics for each intervention timing
cat("Comparison of intervention timing:\n")
cat("Early intervention (Day 20): Peak infectious =", 
    round(max(early_intervention$infectious)), "\n")
cat("Medium intervention (Day 40): Peak infectious =", 
    round(max(medium_intervention$infectious)), "\n")
cat("Late intervention (Day 60): Peak infectious =", 
    round(max(late_intervention$infectious)), "\n\n")

# ===== Scenario 5: Intervention Strength =====
cat("\n===== Scenario 5: Intervention Strength =====\n")

# Weak intervention (25% reduction)
weak_intervention <- simulate_intervention(
  beta_before = 0.3, 
  beta_after = 0.225,  # 25% reduction
  intervention_time = 40
)
weak_plot <- plot_sir(weak_intervention) + 
  ggtitle("Weak Intervention (25% reduction)") +
  geom_vline(xintercept = 40, linetype = "dashed")

# Moderate intervention (50% reduction)
moderate_intervention <- simulate_intervention(
  beta_before = 0.3, 
  beta_after = 0.15,   # 50% reduction
  intervention_time = 40
)
moderate_plot <- plot_sir(moderate_intervention) + 
  ggtitle("Moderate Intervention (50% reduction)") +
  geom_vline(xintercept = 40, linetype = "dashed")

# Strong intervention (75% reduction)
strong_intervention <- simulate_intervention(
  beta_before = 0.3, 
  beta_after = 0.075,  # 75% reduction
  intervention_time = 40
)
strong_plot <- plot_sir(strong_intervention) + 
  ggtitle("Strong Intervention (75% reduction)") +
  geom_vline(xintercept = 40, linetype = "dashed")

# Arrange plots
grid.arrange(weak_plot, moderate_plot, strong_plot, ncol = 3)

# Print metrics for each intervention strength
cat("Comparison of intervention strength:\n")
cat("Weak intervention (25% reduction): Peak infectious =", 
    round(max(weak_intervention$infectious)), "\n")
cat("Moderate intervention (50% reduction): Peak infectious =", 
    round(max(moderate_intervention$infectious)), "\n")
cat("Strong intervention (75% reduction): Peak infectious =", 
    round(max(strong_intervention$infectious)), "\n")