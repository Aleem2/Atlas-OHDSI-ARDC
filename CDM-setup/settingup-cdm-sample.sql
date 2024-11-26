-- highlevel data --- username= webapi_sa ; password=webapi_sa1 ; databasename= cdm ;
-- connect to db and update the details. psql -U postgres -d cdm      
-- This file is now part of the postgres init-script
  
    
--Group: cdm
CREATE ROLE cdm_group
    CREATEDB REPLICATION
    VALID UNTIL 'infinity';
COMMENT ON ROLE cdm_group
    IS 'cdm group for OHDSI applications';

--Creating Database Login Roles
CREATE ROLE webapi_sa LOGIN ENCRYPTED PASSWORD 'md58d34c863380040dd6e1795bd088ff4a9'
    VALID UNTIL 'infinity';
GRANT cdm_group TO webapi_sa;
COMMENT ON ROLE webapi_sa
    IS 'cdm account for OHDSI applications';
ALTER ROLE webapi_sa WITH PASSWORD '$ENV{webapi_sa}';


   
--Creating the OHDSI WebAPI database
CREATE DATABASE "cdm"
    WITH ENCODING='UTF8'
        OWNER=cdm_group
        CONNECTION LIMIT=-1;
COMMENT ON DATABASE "cdm"
    IS 'cdm ohdsi database';
GRANT ALL ON DATABASE "cdm" TO GROUP cdm_group;
GRANT CONNECT, TEMPORARY ON DATABASE "cdm" TO GROUP cdm_group;

-- creating other schemas -- linked https://github.com/OHDSI/WebAPI/wiki/CDM-Configuration

    -----------------------------
--------------------------------
-- writing up the tabled schema . 
-- Create the results schema
-- ********** to run these commands log into the cdm database and then create these schemas.
CREATE SCHEMA IF NOT EXISTS cdm;

-- Create the temp schema
CREATE SCHEMA IF NOT EXISTS vocabulary;

-- Create the results schema
CREATE SCHEMA IF NOT EXISTS results;

-- Create the temp schema
CREATE SCHEMA IF NOT EXISTS temp;




GRANT USAGE ON SCHEMA cdm TO webapi_sa;
GRANT SELECT ON ALL TABLES IN SCHEMA cdm TO webapi_sa;
GRANT INSERT, DELETE, SELECT, UPDATE ON ALL TABLES IN SCHEMA cdm TO webapi_sa;


GRANT USAGE ON SCHEMA vocabulary TO webapi_sa;
GRANT SELECT ON ALL TABLES IN SCHEMA vocabulary TO webapi_sa;
GRANT INSERT, DELETE, SELECT, UPDATE ON ALL TABLES IN SCHEMA vocabulary TO webapi_sa;





GRANT USAGE ON SCHEMA results TO webapi_sa;
GRANT SELECT ON ALL TABLES IN SCHEMA results TO webapi_sa;
GRANT INSERT, DELETE, SELECT, UPDATE ON ALL TABLES IN SCHEMA results TO webapi_sa;


GRANT USAGE ON SCHEMA temp TO webapi_sa;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA temp TO webapi_sa;


-- viewing schema
SELECT * FROM information_schema.schemata;

