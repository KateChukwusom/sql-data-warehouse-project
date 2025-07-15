/* CREATE DATABASE AND SCHEMAS

Script purpose:
 This script creates a new database named 'DataWarehouse' after checking if it already exists. if the database exists,
 it is dropped and recreated. Additionally, the script sets up three schemas within the database:'bronze,'silver','gold'.

 */



-- create database 'DataWarehouse'

USE master;
GO

--drop and recreate the'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')

BEGIN

    ALTER  DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;

END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- create schemas

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
