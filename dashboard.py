# Epidemiological Modeling Dashboard
import streamlit as st
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import plotly.express as px
import plotly.graph_objects as go
import subprocess
import os
import tempfile
import json
import sys

# Try to import the Python implementation of the SIR model
try:
    from sir_model_py import sir_model as sir_model_py
    from sir_model_py import simulate_intervention as simulate_intervention_py
    PYTHON_MODEL_AVAILABLE = True
except ImportError:
    PYTHON_MODEL_AVAILABLE = False

# Set page configuration
st.set_page_config(
    page_title="Epidemiological Modeling Dashboard",
    page_icon="🦠",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Add custom CSS
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        color: #4257b2;
        text-align: center;
        margin-bottom: 1rem;
    }
    .sub-header {
        font-size: 1.5rem;
        color: #5c7cfa;
        margin-bottom: 1rem;
    }
    .card {
        background-color: #f8f9fa;
        border-radius: 10px;
        padding: 20px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
</style>
""", unsafe_allow_html=True)

# Header
st.markdown('<h1 class="main-header">Epidemiological Modeling Dashboard</h1>', unsafe_allow_html=True)

# Function to check if R is available
def is_r_available():
    try:
        result = subprocess.run(['Rscript', '--version'], 
                               stdout=subprocess.PIPE, 
                               stderr=subprocess.PIPE, 
                               text=True, 
                               check=False)
        return result.returncode == 0
    except FileNotFoundError:
        return False

# Function to run R script and get results
@st.cache
def run_sir_model(params):
    # Check if we should use Python implementation
    if not is_r_available() and PYTHON_MODEL_AVAILABLE:
        st.info("Using Python implementation of SIR model (R not detected)")
        # Use Python implementation
        results = sir_model_py(
            N=params['population'],
            I0=params['initial_infected'],
            R0=params['initial_recovered'],
            beta=params['beta'],
            gamma=params['gamma'],
            timesteps=params['timesteps']
        )
        return results
    
    # Use R implementation
    try:
        # Create a temporary R script with our parameters
        with tempfile.NamedTemporaryFile(suffix='.R', delete=False, mode='w') as f:
            f.write(f'''
            # Load SIR model
            source("sir_model.R")
            
            # Run model with parameters
            results <- sir_model(
                N = {params['population']}, 
                I0 = {params['initial_infected']}, 
                R0 = {params['initial_recovered']},
                beta = {params['beta']}, 
                gamma = {params['gamma']}, 
                timesteps = {params['timesteps']}
            )
            
            # Convert to JSON
            write.table(results, file="{f.name}.csv", sep=",", row.names=FALSE)
            ''')
        
        # Run the R script
        subprocess.run(['Rscript', f.name], check=True)
        
        # Read the results
        results_df = pd.read_csv(f"{f.name}.csv")
        
        # Clean up temporary files
        os.unlink(f.name)
        os.unlink(f"{f.name}.csv")
        
        return results_df
    except Exception as e:
        if PYTHON_MODEL_AVAILABLE:
            st.warning(f"Error running R script: {str(e)}. Falling back to Python implementation.")
            # Use Python implementation as fallback
            results = sir_model_py(
                N=params['population'],
                I0=params['initial_infected'],
                R0=params['initial_recovered'],
                beta=params['beta'],
                gamma=params['gamma'],
                timesteps=params['timesteps']
            )
            return results
        else:
            st.error(f"Error running model: {str(e)}. Please ensure R is installed with required packages.")
            raise e

# Function to run intervention model
def run_intervention_model(params):
    # Check if we should use Python implementation
    if not is_r_available() and PYTHON_MODEL_AVAILABLE:
        st.info("Using Python implementation of SIR model (R not detected)")
        # Use Python implementation
        results = simulate_intervention_py(
            N=params['population'],
            I0=params['initial_infected'],
            R0=params['initial_recovered'],
            beta_before=params['beta_before'],
            beta_after=params['beta_after'],
            intervention_time=params['intervention_time'],
            gamma=params['gamma'],
            timesteps=params['timesteps']
        )
        return results
    
    # Use R implementation
    try:
        # Create a temporary R script with our parameters
        with tempfile.NamedTemporaryFile(suffix='.R', delete=False, mode='w') as f:
            f.write(f'''
            # Load SIR model
            source("sir_model.R")
            
            # Run model with intervention
            results <- simulate_intervention(
                N = {params['population']}, 
                I0 = {params['initial_infected']}, 
                R0 = {params['initial_recovered']},
                beta_before = {params['beta_before']},
                beta_after = {params['beta_after']},
                intervention_time = {params['intervention_time']},
                gamma = {params['gamma']}, 
                timesteps = {params['timesteps']}
            )
            
            # Convert to JSON
            write.table(results, file="{f.name}.csv", sep=",", row.names=FALSE)
            ''')
        
        # Run the R script
        subprocess.run(['Rscript', f.name], check=True)
        
        # Read the results
        results_df = pd.read_csv(f"{f.name}.csv")
        
        # Clean up temporary files
        os.unlink(f.name)
        os.unlink(f"{f.name}.csv")
        
        return results_df
    except Exception as e:
        if PYTHON_MODEL_AVAILABLE:
            st.warning(f"Error running R script: {str(e)}. Falling back to Python implementation.")
            # Use Python implementation as fallback
            results = simulate_intervention_py(
                N=params['population'],
                I0=params['initial_infected'],
                R0=params['initial_recovered'],
                beta_before=params['beta_before'],
                beta_after=params['beta_after'],
                intervention_time=params['intervention_time'],
                gamma=params['gamma'],
                timesteps=params['timesteps']
            )
            return results
        else:
            st.error(f"Error running model: {str(e)}. Please ensure R is installed with required packages.")
            raise e

# Note: We now import the Python implementation from sir_model_py.py

# Sidebar for model selection and parameters
st.sidebar.markdown('<h2 class="sub-header">Model Parameters</h2>', unsafe_allow_html=True)

# Model selection
model_type = st.sidebar.selectbox(
    "Select Model Type",
    ["Basic SIR Model", "Intervention Model"]
)

# Common parameters
population = st.sidebar.slider("Total Population (N)", 100, 10000, 1000, 100)
initial_infected = st.sidebar.slider("Initial Infected (I0)", 1, 100, 1, 1)
initial_recovered = st.sidebar.slider("Initial Recovered (R0)", 0, 100, 0, 1)

# Transmission parameters
st.sidebar.markdown("### Transmission Parameters")
beta = st.sidebar.slider("Transmission Rate (β)", 0.0, 1.0, 0.3, 0.01)
gamma = st.sidebar.slider("Recovery Rate (γ)", 0.0, 1.0, 0.1, 0.01)
timesteps = st.sidebar.slider("Simulation Days", 50, 300, 160, 10)

# Calculate and display R0
r0_value = beta/gamma
st.sidebar.markdown(f"**Basic Reproduction Number (R₀):** {r0_value:.2f}")
st.sidebar.markdown(f"*R₀ > 1 indicates epidemic growth*")

# Intervention parameters (only shown for intervention model)
if model_type == "Intervention Model":
    st.sidebar.markdown("### Intervention Parameters")
    beta_before = beta  # Use the main beta as beta_before
    beta_after = st.sidebar.slider("Transmission Rate After Intervention (β')", 0.0, 1.0, 0.15, 0.01)
    intervention_time = st.sidebar.slider("Intervention Day", 1, timesteps-1, 40, 1)
    
    # Calculate and display R0 after intervention
    r0_after = beta_after/gamma
    st.sidebar.markdown(f"**R₀ After Intervention:** {r0_after:.2f}")

# Run button
run_button = st.sidebar.button("Run Simulation", type="primary")

# Main content area
col1, col2 = st.columns([2, 1])

with col1:
    st.markdown('<div class="card">', unsafe_allow_html=True)
    st.markdown("## Simulation Results")
    
    # Initialize or update plot
    if run_button:
        with st.spinner("Running simulation..."):
            if model_type == "Basic SIR Model":
                # Prepare parameters
                params = {
                    'population': population,
                    'initial_infected': initial_infected,
                    'initial_recovered': initial_recovered,
                    'beta': beta,
                    'gamma': gamma,
                    'timesteps': timesteps
                }
                
                # Run model
                results = run_sir_model(params)
                
                # Create plot
                fig = px.line(
                    results, x='time', y=['susceptible', 'infectious', 'recovered'],
                    labels={'value': 'Number of Individuals', 'time': 'Time (days)', 'variable': 'Compartment'},
                    title=f"SIR Model (N={population}, β={beta}, γ={gamma})",
                    color_discrete_map={
                        'susceptible': 'blue',
                        'infectious': 'red',
                        'recovered': 'green'
                    }
                )
                
                # Improve layout
                fig.update_layout(
                    legend_title_text='Compartment',
                    xaxis_title="Time (days)",
                    yaxis_title="Number of Individuals",
                    height=500
                )
                
                st.plotly_chart(fig, use_container_width=True)
                
                # Store results for metrics
                st.session_state['results'] = results
                
            elif model_type == "Intervention Model":
                # Prepare parameters
                params = {
                    'population': population,
                    'initial_infected': initial_infected,
                    'initial_recovered': initial_recovered,
                    'beta_before': beta,
                    'beta_after': beta_after,
                    'intervention_time': intervention_time,
                    'gamma': gamma,
                    'timesteps': timesteps
                }
                
                # Run model
                results = run_intervention_model(params)
                
                # Create plot
                fig = px.line(
                    results, x='time', y=['susceptible', 'infectious', 'recovered'],
                    labels={'value': 'Number of Individuals', 'time': 'Time (days)', 'variable': 'Compartment'},
                    title=f"SIR Model with Intervention at Day {intervention_time}",
                    color_discrete_map={
                        'susceptible': 'blue',
                        'infectious': 'red',
                        'recovered': 'green'
                    }
                )
                
                # Add vertical line for intervention
                fig.add_vline(x=intervention_time, line_dash="dash", line_color="gray",
                             annotation_text="Intervention", annotation_position="top right")
                
                # Improve layout
                fig.update_layout(
                    legend_title_text='Compartment',
                    xaxis_title="Time (days)",
                    yaxis_title="Number of Individuals",
                    height=500
                )
                
                st.plotly_chart(fig, use_container_width=True)
                
                # Store results for metrics
                st.session_state['results'] = results
    else:
        # Display placeholder
        st.info("Adjust parameters and click 'Run Simulation' to see results")
    
    st.markdown('</div>', unsafe_allow_html=True)

with col2:
    st.markdown('<div class="card">', unsafe_allow_html=True)
    st.markdown("## Key Metrics")
    
    if run_button and 'results' in st.session_state:
        results = st.session_state['results']
        
        # Calculate key metrics
        max_infectious = results['infectious'].max()
        time_to_peak = results.loc[results['infectious'].idxmax(), 'time']
        final_recovered = results['recovered'].iloc[-1]
        total_infected_percent = (final_recovered / population) * 100
        
        # Display metrics
        st.metric("Peak Infectious Cases", f"{max_infectious:.0f}")
        st.metric("Time to Peak (days)", f"{time_to_peak:.1f}")
        st.metric("Total Infected", f"{final_recovered:.0f} ({total_infected_percent:.1f}%)")
        
        # Additional metrics based on model type
        if model_type == "Intervention Model":
            # Calculate what would have happened without intervention
            no_intervention_params = {
                'population': population,
                'initial_infected': initial_infected,
                'initial_recovered': initial_recovered,
                'beta': beta,
                'gamma': gamma,
                'timesteps': timesteps
            }
            
            no_intervention_results = run_sir_model(no_intervention_params)
            no_intervention_total = no_intervention_results['recovered'].iloc[-1]
            
            # Calculate impact
            cases_prevented = no_intervention_total - final_recovered
            percent_reduction = (cases_prevented / no_intervention_total) * 100
            
            st.metric("Cases Prevented by Intervention", 
                     f"{cases_prevented:.0f} ({percent_reduction:.1f}%)")
    else:
        st.info("Run a simulation to see metrics")
    
    st.markdown('</div>', unsafe_allow_html=True)
    
    # Model explanation
    st.markdown('<div class="card">', unsafe_allow_html=True)
    st.markdown("## Model Information")
    
    if model_type == "Basic SIR Model":
        st.markdown("""
        The **SIR model** divides a population into three compartments:
        - **S**usceptible: Individuals who can become infected
        - **I**nfectious: Individuals who are currently infected and can transmit
        - **R**ecovered: Individuals who have recovered and are immune
        
        The model is governed by these parameters:
        - β (beta): Transmission rate
        - γ (gamma): Recovery rate
        - R₀ = β/γ: Basic reproduction number
        """)
    else:
        st.markdown("""
        The **Intervention Model** simulates the effect of public health measures:
        - Intervention reduces the transmission rate (β) at a specific time
        - Examples: social distancing, mask mandates, vaccination
        
        Compare the outcomes with and without intervention to see the impact.
        """)
    
    st.markdown('</div>', unsafe_allow_html=True)

# Footer
st.markdown("""---
*This dashboard interfaces with R-based epidemiological models. Adjust parameters in the sidebar and run simulations to explore different scenarios.*
""")