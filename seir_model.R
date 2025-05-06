# SEIR Epidemiological Model Implementation
# Extension of the basic SIR model with an additional Exposed (E) compartment

# SEIR model function
seir_model <- function(N = 1000, E0 = 0, I0 = 1, R0 = 0, 
                      beta = 0.3, sigma = 0.2, gamma = 0.1, 
                      timesteps = 160) {
  # Initial susceptible population
  S0 <- N - E0 - I0 - R0
  
  # Initialize vectors
  S <- numeric(timesteps)
  E <- numeric(timesteps)
  I <- numeric(timesteps)
  R <- numeric(timesteps)
  S[1] <- S0
  E[1] <- E0
  I[1] <- I0
  R[1] <- R0
  
  # Simulate dynamics
  for (t in 1:(timesteps-1)) {
    # New exposures (S -> E)
    new_exposures <- beta * S[t] * I[t] / N
    
    # New infections (E -> I)
    new_infections <- sigma * E[t]
    
    # New recoveries (I -> R)
    new_recoveries <- gamma * I[t]
    
    # Update compartments
    S[t+1] <- S[t] - new_exposures
    E[t+1] <- E[t] + new_exposures - new_infections
    I[t+1] <- I[t] + new_infections - new_recoveries
    R[t+1] <- R[t] + new_recoveries
  }
  
  # Return results as a data frame
  result <- data.frame(
    time = 1:timesteps,
    susceptible = S,
    exposed = E,
    infectious = I,
    recovered = R
  )
  
  return(result)
}

# Function to plot SEIR model results
plot_seir <- function(seir_data) {
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
  
  plot_data <- melt(seir_data, id.vars = "time", 
                    variable.name = "compartment", 
                    value.name = "count")
  
  # Create plot
  p <- ggplot(plot_data, aes(x = time, y = count, color = compartment)) +
    geom_line(size = 1.2) +
    scale_color_manual(values = c("susceptible" = "blue", 
                                 "exposed" = "orange",
                                 "infectious" = "red", 
                                 "recovered" = "green"),
                      labels = c("Susceptible", "Exposed", "Infectious", "Recovered")) +
    labs(title = "SEIR Epidemiological Model",
         x = "Time (days)",
         y = "Number of individuals",
         color = "Compartment") +
    theme_minimal() +
    theme(legend.position = "right")
  
  return(p)
}

# Function to simulate intervention effects in SEIR model
simulate_seir_intervention <- function(N = 1000, E0 = 0, I0 = 1, R0 = 0, 
                                     beta_before = 0.3, beta_after = 0.15, 
                                     intervention_time = 40,
                                     sigma = 0.2, gamma = 0.1, 
                                     timesteps = 160) {
  # Initial susceptible population
  S0 <- N - E0 - I0 - R0
  
  # Initialize vectors
  S <- numeric(timesteps)
  E <- numeric(timesteps)
  I <- numeric(timesteps)
  R <- numeric(timesteps)
  S[1] <- S0
  E[1] <- E0
  I[1] <- I0
  R[1] <- R0
  
  # Simulate dynamics with intervention
  for (t in 1:(timesteps-1)) {
    # Apply different beta before and after intervention
    current_beta <- ifelse(t < intervention_time, beta_before, beta_after)
    
    # New exposures (S -> E)
    new_exposures <- current_beta * S[t] * I[t] / N
    
    # New infections (E -> I)
    new_infections <- sigma * E[t]
    
    # New recoveries (I -> R)
    new_recoveries <- gamma * I[t]
    
    # Update compartments
    S[t+1] <- S[t] - new_exposures
    E[t+1] <- E[t] + new_exposures - new_infections
    I[t+1] <- I[t] + new_infections - new_recoveries
    R[t+1] <- R[t] + new_recoveries
  }
  
  # Return results as a data frame
  result <- data.frame(
    time = 1:timesteps,
    susceptible = S,
    exposed = E,
    infectious = I,
    recovered = R
  )
  
  return(result)
}

# Example usage
if (interactive()) {
  # Run basic SEIR model
  seir_results <- seir_model()
  seir_plot <- plot_seir(seir_results)
  print(seir_plot)
  
  # Compare SIR and SEIR models
  if (!require("gridExtra")) {
    install.packages("gridExtra")
    library(gridExtra)
  }
  
  # Load SIR model functions
  source("sir_model.R")
  
  # Run SIR model with same parameters
  sir_results <- sir_model()
  sir_plot <- plot_sir(sir_results) + ggtitle("SIR Model")
  
  # Plot SEIR with title
  seir_plot_titled <- plot_seir(seir_results) + ggtitle("SEIR Model")
  
  # Compare models
  grid.arrange(sir_plot, seir_plot_titled, ncol = 2)
}