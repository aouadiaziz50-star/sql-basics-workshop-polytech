-- ============================================
-- Exercice 2 : Requetes SELECT simples et filtrees
-- Realise par : AOUADI Mohamed
-- Date : 2026-06-01
-- ============================================

-- Objectif :
-- Verifier les donnees inserees dans l'exercice 1
-- avec des requetes SELECT simples, des filtres WHERE
-- et un tri avec ORDER BY.

-- ============================================
-- 1. Tous les streamers avec leur URL Twitch,
--    ordonnes par pseudo
-- ============================================

SELECT
    pseudo,
    url_twitch
FROM streamer
ORDER BY pseudo ASC;

-- ============================================
-- 2. Les creneaux du samedi 2025-09-06
--    Utilisation de DATE() pour extraire la date
-- ============================================

SELECT
    id_creneau,
    id_streamer,
    date_debut_autorisee,
    date_fin_autorisee
FROM creneau
WHERE DATE(date_debut_autorisee) = '2025-09-06'
ORDER BY date_debut_autorisee ASC;

-- ============================================
-- 3. Les defis valides ayant un montant palier
--    superieur a 5000 euros
-- ============================================

SELECT
    id_defi,
    intitule,
    montant_palier,
    etat_validation
FROM defi
WHERE etat_validation = TRUE
AND montant_palier > 5000
ORDER BY montant_palier DESC;

-- ============================================
-- 4. Les streams dont la date de fin effective
--    est NULL, donc les streams non termines
-- ============================================

SELECT
    id_stream,
    id_streamer,
    id_creneau,
    titre,
    heure_debut,
    heure_fin,
    date_fin_effective
FROM stream
WHERE date_fin_effective IS NULL
ORDER BY heure_debut ASC;
