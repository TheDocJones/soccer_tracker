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
--
----------
--
CREATE SEQUENCE stadium_id_seq
  MINVALUE 1
  INCREMENT BY 1
  START WITH 1
  NOCACHE
;
--
----------
--
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
  (league_id         NUMBER                NOT NULL
  ,league_nm         VARCHAR2(128 CHAR)    NOT NULL
  ,CONSTRAINT league_pk PRIMARY KEY (league_id) USING INDEX
  ,CONSTRAINT league_nm_uk1 UNIQUE (league_nm) USING INDEX
  )
;
--
----------
--
CREATE TABLE stadiums
  (stadium_id        NUMBER                NOT NULL
  ,stadium_nm        VARCHAR2(128 CHAR)    NOT NULL
  ,capacity          NUMBER
  ,country_nm        VARCHAR2(128 CHAR)
  ,city_nm           VARCHAR2(128 CHAR)
  ,latitude          NUMBER
  ,longitude         NUMBER
  ,CONSTRAINT stadiums_pk PRIMARY KEY (stadium_id) USING INDEX
  ,CONSTRAINT stadium_nm_uk1 UNIQUE (stadium_nm, country_nm, city_nm) USING INDEX
  )
;
--
----------
--
CREATE TABLE teams
  (team_id           NUMBER                NOT NULL
  ,team_nm           VARCHAR2(128 CHAR)    NOT NULL
  ,stadium_id        NUMBER
  ,league_id         NUMBER
  ,CONSTRAINT teams_pk PRIMARY KEY (team_id) USING INDEX
  ,CONSTRAINT teams_league_fk FOREIGN KEY (league_id)
     REFERENCES leagues (league_id)
  ,CONSTRAINT teams_stadium_fk FOREIGN KEY (stadium_id)
 	  REFERENCES stadiums (stadium_id) ENABLE
  )
;
--
----------
--
CREATE TABLE matches
  (home_team_id      NUMBER                NOT NULL
  ,away_team_id      NUMBER                NOT NULL
  ,match_dt          DATE                  NOT NULL
  ,broadcast         VARCHAR2(128 CHAR)
  ,home_goals        NUMBER
  ,away_goals        NUMBER
  ,home_yellows      NUMBER
  ,away_yellows      NUMBER
  ,home_reds         NUMBER
  ,away_reds         NUMBER
  ,away_travel_dist  NUMBER
  ,CONSTRAINT matches_pk PRIMARY KEY (home_team_id, away_team_id, match_dt) USING INDEX
  ,CONSTRAINT matches_home_team_id_fk FOREIGN KEY (home_team_id)
     REFERENCES teams (team_id)
  ,CONSTRAINT matches_away_team_id_fk FOREIGN KEY (away_team_id)
     REFERENCES teams (team_id) ENABLE
  )
;
--
----------
--
CREATE TABLE xt_datafiles
  (file_permissions   VARCHAR2(15 BYTE)
  ,file_link_cnt      VARCHAR2(1 BYTE)
  ,file_owner         VARCHAR2(25 BYTE)
  ,file_group         VARCHAR2(25 BYTE)
  ,file_size          VARCHAR2(50 BYTE)
  ,file_date_mth      VARCHAR2(5 BYTE)
  ,file_date_day      VARCHAR2(5 BYTE)
  ,file_date_year     VARCHAR2(4 BYTE)
  ,file_date_time     VARCHAR2(8 BYTE)
  ,file_name          VARCHAR2(255 BYTE)
  )
  ORGANIZATION EXTERNAL 
    (TYPE ORACLE_LOADER
     DEFAULT DIRECTORY "SOCCER_DATA_DIR"
     ACCESS PARAMETERS
       (RECORDS DELIMITED BY NEWLINE
        NOBADFILE
        NOLOGFILE
        LOAD WHEN file_size != '<DIR>'
        PREPROCESSOR soccer_bin_dir: 'list_files.sh'
        FIELDS TERMINATED BY WHITESPACE
       )
     LOCATION ('sticky.txt')
    )
  REJECT LIMIT UNLIMITED
;
--
----------
--
CREATE TABLE xt_datafile_matches
  (home_team                    VARCHAR2(128 BYTE)
  ,away_team                    VARCHAR2(128 BYTE)
  ,match_date                   DATE
  ,broadcast_options            VARCHAR2(128 BYTE)
  ,home_goals                   NUMBER
  ,away_goals                   NUMBER
  ,home_yellows                 NUMBER
  ,home_reds                    NUMBER
  ,away_yellows                 NUMBER
  ,away_reds                    NUMBER
  )
  ORGANIZATION EXTERNAL 
  (TYPE ORACLE_LOADER
   DEFAULT DIRECTORY "SOCCER_DATA_DIR"
   ACCESS PARAMETERS
   (RECORDS DELIMITED BY NEWLINE
    NOBADFILE
    NOLOGFILE
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    (match_date DATE 'M/D/YY HH:MI AM')
   )
   LOCATION ('sticky.txt')
  )
  REJECT LIMIT UNLIMITED
;
--
----------
--
CREATE TABLE xt_initial_data_load
  (team               VARCHAR2(128 BYTE)
  ,league             VARCHAR2(128 BYTE)
  ,city               VARCHAR2(128 BYTE)
  ,country            VARCHAR2(128 BYTE)
  ,stadium            VARCHAR2(128 BYTE)
  ,capacity           NUMBER
  ,latitude           NUMBER
  ,longitude          NUMBER
  )
  ORGANIZATION EXTERNAL 
    (TYPE ORACLE_LOADER
     DEFAULT DIRECTORY "SOCCER_DATA_DIR"
     ACCESS PARAMETERS
       (RECORDS DELIMITED BY NEWLINE
        NOBADFILE
        NOLOGFILE
        FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
        )
     LOCATION ('initial_data_load--team-league-stadium.csv')
    )
  REJECT LIMIT UNLIMITED
;
--
----------
--
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
--
----------
--
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
--
----------
--
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
--  DDL for directories
--------------------------------------------------------
CREATE DIRECTORY soccer_data_dir AS '/mnt/point/soccer_tracker/data'
;
CREATE DIRECTORY soccer_bin_dir AS '/mnt/point/soccer_tracker/bin'
;
--------------------------------------------------------



--| ==================================================
--| Load initial data
--| ==================================================
CREATE OR REPLACE PROCEDURE initial_data_load AS
  v_team_id     teams.team_id%TYPE;
  v_league_id   leagues.league_id%TYPE;
  v_stadium_id  stadiums.stadium_id%TYPE;
  v_cnt         NUMBER;
  CURSOR c_data IS SELECT team ,league ,city ,country ,stadium
                         ,capacity ,latitude ,longitude
                     FROM xt_initial_data_load;
BEGIN
  FOR v_data IN c_data LOOP
  --|===================
  --| LEAGUE
  --|===================
    --| Check if League exists
    SELECT count(*)
      INTO v_cnt
      FROM leagues
      WHERE league_nm = v_data.league;
    --| If League does not exist, insert into LEAGUES table
    IF v_cnt = 0 THEN
      INSERT INTO leagues (league_nm)
        VALUES (v_data.league);
    END IF;
    SELECT league_id
      INTO v_league_id
      FROM leagues
      WHERE league_nm = v_data.league;
    --| Update LEAGUES information if necessary
  --|===================

  --|===================
  --| STADIUM
  --|===================
    --| Check if Stadium exists
    SELECT count(*)
      INTO v_cnt
      FROM stadiums
      WHERE stadium_nm = v_data.stadium;
    --| If Stadium does not exist, insert into STADIUMS table
    IF v_cnt = 0 THEN
      INSERT INTO stadiums (stadium_nm, capacity, country_nm, city_nm, latitude, longitude)
        VALUES (v_data.stadium, v_data.capacity, v_data.country, v_data.city, v_data.latitude, v_data.longitude);
    END IF;
    --| Update STADIUMS information if necessary (TO DO: add code to check specific columns)
    SELECT stadium_id
      INTO v_stadium_id
      FROM stadiums
      WHERE stadium_nm = v_data.stadium;
    UPDATE stadiums
      SET capacity = v_data.capacity
         ,country_nm = v_data.country
         ,city_nm = v_data.city
         ,latitude = v_data.latitude
         ,longitude = v_data.longitude
      WHERE stadium_id = v_stadium_id;
  --|===================

  --|===================
  --| TEAM
  --|===================
    --| Check if Team exists
    SELECT count(*)
      INTO v_cnt
      FROM teams
      WHERE team_nm = v_data.team;
    --| If Team does not exist, insert into TEAM table
    IF v_cnt = 0 THEN
      INSERT INTO teams (team_nm, stadium_id, league_id)
        VALUES (v_data.team, v_stadium_id, v_league_id);
    END IF;
  --| Update TEAMS information if necessary
    SELECT team_id
      INTO v_team_id
      FROM teams
      WHERE team_nm = v_data.team;
    UPDATE teams
      SET stadium_id = v_stadium_id
         ,league_id = v_league_id
      WHERE team_id = v_team_id;
  --|===================

  END LOOP;

  COMMIT;

END initial_data_load;
/
--| ==================================================


--| ==================================================
--| INSERTING INTO LEAGUES
--| ==================================================
ALTER TRIGGER leagues_trg1 DISABLE;
--| ----------
SET DEFINE OFF;
INSERT INTO leagues (leagues_id, league_nm) VALUES (1,'German Bundesliga');
INSERT INTO leagues (leagues_id, league_nm) VALUES (2,'Italian Serie A');
INSERT INTO leagues (leagues_id, league_nm) VALUES (3,'Czech First League');
INSERT INTO leagues (leagues_id, league_nm) VALUES (4,'English Premier League');
INSERT INTO leagues (leagues_id, league_nm) VALUES (5,'French Ligue 1');
INSERT INTO leagues (leagues_id, league_nm) VALUES (6,'Spanish La Liga');
INSERT INTO leagues (leagues_id, league_nm) VALUES (7,'EFL Championship');
INSERT INTO leagues (leagues_id, league_nm) VALUES (8,'Swiss Super League');
INSERT INTO leagues (leagues_id, league_nm) VALUES (9,'Scottish Premiership');
INSERT INTO leagues (leagues_id, league_nm) VALUES (10,'Belgian Pro League');
INSERT INTO leagues (leagues_id, league_nm) VALUES (11,'Austrian Bundesliga');
INSERT INTO leagues (leagues_id, league_nm) VALUES (12,'Ukrainian Premier League');
INSERT INTO leagues (leagues_id, league_nm) VALUES (13,'Dutch Eredivisie');
INSERT INTO leagues (leagues_id, league_nm) VALUES (14,'Croatian SuperSport HNL');
INSERT INTO leagues (leagues_id, league_nm) VALUES (15,'Serbian SuperLiga');
INSERT INTO leagues (leagues_id, league_nm) VALUES (16,'Portuguese Primeira Liga');
INSERT INTO leagues (leagues_id, league_nm) VALUES (17,'Slovak First Football League');
--| ----------
ALTER SEQUENCE league_id_seq RESTART START WITH 18;
--| ----------
ALTER TRIGGER leagues_trg1 ENABLE;
--| ==================================================


--| ==================================================
--| INSERTING INTO STADIUMS
--| ==================================================
ALTER TRIGGER stadiums_trg1 DISABLE;
--| ----------
SET DEFINE OFF;
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (1,'Voith-Arena',15000,'Germany','Heidenheim an der Brenz',48.668611,10.139444);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (2,'Stadion An der Alten Försterei',22012,'Germany','Berlin',52.457222,13.568056);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (3,'Mewa Arena',33305,'Germany','Mainz',49.984167,8.224167);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (4,'San Siro',80018,'Italy','Milan',45.478056,9.123889);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (5,'Stadio Brianteo',16917,'Italy','Monza',45.582778,9.308056);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (6,'Stadion Letná',18944,'Czechia','Prague',50.099722,14.415833);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (7,'Stadio Artemio Franchi',43147,'Italy','Florence',43.780833,11.282222);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (8,'Dean Court',11307,'England','Bournemouth',50.735278,-1.838333);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (9,'Stade de l''Abbé-Deschamps',21379,'France','Auxerre',47.786753,3.588664);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (10,'Stade Raymond Kopa',18752,'France','Angers',47.460458,-0.530741);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (11,'Emirates Stadium',60704,'England','London',51.556667,-0.106111);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (12,'Stade Louis II',18523,'Monaco','Fontvieille',43.7275,7.415556);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (13,'Stadio Olimpico',70634,'Italy','Rome',41.933889,12.454722);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (14,'Stade Geoffroy-Guichard',41965,'France','Saint-Étienne',45.460833,4.390278);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (15,'Villa Park',42918,'England','Birmingham',52.509167,-1.884722);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (16,'Stadio Atleti Azzurri d''Italia',24950,'Italy','Bergamo',45.708889,9.680833);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (17,'San Mamés Stadium (2013)',53289,'Spain','Bilbao',43.2643,-2.9504);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (18,'Metropolitano Stadium',70460,'Spain','Madrid',40.436111,-3.599444);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (19,'BayArena',30210,'Germany','Leverkusen',51.038333,7.002222);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (20,'Ewood Park',31367,'England','Blackburn',53.728611,-2.489167);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (21,'Stadio Renato Dall''Ara',38279,'Italy','Bologna',44.492222,11.309722);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (22,'Westfalenstadion',81365,'Germany','Dortmund',51.4925,7.451667);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (23,'Borussia-Park',54042,'Germany','Mönchengladbach',51.174722,6.385556);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (24,'Brentford Community Stadium',17250,'England','London',51.490833,-0.288611);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (25,'Falmer Stadium',31876,'England','Brighton and Hove',50.861944,-0.083333);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (26,'Ashton Gate (stadium)',27000,'England','Bristol',51.44,-2.620278);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (27,'Stadion Wankdorf',31120,'Switzerland','Bern',46.963056,7.464722);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (28,'Turf Moor',21944,'England','Burnley',53.789167,-2.230278);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (29,'El Sadar Stadium',23516,'Spain','Pamplona',42.796667,-1.636944);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (30,'Unipol Domus',16416,'Italy','Cagliari',39.2,9.1375);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (31,'Cardiff City Stadium',33280,'Wales','Cardiff',51.472781,-3.203061);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (32,'Estadio Municipal de Butarque',12450,'Spain','Leganés',40.3404,-3.7607);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (33,'Celtic Park',60411,'Scotland','Glasgow',55.849722,-4.205556);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (34,'Stamford Bridge',40173,'England','London',51.481667,-0.191111);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (35,'Jan Breydel Stadium',29042,'Belgium','Bruges',51.193333,3.180556);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (36,'Stadio Giuseppe Sinigaglia',13602,'Italy','Como',45.813889,9.072222);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (37,'Coventry Building Society Arena',32609,'England','Coventry',52.448056,-1.495556);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (38,'Selhurst Park',25194,'England','London',51.398333,-0.085556);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (39,'Mendizorrotza Stadium',19840,'Spain','Vitoria-Gasteiz',42.837111,-2.688044);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (40,'Pride Park Stadium',32956,'England','Derby',52.915,-1.447222);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (41,'Waldstadion (Frankfurt)',58000,'Germany','Frankfurt',50.068056,8.645806);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (42,'Stadio Carlo Castellani',16284,'Italy','Empoli',43.726389,10.955);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (43,'Goodison Park',39414,'England','Liverpool',53.438889,-2.966389);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (44,'Augsburg Arena',30660,'Germany','Augsburg',48.323056,10.886111);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (45,'Estadi Olímpic Lluís Companys',54367,'Spain','Barcelona',41.364722,2.155556);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (46,'Allianz Arena',75000,'Germany','Munich',48.218889,11.624722);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (47,'Stade de la Beaujoire',35322,'France','Nantes',47.256,-1.525);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (48,'Red Bull Arena (Salzburg)',30188,'Austria','Wals-Siezenheim',47.816389,12.998333);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (49,'Arena Lviv',34915,'Ukraine','Lviv',49.775278,24.027778);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (50,'Millerntor-Stadion',29546,'Germany','Hamburg',53.554583,9.967667);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (51,'De Kuip',47500,'Netherlands','Rotterdam',51.893889,4.523056);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (52,'Craven Cottage',26000,'England','London',51.475,-0.221667);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (53,'Stadio Luigi Ferraris',36599,'Italy','Genoa',44.416389,8.9525);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (54,'Estadio Coliseum',16500,'Spain','Getafe',40.325556,-3.714722);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (55,'Estadi Montilivi',14624,'Spain','Girona',41.961389,2.828611);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (56,'Stadion Maksimir',24851,'Croatia','Zagreb',45.818889,16.018056);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (57,'Stadio Marcantonio Bentegodi',39211,'Italy','Verona',45.435278,10.968611);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (58,'Holstein-Stadion',15034,'Germany','Kiel',54.349167,10.123611);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (59,'MKM Stadium',25586,'England','Kingston upon Hull',53.746111,-0.367778);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (60,'Portman Road',29813,'England','Ipswich',52.055,1.144722);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (61,'Juventus Stadium',41507,'Italy','Turin',45.109444,7.641111);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (62,'Stade Océane',25178,'France','Le Havre',49.498889,0.169722);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (63,'Elland Road',37608,'England','Leeds',53.777778,-1.572222);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (64,'King Power Stadium',32259,'England','Leicester',52.620278,-1.142222);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (65,'Stade Pierre-Mauroy',50186,'France','Lille',50.6119,3.1304);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (66,'Anfield',61276,'England','Liverpool',53.430833,-2.960833);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (67,'Kenilworth Road',12000,'England','Luton',51.884167,-0.431667);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (68,'City of Manchester Stadium',52900,'England','Manchester',53.483056,-2.200278);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (69,'Old Trafford',74197,'England','Manchester',53.463056,-2.291389);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (70,'Riverside Stadium',34742,'England','Middlesbrough',54.578333,-1.216944);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (71,'The Den',20146,'England','London',51.485833,-0.050833);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (72,'Stade de la Mosson',32900,'France','Montpellier',43.622222,3.811944);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (73,'St James'' Park',52258,'England','Newcastle upon Tyne',54.975556,-1.621667);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (74,'Carrow Road',27359,'England','Norwich',52.622222,1.309167);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (75,'City Ground',30404,'England','West Bridgford',52.94,-1.132778);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (76,'Allianz Riviera',35624,'France','Nice',43.705278,7.1925);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (77,'Stade Vélodrome',18523,'France','Marseille',43.269722,5.395833);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (78,'Parc Olympique Lyonnais',59186,'France','Lyon',45.765224,4.982131);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (79,'Kassam Stadium',12500,'England','Oxford',51.716389,-1.208056);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (80,'Parc des Princes',47926,'France','Paris',48.84145,2.25305);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (81,'Stadio Ennio Tardini',27906,'Italy','Parma',44.794917,10.338444);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (82,'Home Park',17900,'England','Plymouth',50.388056,-4.150833);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (83,'Fratton Park',20899,'England','Portsmouth',50.796389,-1.063889);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (84,'Deepdale',23408,'England','Preston',53.772222,-2.688056);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (85,'Philips Stadion',36500,'Netherlands','Eindhoven',51.441667,5.4675);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (86,'Loftus Road',18439,'England','London',51.509167,-0.232222);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (87,'Vallecas Stadium',14708,'Spain','Madrid',40.391944,-3.658889);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (88,'Red Bull Arena (Leipzig)',47069,'Germany','Leipzig',51.345833,12.348333);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (89,'Balaídos',24791,'Spain','Vigo',42.2118,-8.7397);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (90,'Stade Bollaert-Delelis',37705,'France','Lens',50.432778,2.815);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (91,'Stade de la Meinau',29230,'France','Strasbourg',48.56,7.755);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (92,'Stage Front Stadium',40000,'Spain','Cornellà and El Prat',41.347778,2.075556);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (93,'Estadi Mallorca Son Moix',23142,'Spain','Palma de Mallorca',39.59,2.63);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (94,'Estadio Benito Villamarín',60720,'Spain','Seville',37.356389,-5.981389);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (95,'Santiago Bernabéu Stadium',83186,'Spain','Madrid',40.453056,-3.688333);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (96,'Anoeta Stadium',39500,'Spain','San Sebastián',43.301389,-1.973611);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (97,'Estadio José Zorrilla',27618,'Spain','Valladolid',41.644444,-4.761111);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (98,'Red Star Stadium',53000,'Serbia','Belgrade',44.783333,20.464722);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (99,'Estádio da Luz',64642,'Portugal','Lisbon',38.7527,-9.1847);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (100,'Europa-Park Stadion',34700,'Germany','Freiburg im Breisgau',48.0216,7.8297);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (101,'Ramón Sánchez Pizjuán Stadium',42714,'Spain','Seville',37.384,-5.9705);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (102,'Bramall Lane',32050,'England','Sheffield',53.370278,-1.470833);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (103,'Hillsborough Stadium',39732,'England','Sheffield',53.411389,-1.500556);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (104,'Tehelné pole',22500,'Slovakia','Bratislava',48.1636,17.1369);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (105,'Liebenauer Stadium',16364,'Austria','Graz',47.046111,15.454444);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (106,'St Mary''s Stadium',32384,'England','Southampton',50.905833,-1.391111);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (107,'Estádio José Alvalade',50095,'Portugal','Lisbon',38.761111,-9.160833);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (108,'Stadio Diego Armando Maradona',54726,'Italy','Naples',40.828,14.193);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (109,'Stade Francis-Le Blé',15931,'France','Brest',48.402932,-4.461694);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (110,'Stade Auguste-Delaune',21684,'France','Reims',49.246667,4.025);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (111,'Roazhon Park',29778,'France','Rennes',48.1075,-1.712778);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (112,'Bet365 Stadium',30089,'England','Stoke-on-Trent',52.988333,-2.175556);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (113,'Stadium of Light',49000,'England','Sunderland',54.914444,-1.388333);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (114,'Weserstadion',42100,'Germany','Bremen',53.066389,8.8375);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (115,'Swansea.com Stadium',21088,'Wales','Swansea',51.6422,-3.9351);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (116,'Stadio Olimpico Grande Torino',27958,'Italy','Turin',45.041667,7.65);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (117,'Tottenham Hotspur Stadium',62850,'England','London',51.604444,-0.066389);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (118,'Stadium de Toulouse',33150,'France','Toulouse',43.583056,1.434167);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (119,'Rhein-Neckar-Arena',30150,'Germany','Sinsheim',49.238056,8.8875);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (120,'Estadio Gran Canaria',32400,'Spain','Las Palmas',28.100278,-15.456667);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (121,'Stadio Friuli',25144,'Italy','Udine',46.0816,13.2001);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (122,'Stadio Via del mare',31533,'Italy','Lecce',40.365278,18.208889);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (123,'Mestalla Stadium',49430,'Spain','Valencia',39.474722,-0.358333);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (124,'Stadio Pier Luigi Penzo',11150,'Italy','Venice',45.427761,12.363731);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (125,'MHPArena',60058,'Germany','Stuttgart',48.792222,9.231944);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (126,'Ruhrstadion',26000,'Germany','Bochum',51.49,7.236667);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (127,'Volkswagen Arena',28917,'Germany','Wolfsburg',52.432778,10.803889);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (128,'Estadio de la Cerámica',23000,'Spain','Villarreal',39.944167,-0.103611);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (129,'Vicarage Road',22200,'England','Watford',51.649722,-0.401389);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (130,'The Hawthorns',26850,'England','West Bromwich',52.509167,-1.963889);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (131,'London Stadium',62500,'England','London',51.538611,-0.016389);
INSERT INTO stadiums (stadium_id, stadium_nm, capacity, country_nm, city_nm, latitude, longitude) VALUES (132,'Molineux Stadium',31750,'England','Wolverhampton',52.590278,-2.130278);
--| ----------
ALTER SEQUENCE stadium_id_seq RESTART START WITH 133;
--| ----------
ALTER TRIGGER stadiums_trg1 ENABLE;
--| ==================================================


--| ==================================================
--| INSERTING INTO TEAMS
--| ==================================================
ALTER TRIGGER teams_trg1 DISABLE;
--| ----------
REM INSERTING into SOCCER_OWNER.TEAMS
SET DEFINE OFF;
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (1,'1. FC Heidenheim',1,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (2,'1. FC Union Berlin',2,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (3,'1. FSV Mainz 05',3,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (4,'AC Milan',4,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (5,'AC Monza',5,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (6,'AC Sparta Prague',6,3);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (7,'ACF Fiorentina',7,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (8,'AFC Bournemouth',8,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (9,'AJ Auxerre',9,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (10,'Angers SCO',10,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (11,'Arsenal F.C.',11,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (12,'AS Monaco FC',12,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (13,'AS Roma',13,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (14,'AS Saint-Étienne',14,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (15,'Aston Villa F.C.',15,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (16,'Atalanta BC',16,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (17,'Athletic Bilbao',17,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (18,'Atlético Madrid',18,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (19,'Bayer 04 Leverkusen',19,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (20,'Blackburn Rovers F.C.',20,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (21,'Bologna FC 1909',21,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (22,'Borussia Dortmund',22,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (23,'Borussia Mönchengladbach',23,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (24,'Brentford F.C.',24,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (25,'Brighton & Hove Albion F.C.',25,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (26,'Bristol City F.C.',26,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (27,'BSC Young Boys',27,8);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (28,'Burnley F.C.',28,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (29,'CA Osasuna',29,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (30,'Cagliari Calcio',30,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (31,'Cardiff City F.C.',31,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (32,'CD Leganés',32,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (33,'Celtic F.C.',33,9);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (34,'Chelsea F.C.',34,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (35,'Club Brugge KV',35,10);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (36,'Como 1907',36,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (37,'Coventry City F.C.',37,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (38,'Crystal Palace F.C.',38,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (39,'Deportivo Alavés',39,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (40,'Derby County F.C.',40,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (41,'Eintracht Frankfurt',41,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (42,'Empoli FC',42,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (43,'Everton F.C.',43,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (44,'FC Augsburg',44,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (45,'FC Barcelona',45,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (46,'FC Bayern Munich',46,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (47,'FC Nantes',47,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (48,'FC Red Bull Salzburg',48,11);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (49,'FC Shakhtar Donetsk',49,12);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (50,'FC St. Pauli',50,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (51,'Feyenoord',51,13);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (52,'Fulham F.C.',52,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (53,'Genoa CFC',53,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (54,'Getafe CF',54,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (55,'Girona FC',55,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (56,'GNK Dinamo Zagreb',56,14);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (57,'Hellas Verona FC',57,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (58,'Holstein Kiel',58,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (59,'Hull City A.F.C.',59,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (60,'Inter Milan',4,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (61,'Ipswich Town F.C.',60,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (62,'Juventus FC',61,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (63,'Le Havre AC',62,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (64,'Leeds United F.C.',63,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (65,'Leicester City F.C.',64,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (66,'Lille OSC',65,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (67,'Liverpool F.C.',66,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (68,'Luton Town F.C.',67,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (69,'Manchester City F.C.',68,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (70,'Manchester United F.C.',69,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (71,'Middlesbrough F.C.',70,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (72,'Millwall F.C.',71,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (73,'Montpellier HSC',72,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (74,'Newcastle United F.C.',73,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (75,'Norwich City F.C.',74,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (76,'Nottingham Forest F.C.',75,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (77,'OGC Nice',76,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (78,'Olympique de Marseille',77,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (79,'Olympique Lyonnais',78,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (80,'Oxford United F.C.',79,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (81,'Paris Saint-Germain F.C.',80,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (82,'Parma Calcio 1913',81,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (83,'Plymouth Argyle F.C.',82,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (84,'Portsmouth F.C.',83,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (85,'Preston North End F.C.',84,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (86,'PSV Eindhoven',85,13);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (87,'Queens Park Rangers F.C.',86,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (88,'Rayo Vallecano',87,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (89,'RB Leipzig',88,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (90,'RC Celta de Vigo',89,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (91,'RC Lens',90,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (92,'RC Strasbourg Alsace',91,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (93,'RCD Espanyol',92,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (94,'RCD Mallorca',93,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (95,'Real Betis',94,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (96,'Real Madrid CF',95,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (97,'Real Sociedad',96,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (98,'Real Valladolid',97,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (99,'Red Star Belgrade',98,15);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (100,'S.L. Benfica',99,16);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (101,'SC Freiburg',100,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (102,'Sevilla FC',101,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (103,'Sheffield United F.C.',102,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (104,'Sheffield Wednesday F.C.',103,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (105,'ŠK Slovan Bratislava',104,17);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (106,'SK Sturm Graz',105,11);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (107,'Southampton F.C.',106,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (108,'Sporting CP',107,16);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (109,'SS Lazio',13,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (110,'SSC Napoli',108,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (111,'Stade Brestois 29',109,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (112,'Stade de Reims',110,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (113,'Stade Rennais F.C.',111,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (114,'Stoke City F.C.',112,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (115,'Sunderland A.F.C.',113,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (116,'SV Werder Bremen',114,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (117,'Swansea City A.F.C.',115,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (118,'Torino FC',116,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (119,'Tottenham Hotspur F.C.',117,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (120,'Toulouse FC',118,5);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (121,'TSG 1899 Hoffenheim',119,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (122,'UD Las Palmas',120,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (123,'Udinese Calcio',121,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (124,'US Lecce',122,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (125,'Valencia CF',123,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (126,'Venezia FC',124,2);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (127,'VfB Stuttgart',125,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (128,'VfL Bochum',126,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (129,'VfL Wolfsburg',127,1);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (130,'Villarreal CF',128,6);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (131,'Watford F.C.',129,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (132,'West Bromwich Albion F.C.',130,7);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (133,'West Ham United F.C.',131,4);
INSERT INTO teams (team_id, team_nm, stadium_id, league_id) VALUES (134,'Wolverhampton Wanderers F.C.',132,4);
--| ----------
ALTER SEQUENCE team_id_seq RESTART START WITH 135;
--| ----------
ALTER TRIGGER teams_trg1 ENABLE;
--| ==================================================


