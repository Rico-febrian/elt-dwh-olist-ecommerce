# **How I Build an ELT Pipeline with Luigi**

--- 

Hi there!, Welcome to my project.

**In this guide, I will share how I developed an ELT pipeline for an e-commerce business based on a study case**. For the full story about the study case and how I designed the data warehouse, you can check out my article on Medium here: [full-story]().

**In this repository, I’ll focus specifically on how I developed the ELT pipeline.**

---

# Dataset Overview
I used an e-commerce business dataset from Kaggle. Here's the full dataset: [olist-dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce?select=olist_geolocation_dataset.csv)

---

Alright, let's begin!, Here's the step-by-step guide:

# Requirements

- OS:
    - Linux
    - WSL (Windows Subsystem For Linux)
      
- Tools:
    - Dbeaver (using postgreSQL)
    - Docker
    - Cron
      
- Programming Language:
    - Python
    - SQL
      
- Python Libray:
    - Luigi
    - Pandas
    - Sentry-SDK
      
- Platforms:
    - Sentry

---

# Preparations

## - **Clone or download this repository to get the populated data for the source database**

  ```
  git lfs clone git@github.com:Kurikulum-Sekolah-Pacmann/dataset-olist.git
  ```

## - **Create and activate python environment to isolate project dependencies**
  
  ```
  python -m venv my_project   # Change my_project with your project name
  source venv/bin/activate    # On Windows: venv\Scripts\activate
  ```
  
## - **Set up or edit a directory structure to organize all project scripts**
  
  ```
  project/
  ├── helper/   # To store SQL script to create db schema
  │   ├── dwh_schema/
  │   └── src_schema/
  ├── logs/     # To store pipeline logs
  ├── pipeline/ # To store pipeline dependencies and develop the scripts 
  │   ├── elt_query/
  │   ├── utils_function/
  │   └── elt_dev_script.py
  │ 
  │ # Root project to store the main scripts
  │ 
  ├── .env
  ├── main_pipeline.py 
  ├── pipeline.sh
  ├── docker-compose.yml
  └── requirements.txt
  ```

## - **Install _requirements.txt_ in the created environment**
  
  ```
  pip install -r requirements.txt
  ```
  
  > **You can install libraries as needed while developing the code. However, once complete, make sure to generate a requirements.txt file listing all dependencies**.

## - **Create _.env_ file to store all credential information**
  
  ```
  touch .env
  ```
  
## - **Set up a Sentry project to receive email notifications in case of any errors in the pipeline**
  - Open and signup to: https://www.sentry.io 
  - Create Project :
    - Select Platform : Python
    - Set Alert frequency : `On every new issue`
    - Create project name.
  - After create the project, **store the SENTRY DSN project key into the .env file**

---

# Develop the ELT Code

## - Setup database
  - Create a [_docker-compose.yml_](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/docker-compose.yml) file to set up both the data source and data warehouse databases.
  - Store database credentials in _.env_ file  

    ```
    # Source
    SRC_POSTGRES_DB=[YOUR SOURCE DB NAME]
    SRC_POSTGRES_HOST=localhost
    SRC_POSTGRES_USER=[YOUR USERNAME]
    SRC_POSTGRES_PASSWORD=[YOUR PASSWORD]
    SRC_POSTGRES_PORT=[YOUR PORT]
    
    # DWH
    DWH_POSTGRES_DB=[YOUR DWH DB NAME] 
    DWH_POSTGRES_HOST=localhost
    DWH_POSTGRES_USER=[YOUR USERNAME]
    DWH_POSTGRES_PASSWORD=[YOUR PASSWORD]
    DWH_POSTGRES_PORT=[YOUR PORT]
    ```
  - Run the _docker-compose.yml_ file 

    ```
    docker-compose up -d
    ```

  - Connect the database to Dbeaver
    - Click **Database** > select **New Database Connection**
    - Select postgreSQL
    - Fill in the port, database, username, and password **as defined in your _.env_**
    - Click **Test Connection**
    - If no errors appear, the database connection is successful   

## - Create utility functions

  **This utility function acts like a basic tool you can use repeatedly when building the pipeline script.**

  -  [Database connector](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/pipeline/utils_function/db_connector.py)
      -  Function to connect python and the database    
  
  -  [Read SQL file](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/pipeline/utils_function/read_sql.py)
      -  Function to read the SQL query files and return it as string so python can run it 
  
  - [Concat DataFrame summary - Optional](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/pipeline/utils_function/concat_df.py)
      - Function to merge the summary data from ELT pipeline

  - [Copy log - Optional](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/pipeline/utils_function/copy_log.py)
      - Function to copy temporary log into main log

  - [Delete temporary data - Optional](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/pipeline/utils_function/delete_temp_data.py)
      - Function to delete all temporary data from ELT pipeline 

## - Create SQL queries to set up schemas, tables, and their constraints _based on data warehouse design_.

You can view the complete data warehouse design for this project in my Medium article: [Data Warehouse Design](https://medium.com/@ricofebrian731/learning-data-engineering-designing-a-data-warehouse-and-building-an-elt-pipeline-for-e-commerce-1f6b77cdfc28)

  - Source database
    - [init](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/helper/source_init/init.sql)
      
  - Warehouse database
    - [Public schema](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/helper/dwh_init/dwh_src_schema.sql)
      
    - [Staging schema](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/helper/dwh_init/dwh_stg_schema.sql)
      
    - [Final schema](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/helper/dwh_init/dwh_final_schema.sql)
      
## - Create SQL queries to extract, load, transform and handling data updates

  - [Extract query](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/tree/main/pipeline/src_query/extract)
    - This query used to:
      - Extract data from source database into data warehouse's public schema
  
  - [Load queries](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/tree/main/pipeline/src_query/load)
    - This query used to:
      - Load data from public to staging schema
      - Handle updated data in each table within staging schema
  
  - [Transform queries](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/tree/main/pipeline/src_query/transform)
    - This query used to:
      - Load transformed data from staging to the final schema
      - Handle updated data in each table within final schema
   
## - Create ELT pipeline task with Luigi

I developed each task separately to ensure everything function properly.

  - Common components in each task
    - Logging setup
        ```
        # Configure logging at the start of each task to assist with monitoring and debugging
  
        # Configure logging
        logging.basicConfig(filename = f'{<YOUR DIRECTORY TO STORE LOG>}/logs.log', 
                            level = logging.INFO, 
                            format = '%(asctime)s - %(levelname)s - %(message)s')
        
        # Record start time
        start_time = time.time()
        
        # Create a log message
        logging.info("START LOG")

        try: 
          ....................................
          # YOUR MAIN CODE/FUNCTION
          ...................................
          
        # If there is an error, catch and store to the log file
        except Exception:
            logging.error()  
            raise Exception()

        # Log completion
        logging.info('TASK SUCCESS/FAILED!')
        end_time = time.time()  # Record end time
        execution_time = end_time - start_time  # Calculate execution time
        logging.info("END LOG")
        ```
  
  - Task summary setup
      ```
      # This summary makes tracking and analyzing pipeline tasks easier than using logs  
      
      # Define a summary
      summary_data = {
          'timestamp': [datetime.now()],
          'task': ['<CHANGE WITH YOUR TASK NAME>'],
          'status' : ['Success'],
          'execution_time': [execution_time]
      }
      
      # Get summary dataframes
      summary = pd.DataFrame(summary_data)
      
      # Write DataFrame to CSV
      summary.to_csv(f"{YOUR TEMPORARY DATA DIRECTORY}/<YOUR SUMMARY FILENAME>", index = False)
      ```
  
- Main pipeline task 
  - [Extract task](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/pipeline/extract.py)
    - This task **pulls data from the source database** and **loads it into the public schema** in the warehouse database
    - Task outputs include:
      - CSV files for each extracted table
      - Task summary CSV
      - Log file
        
  - [Load task](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/pipeline/load.py)
    - This task **reads data from each CSV file generated by the Extract task** and **loads it into the staging schema** in the warehouse database
    - Task outputs include:
      - Task summary CSV
      - Log file

  - [Transform task](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/pipeline/transform.py)
    - This task **pulls data from the Load task in the staging schema**, **transforms it**, and **loads it into the final schema** in the warehouse database
    - This task output such as:
      - Task summary CSV
      - Log file

---

# Testing

## - Run the ELT pipeline

When developed the script you can run the Luigi task separately or execute all of them at once.

```
# Run the luigi task separately

# In your task script, run this:
if __name__ == '__main__':
     luigi.build(<YOUR TASK>()])
```

```
# Or you can execute all of them at once

# In your final task script, run this:
if __name__ == '__main__':
     luigi.build([<TASK A>(),
                  <TASK B>(),
                  ..........
                  <UNTIL YOUR LAST TASK>()])
```
## - Luigi behaviour and limitations

**Important Note:**  

  **- No duplicate runs:**
  - If a task is already running, Luigi will skip new attempts to run it
  
  **- Automatic Dependencies**
  - Luigi handles task order automatically
  - Running the final task triggers all required previous tasks  
      
    ```
    # Task dependencies example
    
    # There is three tasks: Extract, Load, Transform
    
    # Running just the final task
    luigi.build([Transform()])
          
    # Luigi automatically executes in this order:
    # 1. ExtractTask (runs first)
    # 2. LoadTask (runs second)
    # 3. TransformTask (runs last)
    ```

## - Monitoring log and task summary

You can easily check the log file for any errors in your pipeline during development.

- Error log

- Error task summary

---

# Finalizing the Project

## - Compile and test

- Compile all task into a single main script, like [main_elt_pipeline.py](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/main_elt_pipeline.py)
- Run the main script to test the pipeline end-to-end
- Verify all outputs and transformations in Dbeaver
- Review logs and summaries

## - Set up schedulers

- Create a cron job to automate pipeline execution.
  
  - Create shell script [elt_pipeline.sh](https://github.com/Rico-febrian/elt-dwh-olist-ecommerce/blob/main/elt_pipeline.sh)
    ```
    touch SHELL_SCRIPT_NAME.sh
    ```
    ```
    # In SHELL SCRIPT NAME.sh, write this:
    
    #!/bin/bash
    
    # Virtual Environment Path
    VENV_PATH="/PATH/TO/YOUR/VIRTUAL/ENVIRONMENT/bin/activate"
    
    # Activate Virtual Environment
    source "$VENV_PATH"
    
    # Set Python script
    PYTHON_SCRIPT="/PATH/TO/YOUR/MAIN/PIPELINE/SCRIPT/main_elt_pipeline.py"
    
    # Run Python Script 
    python "$PYTHON_SCRIPT"
    ```

  - Make the script executable
    ```
    # In your shell script directory, run this
    chmod +x <SHELL SCRIPT NAME>.sh
    ```
  - Set up cron job
    ```
    # Open crontab
    crontab -e
    ```
    ```
    # In crontab editor

    # Set the schedule like this to run the pipeline EVERY HOUR
    0 * * * * /PATH/TO/YOUR/SHELL/SCRIPT/<SHELL SCRIPT NAME>.sh
    ```
  - Or you can run the shell script manually
    ```
    ./<SHELL SCRIPT NAME>.sh
    ```
  
  ---

# Final Result

## - Pipeline
## - Summary
## - Log