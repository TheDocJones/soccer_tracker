# ##################################################
# Initial install steps
# ##################################################

1. Create account in Oracle Cloud
2. Create database in Oracle Cloud
3. Create database schema owner (ex: soccer_owner)
4. Create database user for read only access (ex: soccer_web)
5. Create database user for administrative access (ex: soccer_admin)
6. Use create_soccer_db.sql to create database objects
   -- Tables
   -- Sequences
   -- Triggers
   -- Directory
7. Use load_soccer_db.sql to load initial dataset
8. Create web server in Oracle Cloud
9. Setup DNS entry



# ##################################################
# Thoughts ...
# ##################################################

1. Allow for other databases:  MySQL, SQL Server, MariaDB, Postgres
2. Allow for other web servers: nginx, IIS
3. Setup TLS




# ##################################################
# Local DB User creation
# ##################################################
CREATE TABLESPACE soccer_tracker_data
  DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/soccer_tracker_data01.dbf'
    SIZE 1G
    AUTOEXTEND ON
      NEXT 512M
      MAXSIZE 2G
  EXTENT MANAGEMENT LOCAL
    UNIFORM SIZE 128K DEFAULT
  NOCOMPRESS
  SEGMENT SPACE MANAGEMENT AUTO
;
CREATE TABLESPACE soccer_tracker_index
  DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/soccer_tracker_index01.dbf'
    SIZE 256M
    AUTOEXTEND ON
      NEXT 256M
      MAXSIZE 1G
  EXTENT MANAGEMENT LOCAL
    UNIFORM SIZE 128K DEFAULT
  NOCOMPRESS
  SEGMENT SPACE MANAGEMENT AUTO
;
CREATE USER soccer_owner
  IDENTIFIED BY soccer_owner
  DEFAULT TABLESPACE soccer_tracker_data
  TEMPORARY TABLESPACE temp
;
ALTER USER soccer_owner
  QUOTA UNLIMITED ON soccer_tracker_data
;
ALTER USER soccer_owner
  QUOTA UNLIMITED ON soccer_tracker_index
;
