# Epidemiological Modeling Dashboard

This dashboard provides an interactive web interface for the SIR epidemiological models in this project. It allows you to visualize and experiment with different parameters without needing to write any code.

## Features

- Interactive parameter adjustment with sliders
- Real-time visualization of model outputs
- Support for both basic SIR model and intervention scenarios
- Key metrics calculation and display
- Responsive design that works on various screen sizes

## Requirements

- Python 3.7 or higher
- R with the required packages installed (run `install_packages.R` first)
- Python packages listed in `requirements.txt`

## Installation

1. Make sure R is installed with the required packages:
   ```
   Rscript install_packages.R
   ```

2. Install the Python dependencies:
   ```
   pip install -r requirements.txt
   ```

## Running the Dashboard

To start the dashboard, run:

```
streamlit run dashboard.py
```

This will start a local web server and automatically open the dashboard in your default web browser. If it doesn't open automatically, you can access it at http://localhost:8501.

## Using the Dashboard

1. **Select a Model Type** - Choose between the basic SIR model or the intervention model
2. **Adjust Parameters** - Use the sliders in the sidebar to set population size, transmission rates, etc.
3. **Run Simulation** - Click the "Run Simulation" button to execute the model with your parameters
4. **Analyze Results** - View the resulting epidemic curves and key metrics

## How It Works

The dashboard uses Streamlit to create the web interface and interacts with the existing R models through subprocess calls. When you run a simulation, the dashboard:

1. Creates a temporary R script with your parameter settings
2. Executes the R script, which runs the appropriate model function
3. Reads the results and displays them in interactive plots

## Troubleshooting

- **Error: R not found** - Ensure R is installed and in your system PATH
- **Missing R packages** - Run `install_packages.R` to install required R packages
- **Python dependency errors** - Make sure you've installed all requirements with `pip install -r requirements.txt`

## Future Enhancements

- Support for SEIR and stochastic models
- Comparison of multiple scenarios side-by-side
- Export of results and plots
- Parameter optimization tools