# Python implementation of SIR Epidemiological Model

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import plotly.express as px

def sir_model(N=1000, I0=1, R0=0, beta=0.3, gamma=0.1, timesteps=160):
    """
    Implements the SIR (Susceptible-Infectious-Recovered) epidemiological model.
    
    Parameters:
    -----------
    N : int
        Total population size
    I0 : int
        Initial number of infectious individuals
    R0 : int
        Initial number of recovered individuals
    beta : float
        Transmission rate
    gamma : float
        Recovery rate
    timesteps : int
        Number of time steps to simulate
        
    Returns:
    --------
    pandas.DataFrame
        DataFrame containing the number of individuals in each compartment at each time step
    """
    # Initial susceptible population
    S0 = N - I0 - R0
    
    # Initialize arrays
    S = np.zeros(timesteps)
    I = np.zeros(timesteps)
    R = np.zeros(timesteps)
    S[0] = S0
    I[0] = I0
    R[0] = R0
    
    # Simulate dynamics
    for t in range(timesteps-1):
        new_infections = beta * S[t] * I[t] / N
        new_recoveries = gamma * I[t]
        
        S[t+1] = S[t] - new_infections
        I[t+1] = I[t] + new_infections - new_recoveries
        R[t+1] = R[t] + new_recoveries
    
    # Return results as a DataFrame
    result = pd.DataFrame({
        'time': range(1, timesteps+1),
        'susceptible': S,
        'infectious': I,
        'recovered': R
    })
    
    return result

def simulate_intervention(N=1000, I0=1, R0=0, beta_before=0.3, beta_after=0.15, 
                         intervention_time=40, gamma=0.1, timesteps=160):
    """
    Simulates the SIR model with an intervention that changes the transmission rate.
    
    Parameters:
    -----------
    N : int
        Total population size
    I0 : int
        Initial number of infectious individuals
    R0 : int
        Initial number of recovered individuals
    beta_before : float
        Transmission rate before intervention
    beta_after : float
        Transmission rate after intervention
    intervention_time : int
        Time step at which intervention occurs
    gamma : float
        Recovery rate
    timesteps : int
        Number of time steps to simulate
        
    Returns:
    --------
    pandas.DataFrame
        DataFrame containing the number of individuals in each compartment at each time step
    """
    # Initial susceptible population
    S0 = N - I0 - R0
    
    # Initialize arrays
    S = np.zeros(timesteps)
    I = np.zeros(timesteps)
    R = np.zeros(timesteps)
    S[0] = S0
    I[0] = I0
    R[0] = R0
    
    # Simulate dynamics with intervention
    for t in range(timesteps-1):
        # Apply different beta before and after intervention
        current_beta = beta_before if t < intervention_time else beta_after
        
        new_infections = current_beta * S[t] * I[t] / N
        new_recoveries = gamma * I[t]
        
        S[t+1] = S[t] - new_infections
        I[t+1] = I[t] + new_infections - new_recoveries
        R[t+1] = R[t] + new_recoveries
    
    # Return results as a DataFrame
    result = pd.DataFrame({
        'time': range(1, timesteps+1),
        'susceptible': S,
        'infectious': I,
        'recovered': R
    })
    
    return result

def plot_sir(sir_data):
    """
    Creates a plot of SIR model results using Plotly.
    
    Parameters:
    -----------
    sir_data : pandas.DataFrame
        DataFrame containing the SIR model results
        
    Returns:
    --------
    plotly.graph_objects.Figure
        Plotly figure object containing the SIR model plot
    """
    fig = px.line(
        sir_data, x='time', y=['susceptible', 'infectious', 'recovered'],
        labels={'value': 'Number of Individuals', 'time': 'Time (days)', 'variable': 'Compartment'},
        title="SIR Epidemiological Model",
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
        yaxis_title="Number of Individuals"
    )
    
    return fig

# Example usage
if __name__ == "__main__":
    # Run basic SIR model
    results = sir_model()
    print("Basic SIR Model Results:")
    print(f"Peak infectious cases: {results['infectious'].max():.0f}")
    print(f"Time to peak: {results.loc[results['infectious'].idxmax(), 'time']:.1f} days")
    print(f"Final recovered (total infected): {results['recovered'].iloc[-1]:.0f}")
    
    # Create and show plot
    fig = plot_sir(results)
    fig.show()