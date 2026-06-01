-- ============================================
-- Exercice 5 : Requetes UPDATE et DELETE
-- Realise par : AOUADI Mohamed
-- Date : 2026-06-01
-- ============================================

-- Objectif :
-- Modifier et supprimer des donnees dans la base.
-- Les suppressions sont placees dans des transactions avec ROLLBACK
-- pour eviter de casser les donnees necessaires aux exercices suivants.

-- ============================================
-- 1. Augmenter de 10% le montant du defi
--    "Tournoi Mario Kart"
-- ============================================

-- Verification avant modification
SELECT
    id_defi,
    intitule,
    montant_palier
FROM defi
WHERE intitule = 'Tournoi Mario Kart';

-- Modification
UPDATE defi
SET montant_palier = montant_palier * 1.10
WHERE intitule = 'Tournoi Mario Kart';

-- Verification apres modification
SELECT
    id_defi,
    intitule,
    montant_palier
FROM defi
WHERE intitule = 'Tournoi Mario Kart';

-- ============================================
-- 2. Valider les defis ayant au moins 3 participants
-- ============================================

-- Verification avant modification
SELECT
    d.id_defi,
    d.intitule,
    d.etat_validation,
    COUNT(pd.id_streamer) AS nombre_participants
FROM defi d
LEFT JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
GROUP BY
    d.id_defi,
    d.intitule,
    d.etat_validation
ORDER BY
    d.id_defi;

-- Modification
UPDATE defi
SET etat_validation = TRUE
WHERE id_defi IN (
    SELECT
        id_defi
    FROM participation_defi
    GROUP BY
        id_defi
    HAVING
        COUNT(id_streamer) >= 3
);

-- Verification apres modification
SELECT
    d.id_defi,
    d.intitule,
    d.etat_validation,
    COUNT(pd.id_streamer) AS nombre_participants
FROM defi d
LEFT JOIN participation_defi pd
    ON d.id_defi = pd.id_defi
GROUP BY
    d.id_defi,
    d.intitule,
    d.etat_validation
ORDER BY
    d.id_defi;

-- ============================================
-- 3. Supprimer les streams non termines
--    Ici on utilise ROLLBACK pour ne pas supprimer definitivement
--    les donnees utiles aux prochains exercices.
-- ============================================

BEGIN;

-- Verification avant suppression
SELECT
    id_stream,
    titre,
    date_fin_effective
FROM stream
WHERE date_fin_effective IS NULL;

-- Suppression
DELETE FROM stream
WHERE date_fin_effective IS NULL;

-- Verification apres suppression
SELECT
    id_stream,
    titre,
    date_fin_effective
FROM stream
WHERE date_fin_effective IS NULL;

-- Annulation volontaire pour garder les donnees
ROLLBACK;

-- Verification finale apres ROLLBACK
SELECT
    id_stream,
    titre,
    date_fin_effective
FROM stream
WHERE date_fin_effective IS NULL;

-- ============================================
-- 4. Supprimer les creneaux passes sans stream associe
--    Ici aussi on utilise ROLLBACK par prudence.
-- ============================================

BEGIN;

-- Verification des creneaux passes sans stream associe
SELECT
    c.id_creneau,
    c.id_streamer,
    c.date_debut_autorisee,
    c.date_fin_autorisee
FROM creneau c
LEFT JOIN stream st
    ON c.id_creneau = st.id_creneau
WHERE c.date_fin_autorisee < '2025-09-08 23:59:59'
AND st.id_stream IS NULL;

-- Suppression des creneaux passes sans stream associe
DELETE FROM creneau
WHERE id_creneau IN (
    SELECT
        c.id_creneau
    FROM creneau c
    LEFT JOIN stream st
        ON c.id_creneau = st.id_creneau
    WHERE c.date_fin_autorisee < '2025-09-08 23:59:59'
    AND st.id_stream IS NULL
);

-- Verification apres suppression
SELECT
    c.id_creneau,
    c.id_streamer,
    c.date_debut_autorisee,
    c.date_fin_autorisee
FROM creneau c
LEFT JOIN stream st
    ON c.id_creneau = st.id_creneau
WHERE c.date_fin_autorisee < '2025-09-08 23:59:59'
AND st.id_stream IS NULL;

-- Annulation volontaire pour garder les donnees
ROLLBACK;

-- ============================================
-- 5. Verification finale des volumes de donnees
-- ============================================

SELECT COUNT(*) AS nb_streamers FROM streamer;
SELECT COUNT(*) AS nb_creneaux FROM creneau;
SELECT COUNT(*) AS nb_defis FROM defi;
SELECT COUNT(*) AS nb_participations FROM participation_defi;
SELECT COUNT(*) AS nb_streams FROM stream;
