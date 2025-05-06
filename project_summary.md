# Epidemiological Modeling Project Summary

This project implements various compartmental models for epidemiological modeling in R. The models range from basic deterministic SIR models to more complex SEIR and stochastic implementations.

## Implemented Models

### 1. Basic SIR Model (`sir_model.R`)

The Susceptible-Infectious-Recovered (SIR) model is the foundation of compartmental modeling in epidemiology. This implementation includes:

- Core SIR dynamics with configurable parameters
- Visualization functions using ggplot2
- Intervention modeling capabilities

### 2. SEIR Model (`seir_model.R`)

The SEIR model extends the SIR model by adding an Exposed (E) compartment, which represents individuals who have been infected but are not yet infectious. This is particularly useful for diseases with an incubation period.

### 3. Stochastic SIR Model (`stochastic_sir_model.R`)

This implementation uses the Gillespie algorithm to simulate random events in continuous time, providing more realistic epidemic dynamics for smaller populations where random effects are important.

## Analysis Tools

### 1. Example Scenarios (`example_scenarios.R`)

This script demonstrates various epidemic scenarios using the SIR model, including:

- Different R₀ values
- Various initial conditions
- Intervention timing and strength comparisons

### 2. Model Comparison (`compare_models.R`)

This script provides a detailed comparison between the SIR and SEIR models, including:

- Basic behavior comparison
- Effect of incubation period in SEIR models
- Intervention effectiveness comparison
- R₀ calculation and epidemic threshold analysis

## Documentation

### 1. R Markdown Report (`SIR_Model_Report.Rmd`)

A comprehensive report that explains the mathematical foundations of the SIR model, demonstrates its implementation, and provides examples of parameter exploration and intervention modeling.

## Getting Started

1. Install required packages using `install_packages.R`
2. Start with the basic SIR model in `sir_model.R`
3. Explore the R Markdown report for detailed explanations
4. Try different scenarios with `example_scenarios.R`
5. Compare model types with `compare_models.R`
6. Experiment with stochastic effects using `stochastic_sir_model.R`

## Model Extensions

Possible extensions to the current implementations include:

1. Age-structured models
2. Spatial/geographic models
3. Vaccination and immunity waning
4. Seasonal forcing
5. Vector-borne disease models

## References

1. Kermack, W. O., & McKendrick, A. G. (1927). A contribution to the mathematical theory of epidemics.
2. Hethcote, H. W. (2000). The mathematics of infectious diseases.
3. Bjørnstad, O. N. (2018). Epidemics: Models and Data using R.