-- ============================================
-- Exercice 4 : Agregations
-- Realise par : AOUADI Mohamed
-- Date : 2026-06-01
-- ============================================

-- Objectif :
-- Utiliser les fonctions d'agregation :
-- COUNT, SUM, AVG, GROUP BY, HAVING et COALESCE.

-- ============================================
-- 1. Nombre de streams par streamer
-- ============================================

SELECT
    s.id_streamer,
    s.pseudo,
    COUNT(st.id_stream) AS nombre_streams
FROM streamer s
LEFT JOIN stream st
    ON s.id_streamer = st.id_streamer
GROUP BY
    s.id_streamer,
    s.pseudo
ORDER BY
    nombre_streams DESC,
    s.pseudo ASC;

-- ============================================
-- 2. Montant total des defis par etat de validation
-- ============================================

SELECT
    etat_validation,
    COUNT(id_defi) AS nombre_defis,
    SUM(montant_palier) AS montant_total
FROM defi
GROUP BY
    etat_validation
ORDER BY
    etat_validation DESC;

-- ============================================
-- 3. Streamers participant a au moins 2 defis
-- ============================================

SELECT
    s.id_streamer,
    s.pseudo,
    COUNT(pd.id_defi) AS nombre_defis
FROM streamer s
INNER JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
GROUP BY
    s.id_streamer,
    s.pseudo
HAVING
    COUNT(pd.id_defi) >= 2
ORDER BY
    nombre_defis DESC,
    s.pseudo ASC;

-- ============================================
-- 4. Duree de chaque stream et duree moyenne globale en heures
-- ============================================

SELECT
    titre,
    ROUND(
        EXTRACT(EPOCH FROM (heure_fin - heure_debut)) / 3600,
        2
    ) AS duree_stream_heures,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (heure_fin - heure_debut)) / 3600) OVER (),
        2
    ) AS duree_moyenne_globale_heures
FROM stream
ORDER BY
    heure_debut ASC;

-- ============================================
-- 5. Streamers ayant effectivement lance au moins un stream
-- ============================================

SELECT
    s.pseudo,
    st.titre,
    st.heure_debut
FROM streamer s
INNER JOIN stream st
    ON s.id_streamer = st.id_streamer
ORDER BY
    s.pseudo ASC,
    st.heure_debut ASC;

-- ============================================
-- 6. Streamers ayant lance au moins un stream
-- ============================================

SELECT
    s.id_streamer,
    s.pseudo,
    COUNT(st.id_stream) AS nombre_streams
FROM streamer s
INNER JOIN stream st
    ON s.id_streamer = st.id_streamer
GROUP BY
    s.id_streamer,
    s.pseudo
HAVING
    COUNT(st.id_stream) >= 1
ORDER BY
    nombre_streams DESC,
    s.pseudo ASC;

-- ============================================
-- 7. Montant total des defis par streamer
-- ============================================

SELECT
    s.id_streamer,
    s.pseudo,
    COUNT(d.id_defi) AS nombre_defis,
    COALESCE(SUM(d.montant_palier), 0) AS montant_total_defis
FROM streamer s
LEFT JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
LEFT JOIN defi d
    ON pd.id_defi = d.id_defi
GROUP BY
    s.id_streamer,
    s.pseudo
ORDER BY
    montant_total_defis DESC,
    s.pseudo ASC;
