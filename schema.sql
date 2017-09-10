CREATE TABLE IF NOT EXISTS episodes(
    episode_id INTEGER PRIMARY KEY
  , title VARCHAR(256) NOT NULL
  , description TEXT NOT NULL
  , image_url VARCHAR(512) NOT NULL
  , episode_url VARCHAR(512) NOT NULL
);

CREATE TABLE IF NOT EXISTS airings(
    airing_id SERIAL PRIMARY KEY
  , episode_id INTEGER NOT NULL REFERENCES episodes (episode_id)
  , air_date TIMESTAMP UNIQUE NOT NULL
);  

COPY episodes FROM '/Volumes/Mac Data/Code/TALReruns/episodes20170902.csv' WITH (FORMAT csv, HEADER TRUE);

COPY airings (episode_id, air_date) FROM '/Volumes/Mac Data/Code/TALReruns/original_airdates.csv' WITH (FORMAT csv, HEADER TRUE);

CREATE OR REPLACE VIEW original_airings AS
	SELECT e.*, original_air_date FROM episodes e
	INNER JOIN (
		SELECT episode_id, MIN(air_date) original_air_date
		FROM airings a
		GROUP BY a.episode_id
	) tbl ON e.episode_id = tbl.episode_id;
	
CREATE OR REPLACE VIEW all_airings AS
	SELECT o.*, a.air_date FROM original_airings o
	INNER JOIN airings a ON o.episode_id = a.episode_id;

