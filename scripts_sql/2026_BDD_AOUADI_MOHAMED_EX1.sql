-- ============================================
-- Exercice 1 : Creation et population de la base
-- Realise par : AOUADI Mohamed
-- Date : 2026-06-01
-- ============================================

-- Objectif :
-- Creer les tables principales du projet ZEvent
-- puis inserer des donnees coherentes pour les exercices suivants.

-- ============================================
-- 1. Suppression des anciennes tables
-- ============================================

DROP TABLE IF EXISTS stream CASCADE;
DROP TABLE IF EXISTS participation_defi CASCADE;
DROP TABLE IF EXISTS creneau CASCADE;
DROP TABLE IF EXISTS defi CASCADE;
DROP TABLE IF EXISTS streamer CASCADE;

-- ============================================
-- 2. Creation des tables
-- ============================================

CREATE TABLE streamer (
    id_streamer SERIAL PRIMARY KEY,
    pseudo VARCHAR(100) UNIQUE NOT NULL,
    url_twitch VARCHAR(255) NOT NULL
);

CREATE TABLE creneau (
    id_creneau SERIAL PRIMARY KEY,
    id_streamer INT NOT NULL,
    date_debut_autorisee TIMESTAMP NOT NULL,
    date_fin_autorisee TIMESTAMP NOT NULL,

    CONSTRAINT fk_creneau_streamer
        FOREIGN KEY (id_streamer)
        REFERENCES streamer(id_streamer)
        ON DELETE CASCADE,

    CONSTRAINT chk_creneau_dates
        CHECK (date_fin_autorisee > date_debut_autorisee)
);

CREATE TABLE defi (
    id_defi SERIAL PRIMARY KEY,
    intitule VARCHAR(255) NOT NULL,
    montant_palier DECIMAL(12,2) NOT NULL,
    etat_validation BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT chk_montant_palier
        CHECK (montant_palier > 0)
);

CREATE TABLE participation_defi (
    id_streamer INT NOT NULL,
    id_defi INT NOT NULL,

    PRIMARY KEY (id_streamer, id_defi),

    CONSTRAINT fk_participation_streamer
        FOREIGN KEY (id_streamer)
        REFERENCES streamer(id_streamer)
        ON DELETE CASCADE,

    CONSTRAINT fk_participation_defi
        FOREIGN KEY (id_defi)
        REFERENCES defi(id_defi)
        ON DELETE CASCADE
);

CREATE TABLE stream (
    id_stream SERIAL PRIMARY KEY,
    id_streamer INT NOT NULL,
    id_creneau INT NOT NULL,
    titre VARCHAR(255) NOT NULL,
    heure_debut TIMESTAMP NOT NULL,
    heure_fin TIMESTAMP NOT NULL,
    date_fin_effective TIMESTAMP NULL,

    CONSTRAINT fk_stream_streamer
        FOREIGN KEY (id_streamer)
        REFERENCES streamer(id_streamer)
        ON DELETE CASCADE,

    CONSTRAINT fk_stream_creneau
        FOREIGN KEY (id_creneau)
        REFERENCES creneau(id_creneau)
        ON DELETE CASCADE,

    CONSTRAINT chk_stream_dates
        CHECK (heure_fin > heure_debut)
);

-- ============================================
-- 3. Insertion des streamers
-- ============================================

INSERT INTO streamer (pseudo, url_twitch) VALUES
('ZeratoR', 'https://twitch.tv/zerator'),
('AntoineDaniel', 'https://twitch.tv/antoinedaniel'),
('MisterMV', 'https://twitch.tv/mistermv'),
('Ultia', 'https://twitch.tv/ultia'),
('Domingo', 'https://twitch.tv/domingo'),
('BagheraJones', 'https://twitch.tv/bagherajones'),
('Etoiles', 'https://twitch.tv/etoiles'),
('Ponce', 'https://twitch.tv/ponce'),
('JDG', 'https://twitch.tv/joueurdugrenier'),
('Maghla', 'https://twitch.tv/maghla');

-- ============================================
-- 4. Insertion des creneaux
-- ============================================

INSERT INTO creneau (id_streamer, date_debut_autorisee, date_fin_autorisee) VALUES
(1, '2025-09-05 18:00:00', '2025-09-05 22:00:00'),
(1, '2025-09-06 10:00:00', '2025-09-06 14:00:00'),

(2, '2025-09-05 20:00:00', '2025-09-06 00:00:00'),
(2, '2025-09-06 14:00:00', '2025-09-06 18:00:00'),

(3, '2025-09-05 22:00:00', '2025-09-06 02:00:00'),
(3, '2025-09-06 18:00:00', '2025-09-06 22:00:00'),

(4, '2025-09-06 08:00:00', '2025-09-06 12:00:00'),
(4, '2025-09-06 20:00:00', '2025-09-07 00:00:00'),

(5, '2025-09-06 09:00:00', '2025-09-06 13:00:00'),
(5, '2025-09-07 10:00:00', '2025-09-07 14:00:00'),

(6, '2025-09-06 11:00:00', '2025-09-06 15:00:00'),
(6, '2025-09-07 14:00:00', '2025-09-07 18:00:00'),

(7, '2025-09-06 13:00:00', '2025-09-06 17:00:00'),
(7, '2025-09-07 16:00:00', '2025-09-07 20:00:00'),

(8, '2025-09-06 15:00:00', '2025-09-06 19:00:00'),
(8, '2025-09-07 18:00:00', '2025-09-07 22:00:00'),

(9, '2025-09-06 17:00:00', '2025-09-06 21:00:00'),
(9, '2025-09-07 20:00:00', '2025-09-08 00:00:00'),

(10, '2025-09-06 19:00:00', '2025-09-06 23:00:00'),
(10, '2025-09-07 21:00:00', '2025-09-08 01:00:00');

-- ============================================
-- 5. Insertion des defis
-- ============================================

INSERT INTO defi (intitule, montant_palier, etat_validation) VALUES
('Saut en parachute', 100000.00, FALSE),
('Marathon jeu horreur', 15000.00, TRUE),
('Teinture cheveux', 8000.00, TRUE),
('Tournoi Mario Kart', 5000.00, FALSE),
('Karaoke collectif', 2500.00, TRUE),
('Speedrun surprise', 12000.00, FALSE),
('Cosplay complet', 20000.00, TRUE),
('Cuisine en live', 3500.00, FALSE),
('Quiz culture generale', 1000.00, TRUE),
('Stream de nuit', 7000.00, FALSE);

-- ============================================
-- 6. Insertion des participations aux defis
-- ============================================

INSERT INTO participation_defi (id_streamer, id_defi) VALUES
(1, 1),
(2, 1),
(3, 1),

(1, 2),
(4, 2),

(5, 3),
(6, 3),

(7, 4),
(8, 4),
(9, 4),

(10, 5),
(1, 5),

(2, 6),
(3, 6),

(4, 7),
(5, 7),
(6, 7),

(8, 9),
(9, 10);

-- ============================================
-- 7. Insertion des streams
-- ============================================

INSERT INTO stream (id_streamer, id_creneau, titre, heure_debut, heure_fin, date_fin_effective) VALUES
(1, 1, 'Ouverture du ZEvent', '2025-09-05 18:15:00', '2025-09-05 21:45:00', '2025-09-05 21:50:00'),
(1, 2, 'Session donation goals', '2025-09-06 10:10:00', '2025-09-06 13:30:00', '2025-09-06 13:35:00'),

(2, 3, 'Discussion et reactions', '2025-09-05 20:30:00', '2025-09-05 23:30:00', '2025-09-05 23:40:00'),
(2, 4, 'Jeux avec viewers', '2025-09-06 14:05:00', '2025-09-06 17:45:00', NULL),

(3, 5, 'Concert et gaming', '2025-09-05 22:15:00', '2025-09-06 01:45:00', '2025-09-06 01:55:00'),
(3, 6, 'Session retro gaming', '2025-09-06 18:20:00', '2025-09-06 21:30:00', NULL),

(4, 7, 'Matinee chill', '2025-09-06 08:15:00', '2025-09-06 11:45:00', '2025-09-06 11:45:00'),
(5, 9, 'Talk show caritatif', '2025-09-06 09:30:00', '2025-09-06 12:30:00', '2025-09-06 12:40:00'),

(6, 11, 'Jeu cooperatif', '2025-09-06 11:10:00', '2025-09-06 14:50:00', NULL),
(7, 13, 'Quiz interactif', '2025-09-06 13:20:00', '2025-09-06 16:45:00', '2025-09-06 16:50:00'),

(8, 15, 'Defi communautaire', '2025-09-06 15:30:00', '2025-09-06 18:30:00', '2025-09-06 18:35:00'),
(9, 17, 'Session humour', '2025-09-06 17:15:00', '2025-09-06 20:45:00', NULL),
(10, 19, 'Fin de soiree', '2025-09-06 19:30:00', '2025-09-06 22:30:00', '2025-09-06 22:40:00');

-- ============================================
-- 8. Verification des insertions
-- ============================================

SELECT COUNT(*) AS nb_streamers FROM streamer;
SELECT COUNT(*) AS nb_creneaux FROM creneau;
SELECT COUNT(*) AS nb_defis FROM defi;
SELECT COUNT(*) AS nb_participations FROM participation_defi;
SELECT COUNT(*) AS nb_streams FROM stream;

-- Verification rapide du contenu principal
SELECT * FROM streamer ORDER BY id_streamer;
SELECT * FROM creneau ORDER BY id_creneau;
SELECT * FROM defi ORDER BY id_defi;
SELECT * FROM participation_defi ORDER BY id_defi, id_streamer;
SELECT * FROM stream ORDER BY id_stream;
