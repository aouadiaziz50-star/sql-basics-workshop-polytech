-- ============================================
-- Exercice 3 : Jointures
-- Realise par : AOUADI Mohamed
-- Date : 2026-06-01
-- ============================================

-- Objectif :
-- Utiliser des jointures pour relier les tables entre elles :
-- streamer, creneau, stream, defi et participation_defi.

-- ============================================
-- 1. Afficher les streamers avec leurs creneaux
-- ============================================

SELECT
    s.id_streamer,
    s.pseudo,
    s.url_twitch,
    c.id_creneau,
    c.date_debut_autorisee,
    c.date_fin_autorisee
FROM streamer s
INNER JOIN creneau c
    ON s.id_streamer = c.id_streamer
ORDER BY
    s.pseudo ASC,
    c.date_debut_autorisee ASC;

-- ============================================
-- 2. Afficher les streams avec le streamer
--    et le creneau correspondant
-- ============================================

SELECT
    st.id_stream,
    st.titre,
    s.pseudo AS streamer,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin,
    st.date_fin_effective
FROM stream st
INNER JOIN streamer s
    ON st.id_streamer = s.id_streamer
INNER JOIN creneau c
    ON st.id_creneau = c.id_creneau
ORDER BY
    st.heure_debut ASC;

-- ============================================
-- 3. Afficher les defis avec les streamers
--    qui y participent
-- ============================================

SELECT
    d.id_defi,
    d.intitule,
    d.montant_palier,
    d.etat_validation,
    s.id_streamer,
    s.pseudo AS participant
FROM defi d
INNER JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
INNER JOIN streamer s
    ON pd.id_streamer = s.id_streamer
ORDER BY
    d.id_defi ASC,
    s.pseudo ASC;

-- ============================================
-- 4. Version avec LEFT JOIN pour voir aussi
--    les defis sans participant
-- ============================================

SELECT
    d.id_defi,
    d.intitule,
    d.montant_palier,
    d.etat_validation,
    s.pseudo AS participant
FROM defi d
LEFT JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
LEFT JOIN streamer s
    ON pd.id_streamer = s.id_streamer
ORDER BY
    d.id_defi ASC,
    s.pseudo ASC;
