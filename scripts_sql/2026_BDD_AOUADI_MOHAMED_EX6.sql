-- ============================================
-- Exercice 6 : Requetes avancees sur relation M:N
-- Realise par : AOUADI Mohamed
-- Date : 2026-06-01
-- ============================================

-- Objectif :
-- Exploiter la relation plusieurs-a-plusieurs entre streamer et defi
-- grace a la table de liaison participation_defi.

-- ============================================
-- 1. Streamers ayant au moins un defi
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
    COUNT(pd.id_defi) >= 1
ORDER BY
    nombre_defis DESC,
    s.pseudo ASC;

-- ============================================
-- 2. Defis sans participant
-- ============================================

SELECT
    d.id_defi,
    d.intitule,
    d.montant_palier,
    d.etat_validation
FROM defi d
LEFT JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
WHERE pd.id_streamer IS NULL
ORDER BY
    d.id_defi ASC;

-- ============================================
-- 3. Defis avec plus de 2 participants
-- ============================================

SELECT
    d.id_defi,
    d.intitule,
    d.montant_palier,
    COUNT(pd.id_streamer) AS nombre_participants
FROM defi d
INNER JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
GROUP BY
    d.id_defi,
    d.intitule,
    d.montant_palier
HAVING
    COUNT(pd.id_streamer) > 2
ORDER BY
    nombre_participants DESC,
    d.montant_palier DESC;

-- ============================================
-- 4. Nombre de defis par streamer
--    et montant total engage
-- ============================================

SELECT
    s.id_streamer,
    s.pseudo,
    COUNT(d.id_defi) AS nombre_defis,
    COALESCE(SUM(d.montant_palier), 0) AS montant_total_engage
FROM streamer s
LEFT JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
LEFT JOIN defi d
    ON pd.id_defi = d.id_defi
GROUP BY
    s.id_streamer,
    s.pseudo
ORDER BY
    montant_total_engage DESC,
    nombre_defis DESC,
    s.pseudo ASC;

-- ============================================
-- 5. Streamers avec leurs creneaux
--    et le nombre de streams par creneau
-- ============================================

SELECT
    s.id_streamer,
    s.pseudo,
    c.id_creneau,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    COUNT(st.id_stream) AS nombre_streams_sur_creneau
FROM streamer s
INNER JOIN creneau c
    ON s.id_streamer = c.id_streamer
LEFT JOIN stream st
    ON c.id_creneau = st.id_creneau
GROUP BY
    s.id_streamer,
    s.pseudo,
    c.id_creneau,
    c.date_debut_autorisee,
    c.date_fin_autorisee
ORDER BY
    s.pseudo ASC,
    c.date_debut_autorisee ASC;

-- ============================================
-- 6. Defis avec liste des participants
--    Utilisation de STRING_AGG pour rendre le resultat plus lisible
-- ============================================

SELECT
    d.id_defi,
    d.intitule,
    d.montant_palier,
    COUNT(s.id_streamer) AS nombre_participants,
    STRING_AGG(s.pseudo, ', ' ORDER BY s.pseudo) AS participants
FROM defi d
LEFT JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
LEFT JOIN streamer s
    ON pd.id_streamer = s.id_streamer
GROUP BY
    d.id_defi,
    d.intitule,
    d.montant_palier
ORDER BY
    nombre_participants DESC,
    d.id_defi ASC;

-- ============================================
-- 7. Streamers qui participent a un defi valide
-- ============================================

SELECT DISTINCT
    s.id_streamer,
    s.pseudo
FROM streamer s
INNER JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
INNER JOIN defi d
    ON pd.id_defi = d.id_defi
WHERE d.etat_validation = TRUE
ORDER BY
    s.pseudo ASC;

-- ============================================
-- 8. Streamers qui ne participent a aucun defi
-- ============================================

SELECT
    s.id_streamer,
    s.pseudo
FROM streamer s
LEFT JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
WHERE pd.id_defi IS NULL
ORDER BY
    s.pseudo ASC;
