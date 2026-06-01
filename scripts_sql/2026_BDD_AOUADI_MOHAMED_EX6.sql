-- ============================================
-- Exercice 6 : Requetes avancees sur relation M:N
-- Realise par : AOUADI Mohamed
-- Date : 2026-06-01
-- ============================================

-- Objectif :
-- Exploiter la relation plusieurs-a-plusieurs entre
-- les streamers et les defis grace a la table
-- participation_defi.
--
-- Les requetes utilisent :
-- LEFT JOIN, HAVING, NOT EXISTS, COALESCE
-- et des agregations avancees.

-- ============================================
-- 1. Streamers ayant au moins un defi
--    Afficher le pseudo du streamer
--    et le nombre de defis auxquels il participe.
-- ============================================

SELECT
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
-- 2. Defis n'ayant aucun participant
--    Version avec NOT EXISTS.
-- ============================================

SELECT
    d.intitule,
    d.montant_palier
FROM defi d
WHERE NOT EXISTS (
    SELECT 1
    FROM participation_defi pd
    WHERE pd.id_defi = d.id_defi
)
ORDER BY
    d.montant_palier DESC;


-- ============================================
-- 3. Defis ayant plus de 2 streamers participants
--    Afficher l'intitule, le montant
--    et le nombre de participants.
-- ============================================

SELECT
    d.intitule,
    d.montant_palier,
    COALESCE(COUNT(pd.id_streamer), 0) AS nombre_participants
FROM defi d
LEFT JOIN participation_defi pd
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
--    avec le montant total engage.
--    Ordonner par montant total decroissant.
-- ============================================

SELECT
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
-- 5. Streamers et creneaux avec nombre
--    de streams effectues par creneau.
--    Afficher le pseudo, les dates du creneau
--    et le nombre de streams.
-- ============================================

SELECT
    s.pseudo,
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
