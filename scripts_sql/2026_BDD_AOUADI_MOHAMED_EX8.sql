-- ============================================
-- Exercice 8 : Analyse de performance et creation d'index
-- Realise par : AOUADI Mohamed
-- Date : 2026-06-01
-- ============================================

-- Objectif :
-- Charger un grand volume de donnees, analyser une requete complexe
-- avec EXPLAIN ANALYZE, creer des index, puis comparer les performances.

-- ATTENTION :
-- Ce script remplace les petites donnees de test de l'exercice 1
-- par des donnees massives.
-- Pour revenir aux petites donnees, il suffit de relancer EX1 apres EX8.

-- ============================================
-- 1. Reinitialisation des tables
-- ============================================

TRUNCATE TABLE stream, participation_defi, creneau, defi, streamer
RESTART IDENTITY CASCADE;

-- ============================================
-- 2. Insertion de 50 000 streamers
-- ============================================

DO $$
BEGIN
    FOR i IN 1..50000 LOOP
        INSERT INTO streamer (pseudo, url_twitch)
        VALUES (
            'pseudo_' || i,
            'https://twitch.tv/pseudo_' || i
        );
    END LOOP;
END $$;

-- ============================================
-- 3. Insertion de 50 000 defis
-- ============================================

DO $$
BEGIN
    FOR i IN 1..50000 LOOP
        INSERT INTO defi (intitule, montant_palier, etat_validation)
        VALUES (
            'defi_' || i,
            (random() * 50000)::DECIMAL(12,2) + 500,
            (random() < 0.5)
        );
    END LOOP;
END $$;

-- ============================================
-- 4. Insertion de 250 000 participations
-- Utilisation de ON CONFLICT DO NOTHING pour eviter les doublons
-- sur la cle primaire composee.
-- ============================================

DO $$
BEGIN
    FOR i IN 1..250000 LOOP
        INSERT INTO participation_defi (id_streamer, id_defi)
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            FLOOR(random() * 50000 + 1)::INT
        )
        ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

-- ============================================
-- 5. Insertion de 100 000 creneaux
-- ============================================

DO $$
DECLARE
    start_date TIMESTAMP;
    end_date TIMESTAMP;
BEGIN
    FOR i IN 1..100000 LOOP
        start_date := TIMESTAMP '2025-09-05 18:00:00'
                      + (random() * 48)::INT * INTERVAL '1 hour';

        end_date := start_date
                    + (random() * 4 + 1)::INT * INTERVAL '1 hour';

        INSERT INTO creneau (
            id_streamer,
            date_debut_autorisee,
            date_fin_autorisee
        )
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            start_date,
            end_date
        );
    END LOOP;
END $$;

-- ============================================
-- 6. Insertion de 100 000 streams
-- ============================================

DO $$
DECLARE
    start_date TIMESTAMP;
    end_date TIMESTAMP;
    effective_end_date TIMESTAMP;
BEGIN
    FOR i IN 1..100000 LOOP
        start_date := TIMESTAMP '2025-09-05 18:00:00'
                      + (random() * 48)::INT * INTERVAL '1 hour';

        end_date := start_date
                    + (random() * 4 + 1)::INT * INTERVAL '1 hour';

        effective_end_date := CASE
            WHEN random() < 0.7
            THEN end_date
            ELSE end_date + (random() * 3)::INT * INTERVAL '1 hour'
        END;

        INSERT INTO stream (
            id_streamer,
            id_creneau,
            titre,
            heure_debut,
            heure_fin,
            date_fin_effective
        )
        VALUES (
            FLOOR(random() * 50000 + 1)::INT,
            FLOOR(random() * 100000 + 1)::INT,
            'Stream caritatif ' || i,
            start_date,
            end_date,
            effective_end_date
        );
    END LOOP;
END $$;

-- ============================================
-- 7. Verification du volume de donnees
-- ============================================

SELECT COUNT(*) AS nb_streamers FROM streamer;
SELECT COUNT(*) AS nb_defis FROM defi;
SELECT COUNT(*) AS nb_participations FROM participation_defi;
SELECT COUNT(*) AS nb_creneaux FROM creneau;
SELECT COUNT(*) AS nb_streams FROM stream;

-- ============================================
-- 8. Requete complexe SANS index
-- Executer cette requete avant la creation des index
-- et noter le Planning Time et Execution Time dans les commentaires.
-- ============================================

EXPLAIN ANALYZE
SELECT
    s.pseudo,
    d.intitule,
    COUNT(st.id_stream) AS nb_streams,
    COUNT(
        CASE
            WHEN st.date_fin_effective > st.heure_fin THEN 1
        END
    ) AS nb_depassements
FROM streamer s
JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
JOIN defi d
    ON pd.id_defi = d.id_defi
LEFT JOIN stream st
    ON s.id_streamer = st.id_streamer
WHERE (s.id_streamer + 0) < 5000
GROUP BY
    s.id_streamer,
    s.pseudo,
    d.id_defi,
    d.intitule
ORDER BY
    s.pseudo,
    d.intitule;

-- Observation avant index :
-- Planning Time : A_COMPLETER ms
-- Execution Time : A_COMPLETER ms
-- Scans observes : A_COMPLETER
-- Operations couteuses : A_COMPLETER

-- ============================================
-- 9. Creation des index
-- ============================================

CREATE INDEX IF NOT EXISTS idx_participation_defi_id_streamer
    ON participation_defi(id_streamer);

CREATE INDEX IF NOT EXISTS idx_participation_defi_id_defi
    ON participation_defi(id_defi);

CREATE INDEX IF NOT EXISTS idx_stream_id_streamer
    ON stream(id_streamer);

CREATE INDEX IF NOT EXISTS idx_stream_date_fin_effective
    ON stream(date_fin_effective);

CREATE INDEX IF NOT EXISTS idx_stream_id_streamer_date_fin_effective
    ON stream(id_streamer, date_fin_effective);

-- Mise a jour des statistiques pour aider l'optimiseur PostgreSQL
ANALYZE;

-- ============================================
-- 10. Meme requete APRES index
-- ============================================

EXPLAIN ANALYZE
SELECT
    s.pseudo,
    d.intitule,
    COUNT(st.id_stream) AS nb_streams,
    COUNT(
        CASE
            WHEN st.date_fin_effective > st.heure_fin THEN 1
        END
    ) AS nb_depassements
FROM streamer s
JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
JOIN defi d
    ON pd.id_defi = d.id_defi
LEFT JOIN stream st
    ON s.id_streamer = st.id_streamer
WHERE (s.id_streamer + 0) < 5000
GROUP BY
    s.id_streamer,
    s.pseudo,
    d.id_defi,
    d.intitule
ORDER BY
    s.pseudo,
    d.intitule;

-- Observation apres index :
-- Planning Time : A_COMPLETER ms
-- Execution Time : A_COMPLETER ms
-- Scans observes : A_COMPLETER
-- Gain de performance : A_COMPLETER %

-- ============================================
-- 11. Bonus : index trigram pour les recherches LIKE
-- ============================================

CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX IF NOT EXISTS idx_streamer_pseudo_trgm
    ON streamer USING gin (pseudo gin_trgm_ops);

EXPLAIN ANALYZE
SELECT
    s.pseudo,
    COUNT(pd.id_defi) AS nb_defis
FROM streamer s
LEFT JOIN participation_defi pd
    ON s.id_streamer = pd.id_streamer
WHERE s.pseudo LIKE '%pseudo%1%'
GROUP BY
    s.id_streamer,
    s.pseudo;

-- ============================================
-- 12. Conclusion
-- ============================================

-- Les index les plus utiles sont ceux places sur les cles etrangeres
-- utilisees dans les jointures : participation_defi(id_streamer),
-- participation_defi(id_defi) et stream(id_streamer).
--
-- Sans index, PostgreSQL doit parcourir beaucoup de lignes,
-- ce qui provoque des scans sequentiels et des jointures plus couteuses.
--
-- Apres creation des index, l'optimiseur peut retrouver plus rapidement
-- les lignes correspondant aux jointures et aux filtres.
--
-- Le gain exact doit etre complete apres execution dans PgAdmin,
-- en comparant le Planning Time et surtout l'Execution Time.
