USE master;

--Note the following will drop database named DataWarehouse if exists.
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	DROP DATABASE DataWarehouse
END;

--creates new Database with name DataWarehouse
CREATE DATABASE DataWarehouse;

USE DataWarehouse;
GO
--Create Needed schemas for the project
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
