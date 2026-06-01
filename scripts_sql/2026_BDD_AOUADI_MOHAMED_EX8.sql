-- ============================================
-- Exercice 8 : Performance et indexation
-- Realise par : AOUADI Mohamed
-- Date : 2026-06-01
-- ============================================

-- Ce script charge un volume important de donnees,
-- execute une requete complexe avant indexation,
-- cree plusieurs index utiles, puis relance la meme requete.
-- Les temps d'execution sont visibles directement dans les deux
-- sorties EXPLAIN ANALYZE de PgAdmin.

-- Si besoin, relancer EX1 apres cet exercice pour retrouver
-- les petites donnees de depart.


-- ============================================
-- 1. Nettoyage des index de test
-- ============================================

DROP INDEX IF EXISTS idx_perf_participation_streamer;
DROP INDEX IF EXISTS idx_perf_participation_defi;
DROP INDEX IF EXISTS idx_perf_stream_streamer;
DROP INDEX IF EXISTS idx_perf_stream_fin_effective;
DROP INDEX IF EXISTS idx_perf_stream_streamer_fin;
DROP INDEX IF EXISTS idx_perf_creneau_streamer;


-- ============================================
-- 2. Reinitialisation des tables
-- ============================================

TRUNCATE TABLE stream, participation_defi, creneau, defi, streamer
RESTART IDENTITY CASCADE;


-- ============================================
-- 3. Insertion des streamers
-- ============================================

INSERT INTO streamer (pseudo, url_twitch)
SELECT
    'streamer_' || gs,
    'https://twitch.tv/streamer_' || gs
FROM generate_series(1, 50000) AS gs;


-- ============================================
-- 4. Insertion des defis
-- ============================================

INSERT INTO defi (intitule, montant_palier, etat_validation)
SELECT
    'Defi caritatif ' || gs,
    ROUND((500 + random() * 50000)::numeric, 2),
    random() < 0.5
FROM generate_series(1, 50000) AS gs;


-- ============================================
-- 5. Insertion des creneaux
-- ============================================

INSERT INTO creneau (
    id_streamer,
    date_debut_autorisee,
    date_fin_autorisee
)
SELECT
    ((gs - 1) % 50000) + 1,
    TIMESTAMP '2025-09-05 08:00:00'
        + ((gs % 72) * INTERVAL '1 hour'),
    TIMESTAMP '2025-09-05 08:00:00'
        + ((gs % 72) * INTERVAL '1 hour')
        + INTERVAL '3 hours'
FROM generate_series(1, 150000) AS gs;


-- ============================================
-- 6. Insertion des participations aux defis
-- ============================================

INSERT INTO participation_defi (id_streamer, id_defi)
SELECT DISTINCT
    ((gs * 17) % 50000) + 1 AS id_streamer,
    ((gs * 31) % 50000) + 1 AS id_defi
FROM generate_series(1, 300000) AS gs
ON CONFLICT DO NOTHING;


-- ============================================
-- 7. Insertion des streams
-- ============================================

INSERT INTO stream (
    id_streamer,
    id_creneau,
    titre,
    heure_debut,
    heure_fin,
    date_fin_effective
)
SELECT
    ((gs - 1) % 50000) + 1 AS id_streamer,
    ((gs - 1) % 150000) + 1 AS id_creneau,
    'Stream caritatif ' || gs AS titre,
    TIMESTAMP '2025-09-05 08:15:00'
        + ((gs % 72) * INTERVAL '1 hour') AS heure_debut,
    TIMESTAMP '2025-09-05 08:15:00'
        + ((gs % 72) * INTERVAL '1 hour')
        + INTERVAL '2 hours' AS heure_fin,
    CASE
        WHEN gs % 5 = 0 THEN NULL
        WHEN gs % 3 = 0 THEN
            TIMESTAMP '2025-09-05 08:15:00'
            + ((gs % 72) * INTERVAL '1 hour')
            + INTERVAL '2 hours 30 minutes'
        ELSE
            TIMESTAMP '2025-09-05 08:15:00'
            + ((gs % 72) * INTERVAL '1 hour')
            + INTERVAL '2 hours'
    END AS date_fin_effective
FROM generate_series(1, 150000) AS gs;


-- ============================================
-- 8. Verification du volume de donnees
-- ============================================

SELECT COUNT(*) AS nb_streamers FROM streamer;
SELECT COUNT(*) AS nb_defis FROM defi;
SELECT COUNT(*) AS nb_creneaux FROM creneau;
SELECT COUNT(*) AS nb_participations FROM participation_defi;
SELECT COUNT(*) AS nb_streams FROM stream;


-- ============================================
-- 9. Mise a jour des statistiques avant analyse
-- ============================================

ANALYZE streamer;
ANALYZE defi;
ANALYZE creneau;
ANALYZE participation_defi;
ANALYZE stream;


-- ============================================
-- 10. Requete complexe avant creation des index
-- ============================================

-- Cette premiere analyse permet d'observer le plan choisi
-- par PostgreSQL avant l'ajout des index sur les cles etrangeres.

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    s.pseudo,
    COUNT(DISTINCT st.id_stream) AS nombre_streams,
    COUNT(DISTINCT pd.id_defi) AS nombre_defis,
    COUNT(
        CASE
            WHEN st.date_fin_effective IS NOT NULL
             AND st.date_fin_effective > st.heure_fin
            THEN 1
        END
    ) AS nombre_depassements,
    COALESCE(SUM(d.montant_palier), 0) AS montant_total_defis
FROM streamer s
LEFT JOIN stream st
    ON s.id_streamer = st.id_streamer
LEFT JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
LEFT JOIN defi d
    ON pd.id_defi = d.id_defi
WHERE s.id_streamer BETWEEN 1 AND 10000
GROUP BY
    s.id_streamer,
    s.pseudo
ORDER BY
    montant_total_defis DESC,
    nombre_streams DESC;


-- ============================================
-- 11. Creation des index
-- ============================================

CREATE INDEX idx_perf_participation_streamer
    ON participation_defi(id_streamer);

CREATE INDEX idx_perf_participation_defi
    ON participation_defi(id_defi);

CREATE INDEX idx_perf_stream_streamer
    ON stream(id_streamer);

CREATE INDEX idx_perf_stream_fin_effective
    ON stream(date_fin_effective);

CREATE INDEX idx_perf_stream_streamer_fin
    ON stream(id_streamer, date_fin_effective);

CREATE INDEX idx_perf_creneau_streamer
    ON creneau(id_streamer);


-- ============================================
-- 12. Mise a jour des statistiques apres indexation
-- ============================================

ANALYZE streamer;
ANALYZE defi;
ANALYZE creneau;
ANALYZE participation_defi;
ANALYZE stream;


-- ============================================
-- 13. Meme requete apres creation des index
-- ============================================

-- Cette deuxieme analyse permet de comparer le nouveau plan
-- avec celui obtenu avant indexation.

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    s.pseudo,
    COUNT(DISTINCT st.id_stream) AS nombre_streams,
    COUNT(DISTINCT pd.id_defi) AS nombre_defis,
    COUNT(
        CASE
            WHEN st.date_fin_effective IS NOT NULL
             AND st.date_fin_effective > st.heure_fin
            THEN 1
        END
    ) AS nombre_depassements,
    COALESCE(SUM(d.montant_palier), 0) AS montant_total_defis
FROM streamer s
LEFT JOIN stream st
    ON s.id_streamer = st.id_streamer
LEFT JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
LEFT JOIN defi d
    ON pd.id_defi = d.id_defi
WHERE s.id_streamer BETWEEN 1 AND 10000
GROUP BY
    s.id_streamer,
    s.pseudo
ORDER BY
    montant_total_defis DESC,
    nombre_streams DESC;


-- ============================================
-- 14. Requete ciblee sur les streams en depassement
-- ============================================

-- Cette requete montre l'interet des index sur les colonnes
-- utilisees pour filtrer ou joindre les donnees.

EXPLAIN (ANALYZE, BUFFERS)
SELECT
    s.pseudo,
    st.titre,
    st.heure_fin,
    st.date_fin_effective,
    ROUND(
        (EXTRACT(EPOCH FROM (st.date_fin_effective - st.heure_fin)) / 60)::numeric,
        2
    ) AS depassement_minutes
FROM stream st
INNER JOIN streamer s
    ON st.id_streamer = s.id_streamer
WHERE st.date_fin_effective IS NOT NULL
AND st.date_fin_effective > st.heure_fin
AND st.id_streamer BETWEEN 1 AND 10000
ORDER BY
    depassement_minutes DESC;


-- ============================================
-- 15. Conclusion
-- ============================================

-- Les index crees portent principalement sur les cles etrangeres
-- utilisees dans les jointures :
-- participation_defi(id_streamer), participation_defi(id_defi),
-- stream(id_streamer) et creneau(id_streamer).
--
-- L'index compose stream(id_streamer, date_fin_effective)
-- aide les requetes qui filtrent les streams d'un streamer
-- et qui analysent les dates de fin effective.
--
-- La comparaison des deux sorties EXPLAIN ANALYZE permet
-- d'observer l'evolution du plan d'execution, notamment le passage
-- de parcours sequentiels vers des parcours indexes lorsque
-- PostgreSQL les juge avantageux.
