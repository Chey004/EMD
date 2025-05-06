# Setup script for Python dashboard dependencies
import subprocess
import sys
import os

def check_python_version():
    """Check if Python version is compatible"""
    if sys.version_info < (3, 7):
        print("Error: Python 3.7 or higher is required.")
        print(f"Current Python version: {sys.version}")
        return False
    return True

def check_r_installation():
    """Check if R is installed and accessible"""
    try:
        subprocess.run(['Rscript', '--version'], check=True, capture_output=True)
        return True
    except (subprocess.SubprocessError, FileNotFoundError):
        print("Error: R is not installed or not in PATH.")
        print("Please install R from https://www.r-project.org/")
        return False

def install_r_packages():
    """Install required R packages"""
    print("\nInstalling required R packages...")
    try:
        subprocess.run(['Rscript', 'install_packages.R'], check=True)
        print("R packages installed successfully.")
        return True
    except subprocess.SubprocessError:
        print("Error: Failed to install R packages.")
        print("Please run 'Rscript install_packages.R' manually.")
        return False

def install_python_packages():
    """Install required Python packages"""
    print("\nInstalling required Python packages...")
    try:
        subprocess.run([sys.executable, '-m', 'pip', 'install', '-r', 'requirements.txt'], check=True)
        print("Python packages installed successfully.")
        return True
    except subprocess.SubprocessError:
        print("Error: Failed to install Python packages.")
        print("Please run 'pip install -r requirements.txt' manually.")
        return False

def main():
    print("===== Epidemiological Modeling Dashboard Setup =====\n")
    
    # Check Python version
    if not check_python_version():
        return False
    
    # Check R installation
    if not check_r_installation():
        return False
    
    # Install R packages
    install_r_packages()
    
    # Install Python packages
    install_python_packages()
    
    print("\n===== Setup Complete =====")
    print("You can now run the dashboard with: streamlit run dashboard.py")
    return True

if __name__ == "__main__":
    main()