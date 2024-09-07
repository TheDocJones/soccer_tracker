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

--| ==================================================
--| INSERTING INTO LEAGUES
--| ==================================================
ALTER TRIGGER leagues_trg1 DISABLE;
--| ----------
SET DEFINE OFF;
INSERT INTO leagues (league_id,league_nm) VALUES ( 1,'Austrian Bundesliga');
INSERT INTO leagues (league_id,league_nm) VALUES ( 2,'Belgian Pro League');
INSERT INTO leagues (league_id,league_nm) VALUES ( 3,'Croatian SuperSport HNL');
INSERT INTO leagues (league_id,league_nm) VALUES ( 4,'Czech First League');
INSERT INTO leagues (league_id,league_nm) VALUES ( 5,'Dutch Eredivisie');
INSERT INTO leagues (league_id,league_nm) VALUES ( 6,'EFL Championship');
INSERT INTO leagues (league_id,league_nm) VALUES ( 7,'English Premier League');
INSERT INTO leagues (league_id,league_nm) VALUES ( 8,'French Ligue 1');
INSERT INTO leagues (league_id,league_nm) VALUES ( 9,'German Bundesliga');
INSERT INTO leagues (league_id,league_nm) VALUES (10,'Italian Serie A');
INSERT INTO leagues (league_id,league_nm) VALUES (11,'Portuguese Primeira Liga');
INSERT INTO leagues (league_id,league_nm) VALUES (12,'Scottish Premiership');
INSERT INTO leagues (league_id,league_nm) VALUES (13,'Serbian SuperLiga');
INSERT INTO leagues (league_id,league_nm) VALUES (14,'Slovak First Football League');
INSERT INTO leagues (league_id,league_nm) VALUES (15,'Spanish La Liga');
INSERT INTO leagues (league_id,league_nm) VALUES (16,'Swiss Super League');
INSERT INTO leagues (league_id,league_nm) VALUES (17,'Ukrainian Premier League');
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
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (  1,'Voith-Arena',15000,'Germany','Heidenheim',48.668611,10.139444);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (  2,'Stadion An der Alten Forsterei',22012,'Germany','Berlin',52.457222,13.568056);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (  3,'Giuseppe Meazza',80018,'Italy','Milan',45.478056,9.123889);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (  4,'epet ARENA',18944,'Czechia','Prague',50.099722,14.415833);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (  5,'Dean Court',11307,'England','Bournemouth',50.735278,-1.838333);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (  6,'Stade de I''Abbe-Deschamps',21379,'France','Auxerre',47.786753,3.588664);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (  7,'Mendizorrotza',19840,'Spain','Vitoria-Gasteiz',42.837111,-2.688044);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (  8,'Stade Raymond Kopa',18752,'France','Angers',47.460458,-0.530741);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (  9,'Emirates Stadium',60704,'England','London',51.556667,-0.106111);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 10,'Stade Louis II',18523,'Monaco','Fontvieille',43.7275,7.415556);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 11,'Stadio Olimpico',70634,'Italy','Rome',41.933889,12.454722);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 12,'Villa Park',42918,'England','Birmingham',52.509167,-1.884722);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 13,'Gewiss Stadium',24950,'Italy','Bergamo',45.708889,9.680833);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 14,'San Mames',53289,'Spain','Bilbao',43.2643,-2.9504);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 15,'Metropolitano Stadium',70460,'Spain','Madrid',40.436111,-3.599444);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 16,'Estadi Olimpic Lluis Companys',54367,'Spain','Barcelona',41.364722,2.155556);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 17,'BayArena',30210,'Germany','Leverkusen',51.038333,7.002222);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 18,'Allianz Arena',75000,'Germany','Munich',48.218889,11.624722);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 19,'Ewood Park',31367,'England','Blackburn',53.728611,-2.489167);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 20,'Stadio Renato Dall''Ara',38279,'Italy','Bologna',44.492222,11.309722);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 21,'Signal Iduna Park',81365,'Germany','Dortmund',51.4925,7.451667);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 22,'Borussia-Park',54042,'Germany','Monchengladbach',51.174722,6.385556);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 23,'Brentford Community Stadium',17250,'England','London',51.490833,-0.288611);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 24,'Stade Francis-Le Ble',15931,'France','Brest',48.402932,-4.461694);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 25,'Falmer Stadium',31876,'England','Falmer',50.861944,-0.083333);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 26,'Ashton Gate Stadium',27000,'England','Bristol',51.44,-2.620278);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 27,'Stadion Wankdorf',31120,'Switzerland','Bern',46.963056,7.464722);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 28,'Turf Moor',21944,'England','Burnley',53.789167,-2.230278);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 29,'Sardegna Arena',16416,'Italy','Cagliari',39.2,9.1375);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 30,'Cardiff City Stadium',33280,'Wales','Cardiff',51.472781,-3.203061);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 31,'Balaidos',24791,'Spain','Vigo',42.2118,-8.7397);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 32,'Celtic Park',60411,'Scotland','Glasgow',55.849722,-4.205556);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 33,'Stamford Bridge',40173,'England','London',51.481667,-0.191111);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 34,'Jan Breydel Stadium',29042,'Belgium','Bruges',51.193333,3.180556);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 35,'Stadio Giuseppe Sinigaglia',13602,'Italy','Como',45.813889,9.072222);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 36,'Coventry Building Society Arena',32609,'England','Coventry',52.448056,-1.495556);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 37,'Selhurst Park',25194,'England','London',51.398333,-0.085556);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 38,'Pride Park Stadium',32956,'England','Derby',52.915,-1.447222);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 39,'Deutsche Bank Park',58000,'Germany','Frankfurt',50.068056,8.645806);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 40,'Stadio Carlo Castellani',16284,'Italy','Empoli',43.726389,10.955);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 41,'Stage Front Stadium',40000,'Spain','Cornella de Llobregat',41.347778,2.075556);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 42,'Goodison Park',39414,'England','Liverpool',53.438889,-2.966389);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 43,'WWK Arena',30660,'Germany','Augsburg',48.323056,10.886111);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 44,'Red Bull Arena',30188,'Austria','Wals-Siezenheim',47.816389,12.998333);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 45,'Arena Livyi Bereh',4700,'Ukraine','Zolochivska',50.324433,30.649909);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 46,'De Kuip',47500,'Netherlands','Rotterdam',51.893889,4.523056);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 47,'Stadio Artemio Franchi',43147,'Italy','Florence',43.780833,11.282222);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 48,'Craven Cottage',26000,'England','London',51.475,-0.221667);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 49,'Stadio Luigi Ferraris',36599,'Italy','Genoa',44.416389,8.9525);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 50,'Estadio Coliseum',16500,'Spain','Getafe',40.325556,-3.714722);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 51,'Estadi Montilivi',14624,'Spain','Girona',41.961389,2.828611);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 52,'Maksimir',24851,'Croatia','Zagreb',45.818889,16.018056);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 53,'Marcantonio Bentegodi',39211,'Italy','Verona',45.435278,10.968611);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 54,'Holstein-Stadion',15034,'Germany','Kiel',54.349167,10.123611);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 55,'MKM Stadium',25586,'England','Kingston upon Hull',53.746111,-0.367778);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 56,'Portman Road',29813,'England','Ipswich',52.055,1.144722);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 57,'Allianz Stadium',41507,'Italy','Turin',45.109444,7.641111);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 58,'Estadio Gran Canaria',32400,'Spain','Las Palmas',28.100278,-15.456667);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 59,'Stade Oceane',25178,'France','Le Havre',49.498889,0.169722);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 60,'Stadio Ettore Giardiniero - Via del Mare',31533,'Italy','Lecce',40.365278,18.208889);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 61,'Elland Road',37608,'England','Leeds',53.777778,-1.572222);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 62,'Estadio Municipal Butarque',12450,'Spain','Leganes',40.3404,-3.7607);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 63,'King Power Stadium',32259,'England','Leicester',52.620278,-1.142222);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 64,'Stade Bollaert-Delelis',37705,'France','Lens',50.432778,2.815);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 65,'Decathlon Arena Pierre Mauroy Stadium',50186,'France','Lille',50.6119,3.1304);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 66,'Anfield',61276,'England','Liverpool',53.430833,-2.960833);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 67,'Kenilworth Road',12000,'England','Luton',51.884167,-0.431667);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 68,'Groupama Stadium',59186,'France','Lyon',45.765224,4.982131);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 69,'Mewa Arena',33305,'Germany','Mainz',49.984167,8.224167);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 70,'Estadi Mallorca Son Moix',23142,'Spain','Palma',39.59,2.63);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 71,'City of Manchester Stadium',52900,'England','Manchester',53.483056,-2.200278);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 72,'Old Trafford',74197,'England','Manchester',53.463056,-2.291389);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 73,'Orange Velodrome',18523,'France','Marseille',43.269722,5.395833);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 74,'Riverside Stadium',34742,'England','Middlesbrough',54.578333,-1.216944);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 75,'The Den',20146,'England','London',51.485833,-0.050833);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 76,'Stade de la Mosson',32900,'France','Montpellier',43.622222,3.811944);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 77,'Stadio Brianteo',16917,'Italy','Monza',45.582778,9.308056);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 78,'Stade de la Beaujoire',35322,'France','Nantes',47.256,-1.525);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 79,'Stadio Diego Armando Maradona',54726,'Italy','Naples',40.828,14.193);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 80,'St James'' Park',52258,'England','Newcastle upon Tyne',54.975556,-1.621667);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 81,'Allianz Riviera',35624,'France','Nice',43.705278,7.1925);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 82,'Carrow Road',27359,'England','Norwich',52.622222,1.309167);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 83,'City Ground',30404,'England','West Bridgford',52.94,-1.132778);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 84,'El Sadar',23516,'Spain','Pamplona',42.796667,-1.636944);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 85,'Kassam Stadium',12500,'England','Oxford',51.716389,-1.208056);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 86,'Parce Des Princes',47926,'France','Paris',48.84145,2.25305);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 87,'Stadio Ennio Tardini',27906,'Italy','Parma',44.794917,10.338444);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 88,'Home Park',17900,'England','Plymouth',50.388056,-4.150833);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 89,'Fratton Park',20899,'England','Portsmouth',50.796389,-1.063889);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 90,'Deepdale',23408,'England','Preston',53.772222,-2.688056);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 91,'Philips Stadion',36500,'Netherlands','Eindhoven',51.441667,5.4675);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 92,'Loftus Road',18439,'England','London',51.509167,-0.232222);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 93,'Campo de Futbol de Vallecas',14708,'Spain','Madrid',40.391944,-3.658889);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 94,'Red Bull Arena',47069,'Germany','Leipzig',51.345833,12.348333);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 95,'Estadio Benito Villamarin',60720,'Spain','Seville',37.356389,-5.981389);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 96,'Santiago Bernabeu',83186,'Spain','Madrid',40.453056,-3.688333);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 97,'Reale Arena',39500,'Spain','San Sebastian',43.301389,-1.973611);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 98,'Estadio Jose Zorrilla',27618,'Spain','Valladolid',41.644444,-4.761111);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ( 99,'Rajko Mitic Stadium',53000,'Serbia','Belgrade',44.783333,20.464722);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (100,'Estadio da Luz',64642,'Portugal','Lisbon',38.7527,-9.1847);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (101,'Stade Geoffroy-Guichard',41965,'France','Saint-Etienne',45.460833,4.390278);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (102,'Europa-Park Stadion',34700,'Germany','Freiburg im Breisgau',48.0216,7.8297);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (103,'Ramon Sanchez Pizjuan',42714,'Spain','Seville',37.384,-5.9705);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (104,'Bramall Lane',32050,'England','Sheffield',53.370278,-1.470833);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (105,'Hillsborough Stadium',39732,'England','Sheffield',53.411389,-1.500556);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (106,'Tehelne pole',22500,'Slovakia','Bratislava',48.1636,17.1369);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (107,'Merkur-Arena',16364,'Austria','Graz',47.046111,15.454444);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (108,'St Mary''s Stadium',32384,'England','Southampton',50.905833,-1.391111);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (109,'Estadio Jose Alvalade',50095,'Portugal','Lisbon',38.761111,-9.160833);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (110,'Millerntor-Stadion',29546,'Germany','Hamburg',53.554583,9.967667);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (111,'Stade Auguste Delaune',21684,'France','Reims',49.246667,4.025);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (112,'Roazhon Park',29778,'France','Rennes',48.1075,-1.712778);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (113,'bet365 Stadium',30089,'England','Stoke-on-Trent',52.988333,-2.175556);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (114,'Stade de la Meinau',29230,'France','Strasbourg',48.56,7.755);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (115,'Stadium of Light',49000,'England','Sunderland',54.914444,-1.388333);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (116,'Swansea.com Stadium',21088,'Wales','Swansea',51.6422,-3.9351);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (117,'Stadio Olimpico Grande Torino',27958,'Italy','Turin',45.041667,7.65);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (118,'Tottenham Hotspur Stadium',62850,'England','London',51.604444,-0.066389);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (119,'Stadium Municipal',33150,'France','Toulouse',43.583056,1.434167);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (120,'PreZero Arena',30150,'Germany','Sinsheim',49.238056,8.8875);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (121,'Stadio Friuli',25144,'Italy','Udine',46.0816,13.2001);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (122,'Mestalla',49430,'Spain','Valencia',39.474722,-0.358333);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (123,'Pier Luigi Penzo',11150,'Italy','Venice',45.427761,12.363731);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (124,'MHPArena',60058,'Germany','Stuttgart',48.792222,9.231944);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (125,'Vonovia Ruhrstadion',26000,'Germany','Bochum',51.49,7.236667);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (126,'Volkswagen Arena',28917,'Germany','Wolfsburg',52.432778,10.803889);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (127,'Estadio de la Ceramica',23000,'Spain','Villarreal',39.944167,-0.103611);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (128,'Vicarage Road',22200,'England','Watford',51.649722,-0.401389);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (129,'Weserstadion',42100,'Germany','Bremen',53.066389,8.8375);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (130,'The Hawthorns',26850,'England','West Bromwich',52.509167,-1.963889);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (131,'London Stadium',62500,'England','London',51.538611,-0.016389);
INSERT INTO stadiums (stadium_id,stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES (132,'Molineux Stadium',31750,'England','Wolverhampton',52.590278,-2.130278);
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
SET DEFINE OFF;
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (  1,'1. FC Heidenheim 1846',1,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (  2,'1. FC Union Berlin',2,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (  3,'AC Milan',3,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (  4,'AC Sparta Prague',4,4);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (  5,'AFC Bournemouth',5,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (  6,'AJ Auxerre',6,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (  7,'Alaves',7,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (  8,'Angers',8,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (  9,'Arsenal',9,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 10,'AS Monaco',10,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 11,'AS Roma',11,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 12,'Aston Villa',12,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 13,'Atalanta',13,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 14,'Athletic Club',14,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 15,'Atletico Madrid',15,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 16,'Barcelona',16,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 17,'Bayer Leverkusen',17,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 18,'Bayern Munich',18,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 19,'Blackburn Rovers',19,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 20,'Bologna',20,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 21,'Borussia Dortmund',21,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 22,'Borussia Monchengladbach',22,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 23,'Brentford',23,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 24,'Brest',24,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 25,'Brighton & Hove Albion',25,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 26,'Bristol City',26,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 27,'BSC Young Boys',27,16);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 28,'Burnley',28,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 29,'Cagliari',29,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 30,'Cardiff City',30,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 31,'Celta Vigo',31,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 32,'Celtic F.C.',32,12);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 33,'Chelsea',33,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 34,'Club Brugge KV',34,2);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 35,'Como',35,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 36,'Coventry City',36,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 37,'Crystal Palace',37,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 38,'Derby County',38,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 39,'Eintracht Frankfurt',39,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 40,'Empoli',40,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 41,'Espanyol',41,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 42,'Everton',42,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 43,'FC Augsburg',43,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 44,'FC Red Bull Salzburg',44,1);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 45,'FC Shakhtar Donetsk',45,17);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 46,'Feyenoord',46,5);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 47,'Fiorentina',47,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 48,'Fulham',48,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 49,'Genoa',49,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 50,'Getafe',50,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 51,'Girona',51,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 52,'GNK Dinamo Zagreb',52,3);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 53,'Hellas Verona',53,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 54,'Holstein Kiel',54,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 55,'Hull City',55,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 56,'Internazionale',3,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 57,'Ipswich Town',56,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 58,'Juventus',57,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 59,'Las Palmas',58,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 60,'Lazio',11,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 61,'Le Havre AC',59,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 62,'Lecce',60,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 63,'Leeds United',61,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 64,'Leganes',62,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 65,'Leicester City',63,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 66,'Lens',64,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 67,'Lille',65,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 68,'Liverpool',66,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 69,'Luton Town',67,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 70,'Lyon',68,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 71,'Mainz',69,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 72,'Mallorca',70,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 73,'Manchester City',71,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 74,'Manchester United',72,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 75,'Marseille',73,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 76,'Middlesbrough',74,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 77,'Millwall',75,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 78,'Montpellier',76,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 79,'Monza',77,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 80,'Nantes',78,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 81,'Napoli',79,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 82,'Newcastle United',80,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 83,'Nice',81,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 84,'Norwich City',82,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 85,'Nottingham Forest',83,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 86,'Osasuna',84,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 87,'Oxford United',85,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 88,'Paris Saint-Germain',86,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 89,'Parma',87,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 90,'Plymouth Argyle',88,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 91,'Portsmouth',89,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 92,'Preston North End',90,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 93,'PSV Eindhoven',91,5);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 94,'Queens Park Rangers',92,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 95,'Rayo Vallecano',93,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 96,'RB Leipzig',94,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 97,'Real Betis',95,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 98,'Real Madrid',96,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES ( 99,'Real Sociedad',97,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (100,'Real Valladolid',98,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (101,'Red Star Belgrade',99,13);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (102,'S.L. Benfica',100,11);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (103,'Saint-Etienne',101,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (104,'SC Freiburg',102,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (105,'Sevilla',103,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (106,'Sheffield United',104,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (107,'Sheffield Wednesday',105,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (108,'SK Slovan Bratislava',106,14);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (109,'SK Sturm Graz',107,1);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (110,'Southampton',108,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (111,'Sporting CP',109,11);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (112,'St. Pauli',110,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (113,'Stade de Reims',111,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (114,'Stade Rennais',112,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (115,'Stoke City',113,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (116,'Strasbourg',114,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (117,'Sunderland',115,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (118,'Swansea City',116,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (119,'Torino',117,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (120,'Tottenham Hotspur',118,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (121,'Toulouse',119,8);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (122,'TSG Hoffenheim',120,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (123,'Udinese',121,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (124,'Valencia',122,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (125,'Venezia',123,10);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (126,'VfB Stuttgart',124,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (127,'VfL Bochum',125,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (128,'VfL Wolfsburg',126,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (129,'Villarreal',127,15);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (130,'Watford',128,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (131,'Werder Bremen',129,9);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (132,'West Bromwich Albion',130,6);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (133,'West Ham United',131,7);
INSERT INTO teams (team_id,team_nm,stadium_id,league_id) VALUES (134,'Wolverhampton Wanderers',132,7);
--| ----------
ALTER SEQUENCE team_id_seq RESTART START WITH 135;
--| ----------
ALTER TRIGGER teams_trg1 ENABLE;


