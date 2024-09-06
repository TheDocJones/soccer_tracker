--| ==================================================
--| Create initial database objects
--| ==================================================


--------------------------------------------------------
--  DDL for Sequences
--------------------------------------------------------
CREATE SEQUENCE league_id_seq
  MINVALUE 1
  INCREMENT BY 1
  START WITH 1
  NOCACHE
;
CREATE SEQUENCE stadium_id_seq
  MINVALUE 1
  INCREMENT BY 1
  START WITH 1
  NOCACHE
;
CREATE SEQUENCE team_id_seq
  MINVALUE 1
  INCREMENT BY 1
  START WITH 1
  NOCACHE
;
--------------------------------------------------------



--------------------------------------------------------
--  DDL for Tables
--------------------------------------------------------
CREATE TABLE leagues
  (league_id         NUMBER
  ,league_nm         VARCHAR2(128 CHAR)
  )
;
CREATE TABLE matches
  (home_team_id      NUMBER
  ,away_team_id      NUMBER
  ,match_dt          DATE
  ,broadcast         VARCHAR2(128 CHAR)
  ,home_goals        NUMBER
  ,away_goals        NUMBER
  ,home_yellows      NUMBER
  ,away_yellows      NUMBER
  ,home_reds         NUMBER
  ,away_reds         NUMBER
  ,away_travel_dist  NUMBER
  )
;
CREATE TABLE stadiums
  (stadium_id        NUMBER
  ,stadium_nm        VARCHAR2(128 CHAR)
  ,capacity          NUMBER
  ,country_nm        VARCHAR2(128 CHAR)
  ,city_nm           VARCHAR2(128 CHAR)
  ,latitude          NUMBER
  ,longitude         NUMBER
  )
;
CREATE TABLE teams
  (team_id           NUMBER
  ,team_nm           VARCHAR2(128 CHAR)
  ,stadium_id        NUMBER
  ,league_id         NUMBER
  )
;
--------------------------------------------------------



--------------------------------------------------------
--  DDL for Indexes
--------------------------------------------------------
CREATE UNIQUE INDEX LEAGUE_NM_UK1 ON LEAGUES (LEAGUE_NM)
  ;
CREATE UNIQUE INDEX LEAGUE_PK ON LEAGUES (LEAGUE_ID)
  ;
CREATE UNIQUE INDEX MATCHES_PK ON MATCHES (HOME_TEAM_ID, AWAY_TEAM_ID, MATCH_DT)
  ;
CREATE UNIQUE INDEX STADIUMS_PK ON STADIUMS (STADIUM_ID)
  ;
CREATE UNIQUE INDEX STADIUM_NM_UK1 ON STADIUMS (STADIUM_NM, COUNTRY_NM, CITY_NM)
  ;
CREATE UNIQUE INDEX TEAMS_PK ON TEAMS (TEAM_ID)
  ;
CREATE UNIQUE INDEX LEAGUE_PK ON LEAGUES (LEAGUE_ID)
  ;
CREATE UNIQUE INDEX LEAGUE_NM_UK1 ON LEAGUES (LEAGUE_NM)
  ;
CREATE UNIQUE INDEX MATCHES_PK ON MATCHES (HOME_TEAM_ID, AWAY_TEAM_ID, MATCH_DT)
  ;
CREATE UNIQUE INDEX STADIUMS_PK ON STADIUMS (STADIUM_ID)
  ;
CREATE UNIQUE INDEX STADIUM_NM_UK1 ON STADIUMS (STADIUM_NM, COUNTRY_NM, CITY_NM)
  ;
CREATE UNIQUE INDEX TEAMS_PK ON TEAMS (TEAM_ID)
  ;
--------------------------------------------------------



--------------------------------------------------------
--  DDL for Triggers
--------------------------------------------------------
CREATE OR REPLACE EDITIONABLE TRIGGER LEAGUES_TRG1
  BEFORE INSERT
    ON leagues
    FOR EACH ROW
DECLARE
  v_id   leagues.league_id%TYPE;
BEGIN
  SELECT league_id_seq.NEXTVAL
    INTO v_id
    FROM dual;
  :new.league_id := v_id;
END;
/
ALTER TRIGGER LEAGUES_TRG1 ENABLE
;
CREATE OR REPLACE EDITIONABLE TRIGGER STADIUMS_TRG1
  BEFORE INSERT
    ON stadiums
    FOR EACH ROW
DECLARE
  v_id   stadiums.stadium_id%TYPE;
BEGIN
  SELECT stadium_id_seq.NEXTVAL
    INTO v_id
    FROM dual;
  :new.stadium_id := v_id;
END;
/
ALTER TRIGGER STADIUMS_TRG1 ENABLE
;
CREATE OR REPLACE EDITIONABLE TRIGGER TEAMS_TRG1
  BEFORE INSERT
    ON teams
    FOR EACH ROW
DECLARE
  v_id   teams.team_id%TYPE;
BEGIN
  SELECT team_id_seq.NEXTVAL
    INTO v_id
    FROM dual;
  :new.team_id := v_id;
END;
/
ALTER TRIGGER TEAMS_TRG1 ENABLE
;
--------------------------------------------------------



--------------------------------------------------------
--  Constraints
--------------------------------------------------------
ALTER TABLE LEAGUES MODIFY (LEAGUE_ID NOT NULL ENABLE)
;
ALTER TABLE LEAGUES MODIFY (LEAGUE_NM NOT NULL ENABLE)
;
ALTER TABLE LEAGUES ADD CONSTRAINT LEAGUE_PK PRIMARY KEY (LEAGUE_ID)
  USING INDEX  ENABLE
;
ALTER TABLE LEAGUES ADD CONSTRAINT LEAGUE_NM_UK1 UNIQUE (LEAGUE_NM)
  USING INDEX  ENABLE
;
ALTER TABLE MATCHES MODIFY (HOME_TEAM_ID NOT NULL ENABLE)
;
ALTER TABLE MATCHES MODIFY (AWAY_TEAM_ID NOT NULL ENABLE)
;
ALTER TABLE MATCHES MODIFY (MATCH_DT NOT NULL ENABLE)
;
ALTER TABLE MATCHES ADD CONSTRAINT MATCHES_PK PRIMARY KEY (HOME_TEAM_ID, AWAY_TEAM_ID, MATCH_DT)
  USING INDEX  ENABLE
;
ALTER TABLE STADIUMS MODIFY (STADIUM_ID NOT NULL ENABLE)
;
ALTER TABLE STADIUMS MODIFY (STADIUM_NM NOT NULL ENABLE)
;
ALTER TABLE STADIUMS ADD CONSTRAINT STADIUMS_PK PRIMARY KEY (STADIUM_ID)
  USING INDEX  ENABLE
;
ALTER TABLE STADIUMS ADD CONSTRAINT STADIUM_NM_UK1 UNIQUE (STADIUM_NM, COUNTRY_NM, CITY_NM)
  USING INDEX  ENABLE
;
ALTER TABLE TEAMS MODIFY (TEAM_ID NOT NULL ENABLE)
;
ALTER TABLE TEAMS MODIFY (TEAM_NM NOT NULL ENABLE)
;
ALTER TABLE TEAMS ADD CONSTRAINT TEAMS_PK PRIMARY KEY (TEAM_ID)
  USING INDEX  ENABLE
;
ALTER TABLE MATCHES ADD CONSTRAINT MATCHES_HOME_TEAM_ID_FK FOREIGN KEY (HOME_TEAM_ID)
  REFERENCES TEAMS (TEAM_ID) ENABLE
;
ALTER TABLE MATCHES ADD CONSTRAINT MATCHES_AWAY_TEAM_ID_FK FOREIGN KEY (AWAY_TEAM_ID)
  REFERENCES TEAMS (TEAM_ID) ENABLE
;
ALTER TABLE TEAMS ADD CONSTRAINT TEAMS_LEAGUE_FK FOREIGN KEY (LEAGUE_ID)
  REFERENCES LEAGUES (LEAGUE_ID) ENABLE
;
  ALTER TABLE TEAMS ADD CONSTRAINT TEAMS_STADIUM_FK FOREIGN KEY (STADIUM_ID)
	  REFERENCES STADIUMS (STADIUM_ID) ENABLE
;
--------------------------------------------------------


--------------------------------------------------------
--  DDL for directories
--------------------------------------------------------
CREATE DIRECTORY soccer_data_dir AS '/mnt/point/soccer_tracker/data'
;
GRANT READ,WRITE ON DIRECTORY soccer_data_dir TO soccer_owner
;
CREATE DIRECTORY soccer_bin_dir AS '/mnt/point/soccer_tracker/bin'
;
GRANT READ,WRITE,EXECUTE ON DIRECTORY soccer_bin_dir TO soccer_owner
;
--------------------------------------------------------
