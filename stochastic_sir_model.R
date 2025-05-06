# Stochastic SIR Epidemiological Model Implementation

# This model implements a stochastic version of the SIR model using the Gillespie algorithm
# to simulate random events in continuous time, providing more realistic epidemic dynamics
# for smaller populations where random effects are important.

# Stochastic SIR model function
stochastic_sir_model <- function(N = 1000, I0 = 1, R0 = 0, 
                               beta = 0.3, gamma = 0.1, 
                               max_time = 160, 
                               num_simulations = 1) {
  # Initial susceptible population
  S0 <- N - I0 - R0
  
  # Function to run a single stochastic simulation
  run_single_simulation <- function() {
    # Initialize state
    S <- S0
    I <- I0
    R <- R0
    t <- 0
    
    # Initialize results vectors
    times <- c(0)
    S_values <- c(S)
    I_values <- c(I)
    R_values <- c(R)
    
    # Run simulation until max time or disease extinction
    while (t < max_time && I > 0) {
      # Calculate transition rates
      infection_rate <- beta * S * I / N
      recovery_rate <- gamma * I
      total_rate <- infection_rate + recovery_rate
      
      # If no events possible, break
      if (total_rate == 0) break
      
      # Time to next event (exponentially distributed)
      dt <- rexp(1, total_rate)
      t <- t + dt
      
      # Determine which event occurs
      if (runif(1) < infection_rate / total_rate) {
        # Infection event
        S <- S - 1
        I <- I + 1
      } else {
        # Recovery event
        I <- I - 1
        R <- R + 1
      }
      
      # Record state
      times <- c(times, t)
      S_values <- c(S_values, S)
      I_values <- c(I_values, I)
      R_values <- c(R_values, R)
    }
    
    # Create data frame with results
    result <- data.frame(
      time = times,
      susceptible = S_values,
      infectious = I_values,
      recovered = R_values
    )
    
    return(result)
  }
  
  # Run multiple simulations if requested
  if (num_simulations == 1) {
    return(run_single_simulation())
  } else {
    # Run multiple simulations and store them in a list
    simulations <- list()
    for (i in 1:num_simulations) {
      simulations[[i]] <- run_single_simulation()
    }
    return(simulations)
  }
}

# Function to plot a single stochastic SIR simulation
plot_stochastic_sir <- function(sir_data) {
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
    labs(title = "Stochastic SIR Epidemiological Model",
         x = "Time (days)",
         y = "Number of individuals",
         color = "Compartment") +
    theme_minimal() +
    theme(legend.position = "right")
  
  return(p)
}

# Function to plot multiple stochastic simulations
plot_multiple_stochastic_sims <- function(simulations) {
  # Check if required packages are installed
  if (!require("ggplot2")) {
    install.packages("ggplot2")
    library(ggplot2)
  }
  
  # Create empty plot for infectious curves
  p <- ggplot() + 
    labs(title = "Multiple Stochastic SIR Simulations",
         x = "Time (days)",
         y = "Number of infectious individuals") +
    theme_minimal()
  
  # Add each simulation as a separate line
  for (i in 1:length(simulations)) {
    sim_data <- simulations[[i]]
    p <- p + geom_line(data = sim_data, 
                       aes(x = time, y = infectious), 
                       alpha = 0.3, color = "red")
  }
  
  # Run deterministic SIR for comparison
  source("sir_model.R")
  det_sir <- sir_model()
  
  # Add deterministic curve
  p <- p + geom_line(data = det_sir, 
                     aes(x = time, y = infectious), 
                     color = "black", size = 1.2) +
    annotate("text", x = max(det_sir$time) * 0.8, y = max(det_sir$infectious) * 0.9, 
             label = "Deterministic model", hjust = 0)
  
  return(p)
}

# Example usage
if (interactive()) {
  # Run a single stochastic simulation
  set.seed(123)  # For reproducibility
  stoch_sir_results <- stochastic_sir_model()
  stoch_plot <- plot_stochastic_sir(stoch_sir_results)
  print(stoch_plot)
  
  # Run multiple simulations
  set.seed(456)  # For reproducibility
  multi_sims <- stochastic_sir_model(num_simulations = 20)
  multi_plot <- plot_multiple_stochastic_sims(multi_sims)
  print(multi_plot)
  
  # Compare with deterministic model
  source("sir_model.R")
  det_sir <- sir_model()
  
  # Load required packages
  if (!require("gridExtra")) {
    install.packages("gridExtra")
    library(gridExtra)
  }
  
  # Plot comparison
  det_plot <- plot_sir(det_sir) + ggtitle("Deterministic SIR Model")
  grid.arrange(det_plot, stoch_plot, ncol = 2)
}