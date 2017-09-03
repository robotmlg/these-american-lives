
CREATE SCHEMA IF NOT EXISTS tal;

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
  , air_date DATE UNIQUE NOT NULL
);

