# Epidemiological Modeling Project

This repository contains an implementation of the SIR (Susceptible-Infectious-Recovered) compartmental model for epidemiological modeling in R. The project provides tools for simulating disease spread, visualizing results, and evaluating the impact of interventions.

## Contents

- `sir_model.R`: Core implementation of the SIR model with functions for simulation and visualization
- `SIR_Model_Report.Rmd`: R Markdown report that explains the model, demonstrates its use, and provides examples

## Getting Started

### Prerequisites

To run the code in this project, you'll need:

- R (version 3.5.0 or higher recommended)
- RStudio (for working with R Markdown)

The following R packages are required and will be installed automatically if needed:
- ggplot2
- reshape2
- gridExtra

### Running the Model

1. Open R or RStudio
2. Set your working directory to this project folder
3. Source the model file:
   ```r
   source("sir_model.R")
   ```
4. Run a basic simulation:
   ```r
   results <- sir_model()
   plot_sir(results)
   ```

### Generating the Report

To compile the R Markdown report:

1. Open `SIR_Model_Report.Rmd` in RStudio
2. Click the "Knit" button to generate an HTML report

## Model Parameters

The SIR model functions accept the following parameters:

- `N`: Total population size (default: 1000)
- `I0`: Initial number of infectious individuals (default: 1)
- `R0`: Initial number of recovered individuals (default: 0)
- `beta`: Transmission rate (default: 0.3)
- `gamma`: Recovery rate (default: 0.1)
- `timesteps`: Number of time steps to simulate (default: 160)

For the intervention simulation, additional parameters include:

- `beta_before`: Transmission rate before intervention (default: 0.3)
- `beta_after`: Transmission rate after intervention (default: 0.15)
- `intervention_time`: Time step when intervention begins (default: 40)

## Example Usage

```r
# Basic SIR model
results <- sir_model(N = 10000, beta = 0.4, gamma = 0.1)
plot_sir(results)

# Model with intervention
intervention_results <- simulate_intervention(
  N = 10000,
  beta_before = 0.4,
  beta_after = 0.1,
  intervention_time = 30
)
plot_sir(intervention_results)
```

## Extending the Model

This implementation provides a foundation that can be extended to create more complex models such as:

- SEIR model (adding an Exposed compartment)
- Age-structured models
- Spatial models
- Stochastic models

## References

- Kermack, W. O., & McKendrick, A. G. (1927). A contribution to the mathematical theory of epidemics.
- Hethcote, H. W. (2000). The mathematics of infectious diseases.