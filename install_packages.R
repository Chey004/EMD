# Installation script for required packages

# List of required packages
required_packages <- c("ggplot2", "reshape2", "gridExtra")

# Function to check and install packages
install_if_missing <- function(packages) {
  for (package in packages) {
    if (!require(package, character.only = TRUE, quietly = TRUE)) {
      cat("Installing package:", package, "\n")
      install.packages(package, repos = "https://cran.r-project.org")
      
      # Check if installation was successful
      if (!require(package, character.only = TRUE, quietly = TRUE)) {
        warning(paste("Package", package, "could not be installed."))
      } else {
        cat("Package", package, "successfully installed.\n")
      }
    } else {
      cat("Package", package, "is already installed.\n")
    }
  }
}

# Install required packages
cat("Checking and installing required packages for SIR Epidemiological Model...\n")
install_if_missing(required_packages)
cat("\nSetup complete. You can now run the SIR model scripts.\n")

cat("\nTo get started, run the following commands:\n")
cat("source(\"sir_model.R\")\n")
cat("# Run a basic simulation\n")
cat("results <- sir_model()\n")
cat("plot_sir(results)\n")