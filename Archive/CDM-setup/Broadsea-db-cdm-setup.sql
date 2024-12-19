-- CDM: demo_cdm
-- Vocabulary: demo_cdm
-- Results: demo_cdm_results
-- Temp: webapi
--
--
-- Connect to the target database and execute the script
--\bash -c "psql -h postgres -p 5432 -U postgres -d ohdsi -f cdm_setup_script.sql"


\connect ohdsi
INSERT INTO webapi.source (source_id, source_name, source_key, source_connection, source_dialect, is_cache_enabled) 
SELECT nextval('webapi.source_sequence') , 'CMD-sample', 'CDM-sample', ' jdbc:postgresql://broadsea-db:5432/postgres?user=postgres&password=mypass', 'postgresql', true;
--nextval('webapi.source_sequence') was replaced by 1
INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 0, 'demo_cdm', 0
FROM webapi.source
WHERE source_key = 'CDM-sample'
;

INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 1, 'demo_cdm', 1
FROM webapi.source
WHERE source_key = 'CDM-sample'
;

INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 2, 'demo_cdm_results', 1
FROM webapi.source
WHERE source_key = 'CDM-sample'
;

INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 5, 'webapi', 0
FROM webapi.source
WHERE source_key = 'CDM-sample'
;
