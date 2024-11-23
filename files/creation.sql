-- Création des tables principales
CREATE TABLE seasons (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE championships (
    id SERIAL PRIMARY KEY,
    season_id INT REFERENCES seasons(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE leagues (
    id SERIAL PRIMARY KEY,
    championship_id INT REFERENCES championships(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    tier INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE divisions (
    id SERIAL PRIMARY KEY,
    league_id INT REFERENCES leagues(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE teams (
    id SERIAL PRIMARY KEY,
    division_id INT REFERENCES divisions(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    abbreviation VARCHAR(3) NOT NULL UNIQUE,
    logo TEXT,
    mmr FLOAT DEFAULT 0,
    -- penalties INT DEFAULT 0,
    coach_name VARCHAR(255),
    coach_email VARCHAR(255),
    coach_country VARCHAR(2) REFERENCES countries(code),
    coach_discord VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE players (
    id SERIAL PRIMARY KEY,
    team_id INT REFERENCES teams(id) ON DELETE SET NULL,
    nickname VARCHAR(255) NOT NULL,
    country VARCHAR(2) REFERENCES countries(code),
    discord_id VARCHAR(255) UNIQUE,
    epic_id VARCHAR(255) UNIQUE,
    email VARCHAR(255) UNIQUE,
    game_platform VARCHAR(50) NOT NULL,
    game_account VARCHAR(255) NOT NULL UNIQUE,
    mmr FLOAT DEFAULT 0,
    banned BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Contrainte : Un joueur ne peut appartenir qu'à une seule équipe dans une saison
ALTER TABLE players ADD CONSTRAINT unique_team_per_player UNIQUE (team_id);

-- Table de logs
CREATE TABLE logs (
    id SERIAL PRIMARY KEY,                          -- Identifiant unique pour chaque log
    log_type VARCHAR(50) NOT NULL,                  -- Type de log (par exemple : "équipe", "match")
    entity_id INT NOT NULL,                         -- L'ID de l'entité liée à l'action (par exemple, l'ID d'une équipe ou d'un joueur)
    entity_type VARCHAR(50) NOT NULL,               -- Type d'entité associée (par exemple : "team", "player")
    action VARCHAR(255) NOT NULL,                   -- Description de l'action effectuée (par exemple : "ajout d'un joueur", "modification du nom de l'équipe")
    details JSONB,                                  -- Détails supplémentaires au format JSON (exemple : les valeurs avant et après modification)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Date et heure de la création du log (automatiquement attribuée)
);


-- Table pour les utilisateurs (super-admin, admin)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL CHECK (role IN ('super-admin', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table pour les pays avec données pré-remplies
CREATE TABLE countries (
    code VARCHAR(2) PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Insertion des pays (exemple simplifié)
INSERT INTO countries (code, name) VALUES 
('FR', 'France'),
('US', 'United States'),
('ES', 'Spain'),
('DE', 'Germany'),
('IT', 'Italy');

-- Index pour les performances
CREATE INDEX idx_team_division ON teams(division_id);
CREATE INDEX idx_player_team ON players(team_id);
CREATE INDEX idx_logs_entity ON logs(entity_id, entity_type);

-- Mise à jour automatique des timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON seasons
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_championships
BEFORE UPDATE ON championships
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_leagues
BEFORE UPDATE ON leagues
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_divisions
BEFORE UPDATE ON divisions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_teams
BEFORE UPDATE ON teams
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_players
BEFORE UPDATE ON players
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
