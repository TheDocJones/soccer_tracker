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
SET DEFINE OFF;
INSERT INTO leagues (league_nm) VALUES ('Austrian Bundesliga');
INSERT INTO leagues (league_nm) VALUES ('Belgian Pro League');
INSERT INTO leagues (league_nm) VALUES ('Croatian SuperSport HNL');
INSERT INTO leagues (league_nm) VALUES ('Czech First League');
INSERT INTO leagues (league_nm) VALUES ('Dutch Eredivisie');
INSERT INTO leagues (league_nm) VALUES ('EFL Championship');
INSERT INTO leagues (league_nm) VALUES ('English Premier League');
INSERT INTO leagues (league_nm) VALUES ('French Ligue 1');
INSERT INTO leagues (league_nm) VALUES ('German Bundesliga');
INSERT INTO leagues (league_nm) VALUES ('Italian Serie A');
INSERT INTO leagues (league_nm) VALUES ('Portuguese Primeira Liga');
INSERT INTO leagues (league_nm) VALUES ('Scottish Premiership');
INSERT INTO leagues (league_nm) VALUES ('Serbian SuperLiga');
INSERT INTO leagues (league_nm) VALUES ('Slovak First Football League');
INSERT INTO leagues (league_nm) VALUES ('Spanish La Liga');
INSERT INTO leagues (league_nm) VALUES ('Swiss Super League');
INSERT INTO leagues (league_nm) VALUES ('Ukrainian Premier League');
--| ==================================================


--| ==================================================
--| INSERTING INTO STADIUMS
--| ==================================================
SET DEFINE OFF;
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Voith-Arena',15000,'Germany','Heidenheim',48.668611,10.139444);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadion An der Alten Forsterei',22012,'Germany','Berlin',52.457222,13.568056);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Giuseppe Meazza',80018,'Italy','Milan',45.478056,9.123889);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('epet ARENA',18944,'Czechia','Prague',50.099722,14.415833);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Dean Court',11307,'England','Bournemouth',50.735278,-1.838333);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade de I''Abbe-Deschamps',21379,'France','Auxerre',47.786753,3.588664);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Mendizorrotza',19840,'Spain','Vitoria-Gasteiz',42.837111,-2.688044);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade Raymond Kopa',18752,'France','Angers',47.460458,-0.530741);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Emirates Stadium',60704,'England','London',51.556667,-0.106111);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade Louis II',18523,'Monaco','Fontvieille',43.7275,7.415556);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Olimpico',70634,'Italy','Rome',41.933889,12.454722);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Villa Park',42918,'England','Birmingham',52.509167,-1.884722);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Gewiss Stadium',24950,'Italy','Bergamo',45.708889,9.680833);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('San Mames',53289,'Spain','Bilbao',43.2643,-2.9504);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Metropolitano Stadium',70460,'Spain','Madrid',40.436111,-3.599444);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadi Olimpic Lluis Companys',54367,'Spain','Barcelona',41.364722,2.155556);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('BayArena',30210,'Germany','Leverkusen',51.038333,7.002222);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Allianz Arena',75000,'Germany','Munich',48.218889,11.624722);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Ewood Park',31367,'England','Blackburn',53.728611,-2.489167);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Renato Dall''Ara',38279,'Italy','Bologna',44.492222,11.309722);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Signal Iduna Park',81365,'Germany','Dortmund',51.4925,7.451667);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Borussia-Park',54042,'Germany','Monchengladbach',51.174722,6.385556);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Brentford Community Stadium',17250,'England','London',51.490833,-0.288611);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade Francis-Le Ble',15931,'France','Brest',48.402932,-4.461694);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Falmer Stadium',31876,'England','Falmer',50.861944,-0.083333);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Ashton Gate Stadium',27000,'England','Bristol',51.44,-2.620278);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadion Wankdorf',31120,'Switzerland','Bern',46.963056,7.464722);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Turf Moor',21944,'England','Burnley',53.789167,-2.230278);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Sardegna Arena',16416,'Italy','Cagliari',39.2,9.1375);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Cardiff City Stadium',33280,'Wales','Cardiff',51.472781,-3.203061);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Balaidos',24791,'Spain','Vigo',42.2118,-8.7397);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Celtic Park',60411,'Scotland','Glasgow',55.849722,-4.205556);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stamford Bridge',40173,'England','London',51.481667,-0.191111);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Jan Breydel Stadium',29042,'Belgium','Bruges',51.193333,3.180556);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Giuseppe Sinigaglia',13602,'Italy','Como',45.813889,9.072222);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Coventry Building Society Arena',32609,'England','Coventry',52.448056,-1.495556);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Selhurst Park',25194,'England','London',51.398333,-0.085556);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Pride Park Stadium',32956,'England','Derby',52.915,-1.447222);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Deutsche Bank Park',58000,'Germany','Frankfurt',50.068056,8.645806);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Carlo Castellani',16284,'Italy','Empoli',43.726389,10.955);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stage Front Stadium',40000,'Spain','Cornella de Llobregat',41.347778,2.075556);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Goodison Park',39414,'England','Liverpool',53.438889,-2.966389);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('WWK Arena',30660,'Germany','Augsburg',48.323056,10.886111);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Red Bull Arena',30188,'Austria','Wals-Siezenheim',47.816389,12.998333);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Arena Livyi Bereh',4700,'Ukraine','Zolochivska',50.324433,30.649909);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('De Kuip',47500,'Netherlands','Rotterdam',51.893889,4.523056);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Artemio Franchi',43147,'Italy','Florence',43.780833,11.282222);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Craven Cottage',26000,'England','London',51.475,-0.221667);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Luigi Ferraris',36599,'Italy','Genoa',44.416389,8.9525);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadio Coliseum',16500,'Spain','Getafe',40.325556,-3.714722);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadi Montilivi',14624,'Spain','Girona',41.961389,2.828611);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Maksimir',24851,'Croatia','Zagreb',45.818889,16.018056);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Marcantonio Bentegodi',39211,'Italy','Verona',45.435278,10.968611);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Holstein-Stadion',15034,'Germany','Kiel',54.349167,10.123611);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('MKM Stadium',25586,'England','Kingston upon Hull',53.746111,-0.367778);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Portman Road',29813,'England','Ipswich',52.055,1.144722);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Allianz Stadium',41507,'Italy','Turin',45.109444,7.641111);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadio Gran Canaria',32400,'Spain','Las Palmas',28.100278,-15.456667);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade Oceane',25178,'France','Le Havre',49.498889,0.169722);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Ettore Giardiniero - Via del Mare',31533,'Italy','Lecce',40.365278,18.208889);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Elland Road',37608,'England','Leeds',53.777778,-1.572222);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadio Municipal Butarque',12450,'Spain','Leganes',40.3404,-3.7607);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('King Power Stadium',32259,'England','Leicester',52.620278,-1.142222);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade Bollaert-Delelis',37705,'France','Lens',50.432778,2.815);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Decathlon Arena Pierre Mauroy Stadium',50186,'France','Lille',50.6119,3.1304);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Anfield',61276,'England','Liverpool',53.430833,-2.960833);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Kenilworth Road',12000,'England','Luton',51.884167,-0.431667);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Groupama Stadium',59186,'France','Lyon',45.765224,4.982131);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Mewa Arena',33305,'Germany','Mainz',49.984167,8.224167);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadi Mallorca Son Moix',23142,'Spain','Palma',39.59,2.63);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('City of Manchester Stadium',52900,'England','Manchester',53.483056,-2.200278);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Old Trafford',74197,'England','Manchester',53.463056,-2.291389);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Orange Velodrome',18523,'France','Marseille',43.269722,5.395833);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Riverside Stadium',34742,'England','Middlesbrough',54.578333,-1.216944);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('The Den',20146,'England','London',51.485833,-0.050833);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade de la Mosson',32900,'France','Montpellier',43.622222,3.811944);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Brianteo',16917,'Italy','Monza',45.582778,9.308056);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade de la Beaujoire',35322,'France','Nantes',47.256,-1.525);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Diego Armando Maradona',54726,'Italy','Naples',40.828,14.193);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('St James'' Park',52258,'England','Newcastle upon Tyne',54.975556,-1.621667);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Allianz Riviera',35624,'France','Nice',43.705278,7.1925);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Carrow Road',27359,'England','Norwich',52.622222,1.309167);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('City Ground',30404,'England','West Bridgford',52.94,-1.132778);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('El Sadar',23516,'Spain','Pamplona',42.796667,-1.636944);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Kassam Stadium',12500,'England','Oxford',51.716389,-1.208056);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Parce Des Princes',47926,'France','Paris',48.84145,2.25305);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Ennio Tardini',27906,'Italy','Parma',44.794917,10.338444);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Home Park',17900,'England','Plymouth',50.388056,-4.150833);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Fratton Park',20899,'England','Portsmouth',50.796389,-1.063889);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Deepdale',23408,'England','Preston',53.772222,-2.688056);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Philips Stadion',36500,'Netherlands','Eindhoven',51.441667,5.4675);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Loftus Road',18439,'England','London',51.509167,-0.232222);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Campo de Futbol de Vallecas',14708,'Spain','Madrid',40.391944,-3.658889);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Red Bull Arena',47069,'Germany','Leipzig',51.345833,12.348333);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadio Benito Villamarin',60720,'Spain','Seville',37.356389,-5.981389);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Santiago Bernabeu',83186,'Spain','Madrid',40.453056,-3.688333);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Reale Arena',39500,'Spain','San Sebastian',43.301389,-1.973611);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadio Jose Zorrilla',27618,'Spain','Valladolid',41.644444,-4.761111);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Rajko Mitic Stadium',53000,'Serbia','Belgrade',44.783333,20.464722);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadio da Luz',64642,'Portugal','Lisbon',38.7527,-9.1847);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade Geoffroy-Guichard',41965,'France','Saint-Etienne',45.460833,4.390278);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Europa-Park Stadion',34700,'Germany','Freiburg im Breisgau',48.0216,7.8297);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Ramon Sanchez Pizjuan',42714,'Spain','Seville',37.384,-5.9705);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Bramall Lane',32050,'England','Sheffield',53.370278,-1.470833);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Hillsborough Stadium',39732,'England','Sheffield',53.411389,-1.500556);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Tehelne pole',22500,'Slovakia','Bratislava',48.1636,17.1369);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Merkur-Arena',16364,'Austria','Graz',47.046111,15.454444);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('St Mary''s Stadium',32384,'England','Southampton',50.905833,-1.391111);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadio Jose Alvalade',50095,'Portugal','Lisbon',38.761111,-9.160833);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Millerntor-Stadion',29546,'Germany','Hamburg',53.554583,9.967667);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade Auguste Delaune',21684,'France','Reims',49.246667,4.025);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Roazhon Park',29778,'France','Rennes',48.1075,-1.712778);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('bet365 Stadium',30089,'England','Stoke-on-Trent',52.988333,-2.175556);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stade de la Meinau',29230,'France','Strasbourg',48.56,7.755);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadium of Light',49000,'England','Sunderland',54.914444,-1.388333);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Swansea.com Stadium',21088,'Wales','Swansea',51.6422,-3.9351);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Olimpico Grande Torino',27958,'Italy','Turin',45.041667,7.65);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Tottenham Hotspur Stadium',62850,'England','London',51.604444,-0.066389);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadium Municipal',33150,'France','Toulouse',43.583056,1.434167);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('PreZero Arena',30150,'Germany','Sinsheim',49.238056,8.8875);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Stadio Friuli',25144,'Italy','Udine',46.0816,13.2001);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Mestalla',49430,'Spain','Valencia',39.474722,-0.358333);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Pier Luigi Penzo',11150,'Italy','Venice',45.427761,12.363731);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('MHPArena',60058,'Germany','Stuttgart',48.792222,9.231944);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Vonovia Ruhrstadion',26000,'Germany','Bochum',51.49,7.236667);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Volkswagen Arena',28917,'Germany','Wolfsburg',52.432778,10.803889);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Estadio de la Ceramica',23000,'Spain','Villarreal',39.944167,-0.103611);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Vicarage Road',22200,'England','Watford',51.649722,-0.401389);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Weserstadion',42100,'Germany','Bremen',53.066389,8.8375);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('The Hawthorns',26850,'England','West Bromwich',52.509167,-1.963889);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('London Stadium',62500,'England','London',51.538611,-0.016389);
INSERT INTO stadiums (stadium_nm,capacity,country_nm,city_nm,latitude,longitude) VALUES ('Molineux Stadium',31750,'England','Wolverhampton',52.590278,-2.130278);
--| ==================================================


--| ==================================================
--| 
--| ==================================================