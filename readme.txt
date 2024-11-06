Order of SQL script execution :

1) audit_ddl.sql -> creates audit-related tables to support auditing features in the workflow (Optional). Necessary if the workflow is run
at the orchestration level

2) audit_dml.sql -> All the workflow-related information is inserted into the audit table

3) create_model_ddl -> Creates the integration schema (dimension model) of our project

Optional:

4) reset_model_dml -> deletes all the rows and resets the identity columns

5) drop_script -> drops all the tables in the database