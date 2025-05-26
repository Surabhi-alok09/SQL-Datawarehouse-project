/*
==============================================================================
Create Database and Schemas
==============================================================================
Script Purpose:
   This SQL script is designed to initialize the data warehouse environment by programmatically handling the creation of the database and its associated schemas.
   It first checks for the existence of the target database and schemas, then safely drops them if they exist to ensure a clean and consistent setup. 
   Afterward, it recreates the database along with structured schemas bronze, silver, gold to be  used in ETL pipelines for organizing data ingestion, transformation, and reporting layers. 
   This approach helps maintain a standardized and repeatable deployment process, particularly useful for development, testing, and automated CI/CD workflows in data engineering projects.

⚠️ WARNING
This script will permanently drop and recreate the target database and its associated schemas. 
All existing data, tables, views, and other objects will be deleted. Use with extreme caution, especially in shared, staging, or production environments.
Ensure you have a valid backup or have confirmed that data loss is acceptable before running this script.
*/

USE master;
GO

--Drop and recreate the 'DataWarehouse' database
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

--CREATE the 'DataWarehouse' database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
