# SIR Epidemiological Model Implementation

# 1. Define parameters
sir_model <- function(N = 1000, I0 = 1, R0 = 0, beta = 0.3, gamma = 0.1, timesteps = 160) {
  # Initial susceptible population
  S0 <- N - I0 - R0
  
  # 2. Initialize vectors
  S <- numeric(timesteps)
  I <- numeric(timesteps)
  R <- numeric(timesteps)
  S[1] <- S0
  I[1] <- I0
  R[1] <- R0
  
  # 3. Simulate dynamics
  for (t in 1:(timesteps-1)) {
    new_infections <- beta * S[t] * I[t] / N
    new_recoveries <- gamma * I[t]
    
    S[t+1] <- S[t] - new_infections
    I[t+1] <- I[t] + new_infections - new_recoveries
    R[t+1] <- R[t] + new_recoveries
  }
  
  # Return results as a data frame
  result <- data.frame(
    time = 1:timesteps,
    susceptible = S,
    infectious = I,
    recovered = R
  )
  
  return(result)
}

# Function to plot SIR model results
plot_sir <- function(sir_data) {
  # Check if required packages are installed
  if (!require("ggplot2")) {
    install.packages("ggplot2")
    library(ggplot2)
  }
  
  # Reshape data for plotting
  if (!require("reshape2")) {
    install.packages("reshape2")
    library(reshape2)
  }
  
  plot_data <- melt(sir_data, id.vars = "time", 
                    variable.name = "compartment", 
                    value.name = "count")
  
  # Create plot
  p <- ggplot(plot_data, aes(x = time, y = count, color = compartment)) +
    geom_line(size = 1.2) +
    scale_color_manual(values = c("susceptible" = "blue", 
                                 "infectious" = "red", 
                                 "recovered" = "green"),
                      labels = c("Susceptible", "Infectious", "Recovered")) +
    labs(title = "SIR Epidemiological Model",
         x = "Time (days)",
         y = "Number of individuals",
         color = "Compartment") +
    theme_minimal() +
    theme(legend.position = "right")
  
  return(p)
}

# Function to simulate intervention effects
simulate_intervention <- function(N = 1000, I0 = 1, R0 = 0, 
                                beta_before = 0.3, beta_after = 0.15, 
                                intervention_time = 40,
                                gamma = 0.1, timesteps = 160) {
  # Initial susceptible population
  S0 <- N - I0 - R0
  
  # Initialize vectors
  S <- numeric(timesteps)
  I <- numeric(timesteps)
  R <- numeric(timesteps)
  S[1] <- S0
  I[1] <- I0
  R[1] <- R0
  
  # Simulate dynamics with intervention
  for (t in 1:(timesteps-1)) {
    # Apply different beta before and after intervention
    current_beta <- ifelse(t < intervention_time, beta_before, beta_after)
    
    new_infections <- current_beta * S[t] * I[t] / N
    new_recoveries <- gamma * I[t]
    
    S[t+1] <- S[t] - new_infections
    I[t+1] <- I[t] + new_infections - new_recoveries
    R[t+1] <- R[t] + new_recoveries
  }
  
  # Return results as a data frame
  result <- data.frame(
    time = 1:timesteps,
    susceptible = S,
    infectious = I,
    recovered = R
  )
  
  return(result)
}

# Example usage
if (interactive()) {
  # Run basic SIR model
  sir_results <- sir_model()
  sir_plot <- plot_sir(sir_results)
  print(sir_plot)
  
  # Run model with intervention
  intervention_results <- simulate_intervention()
  intervention_plot <- plot_sir(intervention_results)
  print(intervention_plot)
  
  # Compare models with and without intervention
  if (!require("gridExtra")) {
    install.packages("gridExtra")
    library(gridExtra)
  }
  
  grid.arrange(sir_plot + ggtitle("Without Intervention"),
               intervention_plot + ggtitle("With Intervention at Day 40"),
               ncol = 2)
}