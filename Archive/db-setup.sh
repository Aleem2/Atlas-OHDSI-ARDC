-- Instructions are linked here. https://github.com/OHDSI/WebAPI/wiki/PostgreSQL-Installation-Guide
-- container related instructions https://hub.docker.com/_/postgres

--Creating Database Group Roles
--Group: ohdsi_admin
CREATE ROLE ohdsi_admin
  CREATEDB REPLICATION
   VALID UNTIL 'infinity';
COMMENT ON ROLE ohdsi_admin
  IS 'Administration group for OHDSI applications';

--Group: ohdsi_app
CREATE ROLE ohdsi_app
   VALID UNTIL 'infinity';
COMMENT ON ROLE ohdsi_app
  IS 'Application group for OHDSI applications';


--Creating Database Login Roles
CREATE ROLE ohdsi_admin_user LOGIN ENCRYPTED PASSWORD 'md5e00cf25ad42683b3df678c61f42c6bda'
   VALID UNTIL 'infinity';
GRANT ohdsi_admin TO ohdsi_admin_user;
COMMENT ON ROLE ohdsi_admin_user
  IS 'Admin user account for OHDSI applications';
ALTER ROLE ohdsi_admin_user WITH PASSWORD 'admin1';

--Note the password is hashed using md5 with format {password}{user} i.e. for the above example md5("admin1ohdsi_admin_user") == "8d34c863380040dd6e1795bd088ff4a9".


--
CREATE ROLE ohdsi_app_user LOGIN ENCRYPTED PASSWORD 'md5f92ea1839dc16d7396db358365da7066'
   VALID UNTIL 'infinity';
GRANT ohdsi_app TO ohdsi_app_user;
COMMENT ON ROLE ohdsi_app_user
  IS 'Application user account for OHDSI applications';
ALTER ROLE ohdsi_app_user WITH PASSWORD 'app1';

-- Note the password is app1

--Creating the OHDSI WebAPI database
CREATE DATABASE "OHDSI"
  WITH ENCODING='UTF8'
       OWNER=ohdsi_admin
       CONNECTION LIMIT=-1;
COMMENT ON DATABASE "OHDSI"
  IS 'OHDSI database';
GRANT ALL ON DATABASE "OHDSI" TO GROUP ohdsi_admin;
GRANT CONNECT, TEMPORARY ON DATABASE "OHDSI" TO GROUP ohdsi_app;

--Prepare Database Schema for WebAPI
CREATE SCHEMA webapi
       AUTHORIZATION ohdsi_admin;
COMMENT ON SCHEMA webapi
  IS 'Schema containing tables to support WebAPI functionality';
GRANT USAGE ON SCHEMA webapi TO PUBLIC;
GRANT ALL ON SCHEMA webapi TO GROUP ohdsi_admin;
GRANT USAGE ON SCHEMA webapi TO GROUP ohdsi_app;

--Tab: Default Privileges
ALTER DEFAULT PRIVILEGES IN SCHEMA webapi
    GRANT INSERT, SELECT, UPDATE, DELETE, REFERENCES, TRIGGER ON TABLES
    TO ohdsi_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA webapi
    GRANT SELECT, USAGE ON SEQUENCES
    TO ohdsi_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA webapi
    GRANT EXECUTE ON FUNCTIONS
    TO ohdsi_app;

ALTER DEFAULT PRIVILEGES IN SCHEMA webapi
    GRANT USAGE ON TYPES
    TO ohdsi_app;



--------------------------------------------------------------------------------------

--$ docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d postgres
-- translates to kubernetes as 
--kubectl -n ohdsi run postgres --image=postgres --env=POSTGRES_PASSWORD=admin1 -- postgres

--exec into postgresql container

--kubectl exec -it postgres -- psql -U postgres

-- to do mount a volume onto the container. Also to do it automatically configure the code on running kubernetes yaml. And getting password from a k8s secret into env variable. 

-- but first let me connect the ohdsi and database. 

-- testing the database for connectivity. 
 -- psql -U postgres -p 5432 -h postgres.ohdsi

 --62071

-- psql -U postgres -p 5432 -h 172.17.0.6


-- passwords (user = ohdsi_admin_user password = admin1, md5 e00cf25ad42683b3df678c61f42c6bda ); (user = )


