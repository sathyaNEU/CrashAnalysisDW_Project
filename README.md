# CrashAnalysisDW_Project
Crash/accident analysis project utilizing Talend ETL and Azure SQL Server to gather and analyze data from US open data portals of Austin, Chicago, and New York. Perform comprehensive accident analysis, leveraging a data warehouse approach for robust insights and reporting. This project consists of 3 stages: Data Profiling and Cleaning, Data Transformations and Loading (ETL), Data Vizualisation

# Data Profiling
During the data profiling and cleaning phase, we processed TSV data from Austin, Chicago, and New York datasets, each with varying schemas of 40-60 columns. We selected essential columns for analysis, as outlined in the accompanying PDF. Noteworthy hurdles included missing data in one-third of the datasets, affecting visualization. For instance, the Chicago dataset lacked victim details, impeding analysis of motorist and pedestrian involvement. We addressed this by cleaning the data, replacing null values with 'unknown' or 'NA'.

# Data Transformations and Cleaning
During the Data Transformations and Cleaning phase, our team developed a STTM document outlining the required data transformations. We implemented push-down optimization to ensure successful job execution irrespective of file size, processing approximately 24 million records across all jobs. However, prior to transformations, the total row count stood at nearly 3 million. We designed pipelines with three staging layers, each performing distinct data transformations as specified in the document. Dimensions and facts were loaded from specific stage pipelines.



