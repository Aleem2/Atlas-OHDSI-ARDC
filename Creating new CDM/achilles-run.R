# 1. Load necessary libraries
library(DatabaseConnector)
library(Achilles)

# 2. Define connection details for your PostgreSQL database
# IMPORTANT: Replace these with your actual database credentials and server info.
# For security, avoid hardcoding passwords directly in scripts for production.
# Consider using environment variables or a secure configuration file.
connectionDetails <- createConnectionDetails(
  dbms = "postgresql",
  server = "your.postgres.server.com/your_database_name", # e.g., "localhost/ohdsi_cdm"
  port = 5432,                                          # Default PostgreSQL port
  user = "your_username",
  password = "your_password"
)

# 3. Define your OMOP CDM and results schemas
# Replace 'your_cdm_schema' and 'your_results_schema' with your actual schema names.
# For example, if your OMOP CDM tables are in a schema named 'public' and you
# want Achilles to create its results tables in a schema named 'achilles_results'.
cdmDatabaseSchema <- "your_cdm_schema"      # Schema where your OMOP CDM tables reside
resultsDatabaseSchema <- "your_results_schema" # Schema where Achilles will write its results
scratchDatabaseSchema <- "your_scratch_schema" # Schema for temporary tables (can be same as results or a dedicated scratch schema)
vocabDatabaseSchema <- "your_cdm_schema"    # Schema where OMOP Vocabulary tables reside (often same as CDM)

# 4. (Optional) Define a source name
sourceName <- "My Synthetic Achilles CDM"

# 5. Run Achilles
# This is the core function call.
# You can uncomment and modify parameters as needed.
# For a first run, it's often good to run all analyses.
# For large datasets, consider using numThreads for parallel processing
# and potentially specifying specific analysisIds.
achilles(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  resultsDatabaseSchema = resultsDatabaseSchema,
  scratchDatabaseSchema = scratchDatabaseSchema, # Optional, defaults to resultsDatabaseSchema
  vocabDatabaseSchema = vocabDatabaseSchema,     # Optional, defaults to cdmDatabaseSchema
  sourceName = sourceName,
  cdmVersion = "5.4",                            # IMPORTANT: Specify your OMOP CDM version
  # analysisIds = c(101, 102),                   # Optional: Run only specific analysis IDs
  createTable = TRUE,                            # Set to TRUE to create results tables if they don't exist
  createIndices = TRUE,                          # Recommended for performance
  runHeel = TRUE,                                # Run Achilles Heel for data quality checks
  smallCellCount = 5,                            # Suppress counts <= this number for privacy
  numThreads = 1,                                # Number of threads for parallel processing (adjust based on server CPU)
  dropScratchTables = TRUE,                      # Recommended to clean up temporary tables
  outputFolder = "C:/AchillesOutput"             # Folder to save logs and SQL files
)

# 6. After running Achilles, you can connect to your results database
# and explore the tables created (e.g., achilles_results, achilles_results_dist, achilles_heel).
# These tables can then be used by OHDSI tools like Atlas for data characterization dashboards.