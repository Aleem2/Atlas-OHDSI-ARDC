\connect ohdsi
INSERT INTO webapi.source (source_id, source_name, source_key, source_connection, source_dialect, is_cache_enabled) 
SELECT nextval('webapi.source_sequence') , 'CMD-sample', 'CDM-sample', ' jdbc:postgresql://postgres:5432/cdm?user=webapi_sa&password=webapi_sa1', 'postgresql', true;
--nextval('webapi.source_sequence') was replaced by 1
INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 0, 'cdm', 0
FROM webapi.source
WHERE source_key = 'CDM-sample'
;

INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 1, 'vocab', 1
FROM webapi.source
WHERE source_key = 'CDM-sample'
;

INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 2, 'results', 1
FROM webapi.source
WHERE source_key = 'CDM-sample'
;

INSERT INTO webapi.source_daimon (source_daimon_id, source_id, daimon_type, table_qualifier, priority) 
SELECT nextval('webapi.source_daimon_sequence'), source_id, 5, 'temp', 0
FROM webapi.source
WHERE source_key = 'CDM-sample'
;