CREATE TABLE IF NOT EXISTS episodes(
    id INTEGER PRIMARY KEY
  , title VARCHAR(256) NOT NULL
  , description TEXT NOT NULL
  , image_url VARCHAR(512) NOT NULL
  , episode_url VARCHAR(512) NOT NULL
);

CREATE TABLE IF NOT EXISTS airings(
    id SERIAL PRIMARY KEY
  , episode_id INTEGER NOT NULL REFERENCES episodes (id)
  , air_date TIMESTAMP UNIQUE NOT NULL
);  

CREATE OR REPLACE VIEW original_airings AS
	SELECT 
		e.id AS episode_id,
		e.title AS title,
		e.description AS description,
		e.image_url AS image_url,
		e.episode_url AS episode_url, 
		tbl.original_air_date AS original_air_date
	FROM episodes e
		INNER JOIN (
			SELECT episode_id, MIN(air_date) original_air_date
			FROM airings a
			GROUP BY a.episode_id
		) tbl 
			ON e.id = tbl.episode_id;
	
CREATE OR REPLACE VIEW all_airings AS
	SELECT o.*, a.air_date 
	FROM original_airings o
		INNER JOIN airings a 
			ON o.episode_id = a.episode_id;

