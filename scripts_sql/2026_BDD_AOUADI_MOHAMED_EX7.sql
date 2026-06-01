-- ============================================
-- Exercice 7 : Gestion des validations avec CASE
-- Realise par : AOUADI Mohamed
-- Date : 2026-06-01
-- ============================================

-- Objectif :
-- Verifier si les streams respectent les creneaux autorises
-- et detecter les depassements de fin effective.

-- ============================================
-- 1. Validation des streams par rapport aux creneaux
--    Statut VALIDE :
--    heure_debut >= date_debut_autorisee
--    ET heure_fin <= date_fin_autorisee.
--    Sinon, statut INVALIDE.
-- ============================================

SELECT
    st.titre,
    s.pseudo AS streamer,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin,
    CASE
        WHEN st.heure_debut >= c.date_debut_autorisee
         AND st.heure_fin <= c.date_fin_autorisee
        THEN 'VALIDE'
        ELSE 'INVALIDE'
    END AS statut_creneau
FROM stream st
INNER JOIN streamer s
    ON st.id_streamer = s.id_streamer
INNER JOIN creneau c
    ON st.id_creneau = c.id_creneau
ORDER BY
    st.heure_debut ASC;


-- ============================================
-- 2. Identification des streams invalides
--    Cette requete peut retourner 0 ligne
--    si tous les streams respectent les creneaux.
-- ============================================

SELECT
    st.titre,
    s.pseudo AS streamer,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin
FROM stream st
INNER JOIN streamer s
    ON st.id_streamer = s.id_streamer
INNER JOIN creneau c
    ON st.id_creneau = c.id_creneau
WHERE st.heure_debut < c.date_debut_autorisee
   OR st.heure_fin > c.date_fin_autorisee
ORDER BY
    st.heure_debut ASC;


-- ============================================
-- 3. Detection des depassements de fin
--    Statut OK ou DEPASSEMENT avec CASE.
--    La duree du depassement est affichee en minutes.
-- ============================================

SELECT
    st.titre,
    s.pseudo AS streamer,
    st.heure_fin AS heure_fin_prevue,
    st.date_fin_effective,
    CASE
        WHEN st.date_fin_effective IS NOT NULL
         AND st.date_fin_effective > st.heure_fin
        THEN 'DEPASSEMENT'
        ELSE 'OK'
    END AS statut_fin,
    CASE
        WHEN st.date_fin_effective IS NOT NULL
         AND st.date_fin_effective > st.heure_fin
        THEN ROUND(
            (EXTRACT(EPOCH FROM (st.date_fin_effective - st.heure_fin)) / 60)::numeric,
            2
        )
        ELSE 0
    END AS depassement_minutes
FROM stream st
INNER JOIN streamer s
    ON st.id_streamer = s.id_streamer
ORDER BY
    st.heure_debut ASC;


-- ============================================
-- 4. Resume des retards
--    Afficher le nombre de streams en retard
--    et la duree moyenne de retard.
-- ============================================

SELECT
    COUNT(*) FILTER (
        WHERE date_fin_effective IS NOT NULL
        AND date_fin_effective > heure_fin
    ) AS nombre_streams_en_retard,

    ROUND(
        AVG(
            CASE
                WHEN date_fin_effective IS NOT NULL
                 AND date_fin_effective > heure_fin
                THEN EXTRACT(EPOCH FROM (date_fin_effective - heure_fin)) / 60
                ELSE NULL
            END
        )::numeric,
        2
    ) AS duree_moyenne_retard_minutes
FROM stream;


-- ============================================
-- 5. Apercu complet de la conformite des streams
--    Cette requete combine :
--    - validation du creneau
--    - detection du depassement
--    - calcul du depassement en minutes
-- ============================================

SELECT
    st.titre,
    s.pseudo AS streamer,
    c.date_debut_autorisee,
    c.date_fin_autorisee,
    st.heure_debut,
    st.heure_fin,
    st.date_fin_effective,

    CASE
        WHEN st.heure_debut >= c.date_debut_autorisee
         AND st.heure_fin <= c.date_fin_autorisee
        THEN 'VALIDE'
        ELSE 'INVALIDE'
    END AS statut_creneau,

    CASE
        WHEN st.date_fin_effective IS NOT NULL
         AND st.date_fin_effective > st.heure_fin
        THEN 'DEPASSEMENT'
        ELSE 'OK'
    END AS statut_fin,

    CASE
        WHEN st.date_fin_effective IS NOT NULL
         AND st.date_fin_effective > st.heure_fin
        THEN ROUND(
            (EXTRACT(EPOCH FROM (st.date_fin_effective - st.heure_fin)) / 60)::numeric,
            2
        )
        ELSE 0
    END AS depassement_minutes

FROM stream st
INNER JOIN streamer s
    ON st.id_streamer = s.id_streamer
INNER JOIN creneau c
    ON st.id_creneau = c.id_creneau
ORDER BY
    st.heure_debut ASC;
