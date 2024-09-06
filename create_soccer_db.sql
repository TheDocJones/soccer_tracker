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
CREATE UNIQUE INDEX league_nm_uk1 ON leagues (league_nm)
  ;
CREATE UNIQUE INDEX league_pk ON leagues (league_id)
  ;
CREATE UNIQUE INDEX matches_pk ON matches (home_team_id, away_team_id, match_dt)
  ;
CREATE UNIQUE INDEX stadiums_pk ON stadiums (stadium_id)
  ;
CREATE UNIQUE INDEX stadium_nm_uk1 ON stadiums (stadium_nm, country_nm, city_nm)
  ;
CREATE UNIQUE INDEX teams_pk ON teams (team_id)
  ;
--------------------------------------------------------



--------------------------------------------------------
--  DDL for Triggers
--------------------------------------------------------
CREATE OR REPLACE TRIGGER leagues_trg1
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
ALTER TRIGGER leagues_trg1 ENABLE
;
CREATE OR REPLACE TRIGGER stadiums_trg1
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
ALTER TRIGGER stadiums_trg1 ENABLE
;
CREATE OR REPLACE TRIGGER teams_trg1
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
ALTER TRIGGER teams_trg1 ENABLE
;
--------------------------------------------------------



--------------------------------------------------------
--  Constraints
--------------------------------------------------------
ALTER TABLE leagues MODIFY (league_id NOT NULL ENABLE)
;
ALTER TABLE leagues MODIFY (league_nm NOT NULL ENABLE)
;
ALTER TABLE leagues ADD CONSTRAINT league_pk PRIMARY KEY (league_id)
  USING INDEX  ENABLE
;
ALTER TABLE leagues ADD CONSTRAINT league_nm_uk1 UNIQUE (league_nm)
  USING INDEX  ENABLE
;
ALTER TABLE matches MODIFY (home_team_id NOT NULL ENABLE)
;
ALTER TABLE matches MODIFY (away_team_id NOT NULL ENABLE)
;
ALTER TABLE matches MODIFY (match_dt NOT NULL ENABLE)
;
ALTER TABLE matches ADD CONSTRAINT matches_pk PRIMARY KEY (home_team_id, away_team_id, match_dt)
  USING INDEX  ENABLE
;
ALTER TABLE stadiums MODIFY (stadium_id NOT NULL ENABLE)
;
ALTER TABLE stadiums MODIFY (stadium_nm NOT NULL ENABLE)
;
ALTER TABLE stadiums ADD CONSTRAINT stadiums_pk PRIMARY KEY (stadium_id)
  USING INDEX  ENABLE
;
ALTER TABLE stadiums ADD CONSTRAINT stadium_nm_uk1 UNIQUE (stadium_nm, country_nm, city_nm)
  USING INDEX  ENABLE
;
ALTER TABLE teams MODIFY (team_id NOT NULL ENABLE)
;
ALTER TABLE teams MODIFY (team_nm NOT NULL ENABLE)
;
ALTER TABLE teams ADD CONSTRAINT teams_pk PRIMARY KEY (team_id)
  USING INDEX  ENABLE
;
ALTER TABLE matches ADD CONSTRAINT matches_home_team_id_fk FOREIGN KEY (home_team_id)
  REFERENCES teams (team_id) ENABLE
;
ALTER TABLE matches ADD CONSTRAINT matches_away_team_id_fk FOREIGN KEY (away_team_id)
  REFERENCES teams (team_id) ENABLE
;
ALTER TABLE teams ADD CONSTRAINT teams_league_fk FOREIGN KEY (league_id)
  REFERENCES leagues (league_id) ENABLE
;
  ALTER TABLE teams ADD CONSTRAINT teams_stadium_fk FOREIGN KEY (stadium_id)
	  REFERENCES stadiums (stadium_id) ENABLE
;
--------------------------------------------------------


--------------------------------------------------------
--  DDL for directories
--------------------------------------------------------
CREATE DIRECTORY soccer_data_dir AS '/mnt/point/soccer_tracker/data'
;
CREATE DIRECTORY soccer_bin_dir AS '/mnt/point/soccer_tracker/bin'
;
--------------------------------------------------------
