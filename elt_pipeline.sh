#!/bin/bash

echo "========== Start Orcestration Process =========="

# Virtual Environment Path
VENV_PATH="/home/ricofebrian/data-warehouse-labs/exercise/olist-elt/exercise-week-5/bin/activate"

# Activate Virtual Environment
source "$VENV_PATH"

# Set Python script
PYTHON_SCRIPT="/home/ricofebrian/data-warehouse-labs/exercise/olist-elt/main_elt_pipeline.py"

# Run Python Script 
python "$PYTHON_SCRIPT"

echo "========== End of Orcestration Process =========="