
-- This scripts contains following view/synonym's definition:
-- =============================================================================
-- ALL_CATALOG
-- ALL_CONS_COLUMNS
-- ALL_CONSTRAINTS
-- ALL_DEPENDENCIES
-- ALL_IND_COLUMNS
-- ALL_IND_PARTITIONS
-- ALL_IND_STATISTICS
-- ALL_INDEX_USAGE
-- ALL_INDEXES
-- ALL_OBJECTS
-- ALL_PART_INDEXES
-- ALL_PART_TABLES
-- ALL_PROCEDURES
-- ALL_SEGMENTS
-- ALL_SEQUENCES
-- ALL_SOURCE
-- ALL_SYNONYMS
-- ALL_TAB_COL_STATISTICS
-- ALL_TAB_COLS
-- ALL_TAB_COLUMNS
-- ALL_TAB_COMMENTS
-- ALL_TAB_MODIFICATIONS
-- ALL_TAB_PARTITIONS
-- ALL_TAB_STATISTICS
-- ALL_TABLES
-- ALL_TRIGGER_COLS
-- ALL_TRIGGERS
-- ALL_TYPES
-- ALL_USERS
-- ALL_VIEWS

-- DBA_ALL_TABLES
-- DBA_CATALOG
-- DBA_CONS_COLUMNS
-- DBA_CONSTRAINTS
-- DBA_DEPENDENCIES
-- DBA_IND_COLUMNS
-- DBA_IND_PARTITIONS
-- DBA_IND_STATISTICS
-- DBA_INDEX_USAGE
-- DBA_INDEXES
-- DBA_OBJECTS
-- DBA_PART_INDEXES
-- DBA_PART_TABLES
-- DBA_PROCEDURES
-- DBA_SEGMENTS
-- DBA_SEQUENCES
-- DBA_SOURCE
-- DBA_SOURCE_ALL
-- DBA_SYNONYMS
-- DBA_TAB_COL_STATISTICS
-- DBA_TAB_COLS
-- DBA_TAB_COLUMNS
-- DBA_TAB_COMMENTS
-- DBA_TAB_MODIFICATIONS
-- DBA_TAB_PARTITIONS
-- DBA_TAB_STATISTICS
-- DBA_TABLES
-- DBA_TRIGGER_COLS
-- DBA_TRIGGERS
-- DBA_TYPES
-- DBA_USERS
-- DBA_VIEWS

-- USER_CATALOG
-- USER_CONS_COLUMNS
-- USER_CONSTRAINTS
-- USER_DEPENDENCIES
-- USER_IND_COLUMNS
-- USER_IND_PARTITIONS
-- USER_IND_STATISTICS
-- USER_INDEX_USAGE
-- USER_INDEXES
-- USER_OBJECTS
-- USER_PART_INDEXES
-- USER_PART_TABLES
-- USER_PROCEDURES
-- USER_SEGMENTS
-- USER_SEQUENCES
-- USER_SOURCE
-- USER_SYNONYMS
-- USER_TAB_COL_STATISTICS
-- USER_TAB_COLS
-- USER_TAB_COLUMNS
-- USER_TAB_COMMENTS
-- USER_TAB_MODIFICATIONS
-- USER_TAB_PARTITIONS
-- USER_TAB_STATISTICS
-- USER_TABLES
-- USER_TRIGGER_COLS
-- USER_TRIGGERS
-- USER_TYPES
-- USER_VIEWS

-- DICTIONARY
-- DICT
-- COLS
-- IND
-- OBJ
-- TAB

-- GV$PARAMETER
-- GV$PARAMETER_VALID_VALUES
-- GV$SESSION
-- GV$SPPARAMETER
-- V$PARAMETER
-- V$PARAMETER_VALID_VALUES
-- V$SESSION
-- V$SPPARAMETER

-- DBA_DETAIL_PRIVILEGES
-- DBA_ALL_PRIVILEGES
-- DBA_ALL_PRIVILEGES_SQL
-- =============================================================================

do $$
declare
  l_cnt  bigint;
begin
  select count(*) into l_cnt from pg_catalog.pg_namespace where nspname = 'oracle';
  if l_cnt = 0
  then
    create schema oracle;
  end if;
end;
$$ language plpgsql;


-- =============================================================================
-- DBA_SEQUENCES
-- ALL_SEQUENCES
-- USER_SEQUENCES
-- =============================================================================
drop function if exists oracle.mg_sequence() cascade;
create or replace function oracle.mg_sequence()
returns setof record
language plpgsql
as $$
declare
    l_seq_item   record;
begin
    for l_seq_item in SELECT nc.nspname as owner,
                             c.relname AS sequence_name
                        FROM pg_catalog.pg_namespace nc
                        join pg_catalog.pg_class c on c.relnamespace = nc.oid
                      WHERE c.relkind = 'S'::"char"
                        AND NOT pg_is_other_temp_schema(nc.oid)
                        AND (pg_has_role(c.relowner, 'USAGE'::text) OR has_sequence_privilege(c.oid, 'SELECT, UPDATE, USAGE'::text))
    loop
        return query execute 'select tableoid, '''||l_seq_item.owner||''' as owner, sequence_name, last_value, start_value, increment_by, max_value, min_value, cache_value, is_cycled from '||l_seq_item.owner||'.'||l_seq_item.sequence_name;
    end loop;
end;
$$;

DROP VIEW IF EXISTS oracle.DBA_SEQUENCES CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_SEQUENCES
AS
select sequence_oid as sequence_oid
     , case when owner::text = lower(owner::text) then UPPER(owner::text) else owner::text end AS SEQUENCE_OWNER
     , case when sequence_name::text = lower(sequence_name::text) then UPPER(sequence_name::text) else sequence_name::text end AS SEQUENCE_NAME
     , min_value
     , max_value
     , increment_by
     , case when is_cycled then 'Y' else 'N' end AS CYCLE_FLAG
     , cache_value as CACHE_SIZE
     , last_value AS LAST_NUMBER
     , start_value
  from oracle.mg_sequence()
    as ( sequence_oid oid
       , owner text
       , sequence_name name
       , last_value bigint
       , start_value bigint
       , increment_by bigint
       , max_value bigint
       , min_value bigint
       , cache_value bigint
       , is_cycled boolean);

DROP VIEW IF EXISTS oracle.USER_SEQUENCES CASCADE;
CREATE OR REPLACE VIEW oracle.USER_SEQUENCES AS SELECT sequence_oid, SEQUENCE_NAME , min_value, max_value, increment_by, CYCLE_FLAG, CACHE_SIZE, LAST_NUMBER, start_value
  FROM oracle.DBA_SEQUENCES WHERE SEQUENCE_OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_SEQUENCES for oracle.DBA_SEQUENCES;
CREATE OR REPLACE SYNONYM public.ALL_SEQUENCES for oracle.DBA_SEQUENCES;
CREATE OR REPLACE SYNONYM public.USER_SEQUENCES for oracle.USER_SEQUENCES;




-- =============================================================================
-- DBA_SYNONYMS
-- ALL_SYNONYMS
-- USER_SYNONYMS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_SYNONYMS CASCADE;
create or replace view oracle.DBA_SYNONYMS
AS
SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS OWNER
     , case when s.synname::text = lower(s.synname::text) then UPPER(s.synname::text) else s.synname::text end AS SYNONYM_NAME
     , case when s.synobjschema::text = lower(s.synobjschema::text) then UPPER(s.synobjschema::text) else s.synobjschema::text end AS TABLE_OWNER
     , case when s.synobjname::text = lower(s.synobjname::text) then UPPER(s.synobjname::text) else s.synobjname::text end AS TABLE_NAME
  from pg_catalog.pg_synonym as s
  join pg_catalog.pg_namespace as n on s.synnamespace = n.oid;

DROP VIEW IF EXISTS oracle.USER_SYNONYMS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_SYNONYMS AS SELECT SYNONYM_NAME, TABLE_OWNER , TABLE_NAME FROM oracle.DBA_SYNONYMS WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_SYNONYMS for oracle.DBA_SYNONYMS;
CREATE OR REPLACE SYNONYM public.ALL_SYNONYMS for oracle.DBA_SYNONYMS;
CREATE OR REPLACE SYNONYM public.USER_SYNONYMS for oracle.USER_SYNONYMS;




-- =============================================================================
-- DBA_TAB_COLS
-- ALL_TAB_COLS
-- USER_TAB_COLS
-- COLS
-- DBA_TAB_COLUMNS
-- ALL_TAB_COLUMNS
-- USER_TAB_COLUMNS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_TAB_COLS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TAB_COLS
AS
SELECT case when nsp.nspname::text = lower(nsp.nspname::text) then UPPER(nsp.nspname::text) else nsp.nspname::text end AS OWNER
     , case when cls.relname::text = lower(cls.relname::text) then UPPER(cls.relname::text) else cls.relname::text end AS TABLE_NAME
     , case when att.attname::text = lower(att.attname::text) then UPPER(att.attname::text) else att.attname::text end AS COLUMN_NAME
     , case when typ.typname::text = lower(typ.typname::text) then UPPER(typ.typname::text) else typ.typname::text end AS DATA_TYPE
     , case when tnsp.nspname::text = lower(tnsp.nspname::text) then UPPER(tnsp.nspname::text) else tnsp.nspname::text end AS DATA_TYPE_OWNER
     , translate(case when typ.typmodout='bpchartypmodout'::regproc then bpchartypmodout(att.atttypmod)::text
            when typ.typmodout='varchartypmodout'::regproc then varchartypmodout(att.atttypmod)::text
            when typ.typmodout='timetypmodout'::regproc then timetypmodout(att.atttypmod)::text
            when typ.typmodout='timestamptypmodout'::regproc then timestamptypmodout(att.atttypmod)::text
            when typ.typmodout='timestamptztypmodout'::regproc then timestamptztypmodout(att.atttypmod)::text
            when typ.typmodout='intervaltypmodout'::regproc then intervaltypmodout(att.atttypmod)::text
            when typ.typmodout='timetztypmodout'::regproc then timetztypmodout(att.atttypmod)::text
            when typ.typmodout='bittypmodout'::regproc then bittypmodout(att.atttypmod)::text
            when typ.typmodout='varbittypmodout'::regproc then varbittypmodout(att.atttypmod)::text
            when typ.typmodout='numerictypmodout'::regproc then numerictypmodout(att.atttypmod)::text
            when typ.typmodout='nvarchar2typmodout'::regproc then nvarchar2typmodout(att.atttypmod)::text
            when typ.typmodout='byteawithoutorderwithequalcoltypmodout'::regproc then byteawithoutorderwithequalcoltypmodout(att.atttypmod)::text
            else null end,'()','') as DATA_LENGTH
     , information_schema._pg_char_octet_length(information_schema._pg_truetypid(att.*, typ.*), information_schema._pg_truetypmod(att.*, typ.*)) as DATA_LENGTH_OCTET
     , information_schema._pg_numeric_precision(information_schema._pg_truetypid(att.*, typ.*), information_schema._pg_truetypmod(att.*, typ.*)) as DATA_PRECISION
     , information_schema._pg_numeric_scale(information_schema._pg_truetypid(att.*, typ.*), information_schema._pg_truetypmod(att.*, typ.*)) as DATA_SCALE
     , CASE when att.attnotnull THEN 'N'::text ELSE 'Y'::text END AS NULLABLE
     , att.attnum as COLUMN_ID
     , length(pg_get_expr(ad.adbin, ad.adrelid)) as DEFAULT_LENGTH
     , pg_get_expr(ad.adbin, ad.adrelid) as DATA_DEFAULT
     , CASE WHEN stat.n_distinct >= 0 THEN stat.n_distinct ELSE ROUND(ABS(stat.n_distinct * cls.RELTUPLES)) END as NUM_DISTINCT
     , stat.correlation
     , stat.NULL_FRAC * cls.RELTUPLES AS NUM_NULLS
     , stat.avg_width as AVG_COL_LEN
  FROM pg_catalog.pg_attribute att
  JOIN pg_catalog.pg_type typ on att.atttypid = typ.oid
  JOIN pg_catalog.pg_namespace tnsp on typ.typnamespace = tnsp.oid
  JOIN pg_catalog.pg_class cls ON att.attrelid = cls.oid
  JOIN pg_catalog.pg_namespace nsp on cls.relnamespace = nsp.oid
  LEFT JOIN pg_catalog.PG_STATS stat ON nsp.nspname = stat.schemaname AND cls.relname = stat.tablename AND att.attname = stat.attname
  LEFT JOIN pg_catalog.pg_attrdef ad ON att.attrelid = ad.adrelid AND att.attnum = ad.adnum
 WHERE nsp.nspname NOT LIKE 'pg_toast%'
   AND cls.relkind in ('r', 'v', 't', 'f');    -- 限制表和视图

DROP VIEW IF EXISTS oracle.USER_TAB_COLS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TAB_COLS
AS SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE, DATA_TYPE_OWNER, DATA_LENGTH, DATA_LENGTH_OCTET, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID, DEFAULT_LENGTH, DATA_DEFAULT, NUM_DISTINCT, CORRELATION, NUM_NULLS, AVG_COL_LEN
     FROM oracle.DBA_TAB_COLS WHERE OWNER  = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

DROP VIEW IF EXISTS oracle.DBA_TAB_COLUMNS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TAB_COLUMNS AS SELECT * FROM oracle.DBA_TAB_COLS WHERE COLUMN_ID >= 1;

DROP VIEW IF EXISTS oracle.USER_TAB_COLUMNS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TAB_COLUMNS AS SELECT * FROM oracle.USER_TAB_COLS WHERE COLUMN_ID >= 1;

CREATE OR REPLACE SYNONYM public.DBA_TAB_COLS for oracle.DBA_TAB_COLS;
CREATE OR REPLACE SYNONYM public.ALL_TAB_COLS for oracle.DBA_TAB_COLS;
CREATE OR REPLACE SYNONYM public.USER_TAB_COLS for oracle.USER_TAB_COLS;
CREATE OR REPLACE SYNONYM public.COLS for oracle.DBA_TAB_COLS;
CREATE OR REPLACE SYNONYM public.DBA_TAB_COLUMNS for oracle.DBA_TAB_COLUMNS;
CREATE OR REPLACE SYNONYM public.ALL_TAB_COLUMNS for oracle.DBA_TAB_COLUMNS;
CREATE OR REPLACE SYNONYM public.USER_TAB_COLUMNS for oracle.USER_TAB_COLUMNS;




-- =============================================================================
-- DBA_TAB_COL_STATISTICS
-- ALL_TAB_COL_STATISTICS
-- USER_TAB_COL_STATISTICS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_TAB_COL_STATISTICS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TAB_COL_STATISTICS
AS
SELECT OWNER
     , TABLE_NAME
     , COLUMN_NAME
     , NUM_DISTINCT
     , CORRELATION
     , NUM_NULLS
     , AVG_COL_LEN
  FROM oracle.DBA_TAB_COLUMNS;

DROP VIEW IF EXISTS oracle.USER_TAB_COL_STATISTICS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TAB_COL_STATISTICS AS SELECT TABLE_NAME , COLUMN_NAME, NUM_DISTINCT, CORRELATION, NUM_NULLS, AVG_COL_LEN FROM oracle.DBA_TAB_COL_STATISTICS WHERE OWNER  = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_TAB_COL_STATISTICS for oracle.DBA_TAB_COL_STATISTICS;
CREATE OR REPLACE SYNONYM public.ALL_TAB_COL_STATISTICS for oracle.DBA_TAB_COL_STATISTICS;
CREATE OR REPLACE SYNONYM public.USER_TAB_COL_STATISTICS for oracle.USER_TAB_COL_STATISTICS;




-- =============================================================================
-- DBA_OBJECTS
-- ALL_OBJECTS
-- USER_OBJECTS
-- OBJ
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_OBJECTS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_OBJECTS
AS
SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS owner
     , case when o1.object_name::text = lower(o1.object_name::text) then UPPER(o1.object_name::text) else o1.object_name::text end AS object_name
     , case when o1.SUBOBJECT_NAME::text = lower(o1.SUBOBJECT_NAME::text) then UPPER(o1.SUBOBJECT_NAME::text) else o1.SUBOBJECT_NAME::text end AS SUBOBJECT_NAME
     , o1.OBJECT_ID
     , o1.DATA_OBJECT_ID
     , o1.object_type
     , o2.ctime as CREATED
     , o2.mtime as LAST_DDL_TIME
     , o1.TEMPORARY
     , upper(u.usename) as creator
  FROM (SELECT relowner as creator
             , relnamespace AS owner
             , relname AS object_name
             , NULL as SUBOBJECT_NAME
             , oid AS OBJECT_ID
             , relfilenode as DATA_OBJECT_ID
             , CASE relkind
               WHEN 'r'::"char" THEN 'TABLE'::text
               WHEN 'v'::"char" THEN 'VIEW'::text
               WHEN 'i'::"char" THEN 'INDEX'::text
               WHEN 'I'::"char" THEN 'GLOBAL INDEX'::text
               WHEN 'S'::"char" THEN 'SEQUENCE'::text
               WHEN 'f'::"char" THEN 'FOREIGN TABLE'::text
               WHEN 'c'::"char" THEN 'COMPOSITE TYPE'::text
               WHEN 't'::"char" THEN 'TOAST'::text
               ELSE relkind::text
               END AS object_type
             , case when relpersistence = 't' THEN 'Y' else 'N' end as TEMPORARY
          FROM pg_catalog.pg_class
         UNION ALL
        SELECT pp.relowner as creator
             , pp.relnamespace AS owner
             , pp.relname AS object_name
             , p.relname as SUBOBJECT_NAME
             , p.oid AS OBJECT_ID
             , p.relfilenode as DATA_OBJECT_ID
             , CASE p.parttype
                    WHEN 'p'::"char" THEN 'TABLE PARTITION'::text
                    WHEN 'x'::"char" THEN 'INDEX PARTITION'::text
                    WHEN 't'::"char" THEN 'TOAST PARTITION'::text
                    ELSE p.parttype::text
                END AS object_type
             , 'N' as TEMPORARY
          FROM pg_catalog.pg_partition as p
          join pg_catalog.pg_class as pp on p.parentid = pp.oid
         where p.parttype in ('p', 'x', 't')
         UNION ALL
        SELECT proowner as creator
             , pronamespace AS owner
             , proname AS object_name
             , null as sub_object_name
             , min(OID) as OBJECT_ID
             , null as DATA_OBJECT_ID
             , CASE WHEN prorettype = 'trigger'::regtype::oid THEN 'TRIGGER'::text
                    ELSE (case prokind when 'p' then 'PROCEDURE' else 'FUNCTION' end)
               END AS object_type
             , 'N' as temporary
          FROM pg_catalog.pg_proc
         WHERE pg_function_is_visible(oid)
         group by proowner, pronamespace, proname
                , CASE WHEN prorettype = 'trigger'::regtype::oid THEN 'TRIGGER'::text
                       ELSE (case prokind when 'p' then 'PROCEDURE' else 'FUNCTION' end)
                  END
         UNION ALL
        select synowner as creator
             , synnamespace as owner
             , synname as object_name
             , null as sub_object_name
             , oid as object_Id
             , null as DATA_OBJECT_ID
             , 'SYNONYM' as object_type
             , 'N' as temporary
          from pg_catalog.pg_synonym
          ) as o1
  JOIN pg_catalog.pg_namespace as n on o1.owner = n.oid
  JOIN pg_catalog.pg_user as u on o1.creator = u.usesysid
  left JOIN pg_catalog.pg_object as o2 on o1.object_id = o2.object_oid
 where n.nspname NOT LIKE 'pg_toast%';

DROP VIEW IF EXISTS oracle.USER_OBJECTS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_OBJECTS AS SELECT object_name, subobject_name, object_id, data_object_id, object_type, temporary FROM oracle.DBA_OBJECTS WHERE OWNER  = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_OBJECTS for oracle.DBA_OBJECTS;
CREATE OR REPLACE SYNONYM public.ALL_OBJECTS for oracle.DBA_OBJECTS;
CREATE OR REPLACE SYNONYM public.USER_OBJECTS for oracle.USER_OBJECTS;
CREATE OR REPLACE SYNONYM public.OBJ for oracle.USER_OBJECTS;




-- =============================================================================
-- DBA_CATALOG
-- ALL_CATALOG
-- USER_CATALOG
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_CATALOG CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_CATALOG
AS
SELECT owner
     , object_name AS TABLE_NAME
     , object_type as TABLE_TYPE
  FROM oracle.dba_objects c
 WHERE object_type in ('TABLE', 'VIEW', 'SEQUENCE', 'SYNONYM');

DROP VIEW IF EXISTS oracle.USER_CATALOG CASCADE;
CREATE OR REPLACE VIEW oracle.USER_CATALOG AS SELECT TABLE_NAME, TABLE_TYPE FROM oracle.DBA_CATALOG WHERE OWNER  = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_CATALOG for oracle.DBA_CATALOG;
CREATE OR REPLACE SYNONYM public.ALL_CATALOG for oracle.DBA_CATALOG;
CREATE OR REPLACE SYNONYM public.USER_CATALOG for oracle.USER_CATALOG;




-- =============================================================================
-- DICTIONARY    COMMENTS 字段均为空
-- DICT
-- =============================================================================
DROP VIEW IF EXISTS oracle.DICTIONARY CASCADE;
CREATE OR REPLACE VIEW oracle.DICTIONARY
AS
SELECT OWNER
     , OBJECT_NAME AS TABLE_NAME
     , d.description as COMMENTS
  FROM oracle.dba_objects as o
  LEFT JOIN pg_catalog.pg_description d on o.object_id = d.objoid and d.objsubid = 0
 WHERE o.object_type in ('TABLE', 'VIEW')
   and o.owner in ('PG_CATALOG', 'INFORMATION_SCHEMA', 'DBE_PERF', 'PKG_SERVICE', 'SNAPSHOT', 'CSTORE');

CREATE OR REPLACE SYNONYM public.DICTIONARY for oracle.DICTIONARY;
CREATE OR REPLACE SYNONYM public.DICT for oracle.DICTIONARY;




-- =============================================================================
-- DBA_DEPENDENCIES
-- ALL_DEPENDENCIES
-- USER_DEPENDENCIES
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_DEPENDENCIES CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_DEPENDENCIES
AS
with obj as (select object_Id, owner, coalesce(subobject_name, object_name) as object_name, object_type from oracle.dba_objects)
SELECT distinct c.OWNER
     , c.object_name as NAME
     , c.object_type as TYPE
     , cr.OWNER as REFERENCED_OWNER
     , cr.object_name as REFERENCED_NAME
     , cr.object_type as REFERENCED_TYPE
     , case d.deptype when 'n' then 'NORMAL' when 'a' then 'AUTO' when 'i' then 'INTERNAL' when 'e' then 'EXTENSION' when 'p' then 'PIN' when 'x' then 'AUTO_EXTENSION' when 'I' then 'INTERNAL_AUTO' else UPPER(d.deptype::text) end as DEPENDENCY_TYPE
  FROM pg_catalog.pg_depend d
  join obj c on d.objid = c.object_id
  join obj cr on d.refobjid = cr.object_id
 WHERE d.objsubid = 0
   and (c.OWNER != cr.OWNER or c.object_name != cr.object_name);

DROP VIEW IF EXISTS oracle.USER_DEPENDENCIES CASCADE;
CREATE OR REPLACE VIEW oracle.USER_DEPENDENCIES AS SELECT NAME, TYPE, REFERENCED_OWNER, REFERENCED_NAME, REFERENCED_TYPE, DEPENDENCY_TYPE FROM oracle.DBA_DEPENDENCIES WHERE OWNER  = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_DEPENDENCIES for oracle.DBA_DEPENDENCIES;
CREATE OR REPLACE SYNONYM public.ALL_DEPENDENCIES for oracle.DBA_DEPENDENCIES;
CREATE OR REPLACE SYNONYM public.USER_DEPENDENCIES for oracle.USER_DEPENDENCIES;




-- =============================================================================
-- DBA_SEGMENTS
-- ALL_SEGMENTS
-- USER_SEGMENTS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_SEGMENTS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_SEGMENTS
AS
SELECT o.owner
     , o.object_name as SEGMENT_NAME
     , o.subobject_name as PARTITION_NAME
     , o.object_type as SEGMENT_TYPE
     , coalesce(UPPER(t.spcname), 'DEFAULT') as TABLESPACE_NAME
     , (case o.object_type
        when 'TABLE' then pg_table_size(o.object_id)
        when 'INDEX' then pg_indexes_size(o.object_id)
        when 'TABLE PARTITION' then pg_partition_size(lower(o.owner||'.'||o.object_name), lower(o.subobject_name))
        when 'INDEX PARTITION' then pg_partition_indexes_size(lower(o.owner||'.'||o.object_name), lower(o.subobject_name))
        else pg_relation_size(o.data_object_id)
        end) as bytes
     , (case o.object_type
        when 'TABLE' then pg_table_size(o.object_id)
        when 'INDEX' then pg_indexes_size(o.object_id)
        when 'TABLE PARTITION' then pg_partition_size(lower(o.owner||'.'||o.object_name), lower(o.subobject_name))
        when 'INDEX PARTITION' then pg_partition_indexes_size(lower(o.owner||'.'||o.object_name), lower(o.subobject_name))
        else pg_relation_size(o.data_object_id)
        end / b.block_size)::bigint as blocks
  FROM oracle.DBA_OBJECTS o
  join (select setting::bigint as block_size FROM pg_catalog.pg_settings WHERE name = 'block_size') b on 1=1
  left join pg_catalog.pg_class c on o.object_id = c.oid
  left join pg_catalog.pg_partition p on o.object_id = p.oid
  left join pg_catalog.pg_tablespace t on c.reltablespace = t.oid or p.reltablespace = t.oid
 WHERE o.object_type in ('TABLE', 'TABLE PARTITION', 'INDEX', 'INDEX PARTITION');

DROP VIEW IF EXISTS oracle.USER_SEGMENTS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_SEGMENTS AS SELECT segment_name, partition_name, segment_type, tablespace_name, bytes, blocks FROM oracle.DBA_SEGMENTS WHERE OWNER  = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_SEGMENTS for oracle.DBA_SEGMENTS;
CREATE OR REPLACE SYNONYM public.ALL_SEGMENTS for oracle.DBA_SEGMENTS;
CREATE OR REPLACE SYNONYM public.USER_SEGMENTS for oracle.USER_SEGMENTS;




-- =============================================================================
-- DBA_SOURCE_ALL
-- DBA_SOURCE
-- ALL_SOURCE
-- USER_SOURCE
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_SOURCE_ALL CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_SOURCE_ALL
AS
SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS OWNER
     , case when p.proname::text = lower(p.proname::text) then UPPER(p.proname::text) else p.proname::text end AS NAME
     , CASE WHEN p.prorettype = 'trigger'::regtype::oid THEN 'TRIGGER'::text
            ELSE (case prokind when 'p' then 'PROCEDURE' else 'FUNCTION' end)
       END AS TYPE
     , 0 as LINE
     , p.prosrc as TEXT
  FROM pg_catalog.pg_proc as p
  JOIN pg_catalog.pg_namespace as n on p.pronamespace = n.oid
 WHERE p.prolang not in (select oid FROM pg_catalog.pg_language WHERE lanname in ('internal', 'c'));


DROP VIEW IF EXISTS oracle.DBA_SOURCE CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_SOURCE
AS
with recursive
ta as (select case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS OWNER
            , case when p.proname::text = lower(p.proname::text) then UPPER(p.proname::text) else p.proname::text end AS NAME
            , CASE WHEN p.prorettype = 'trigger'::regtype::oid THEN 'TRIGGER'::text
                   ELSE (case prokind when 'p' then 'PROCEDURE' else 'FUNCTION' end)
              END AS TYPE
            , p.prosrc as TEXT
            , length(p.prosrc) - length(replace(p.prosrc, chr(10), '')) + 1 as lines
         FROM pg_catalog.pg_proc as p
         JOIN pg_catalog.pg_namespace as n on p.pronamespace = n.oid
        WHERE p.prolang not in (select oid FROM pg_catalog.pg_language WHERE lanname in ('internal', 'c'))
      ),
t_line as (select owner, name, type, text, 1 as line_id, lines FROM ta
            union all
           select owner, name, type, text, 1 + line_id as line_id, lines FROM t_line WHERE 1 + line_id <= lines)
select owner, name, type, line_id as line, substr(text, p1 + 1, p2-p1-1) as text
  FROM (select owner, name, type, line_id, lines, text
             , case line_id when 1 then 0 else instr(text, chr(10), 1, line_id - 1) end as p1
             , case instr(text, chr(10), 1, line_id) when 0 then length(text) else instr(text, chr(10), 1, line_id) end as p2
          FROM t_line) as x
 order by owner, name, line_id;

DROP VIEW IF EXISTS oracle.USER_SOURCE CASCADE;
CREATE OR REPLACE VIEW oracle.USER_SOURCE AS SELECT name, type, line, text FROM oracle.DBA_SOURCE WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_SOURCE_ALL for oracle.DBA_SOURCE_ALL;
CREATE OR REPLACE SYNONYM public.DBA_SOURCE for oracle.DBA_SOURCE;
CREATE OR REPLACE SYNONYM public.ALL_SOURCE for oracle.DBA_SOURCE;
CREATE OR REPLACE SYNONYM public.USER_SOURCE for oracle.USER_SOURCE;




-- =============================================================================
-- DBA_PROCEDURES
-- ALL_PROCEDURES
-- USER_PROCEDURES
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_PROCEDURES CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_PROCEDURES
AS
SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS OWNER
     , case when p.proname::text = lower(p.proname::text) then UPPER(p.proname::text) else p.proname::text end AS OBJECT_NAME
     , p.oid as OBJECT_ID
     , CASE WHEN p.prorettype = 'trigger'::regtype::oid THEN 'TRIGGER'::text
            ELSE (case p.prokind when 'p' then 'PROCEDURE' when 'f' then 'FUNCTION' else NULL end)
       END AS OBJECT_TYPE
     , case p.prokind when 'a' then 'YES' else 'NO' end as AGGREGATE
     , case p.provolatile when 'v' then 'NO' else 'YES 'end as DETERMINISTIC
  FROM pg_catalog.pg_proc as p
  JOIN pg_catalog.pg_namespace as n on p.pronamespace = n.oid
 WHERE p.prolang not in (select oid FROM pg_catalog.pg_language WHERE lanname in ('internal', 'c'));

DROP VIEW IF EXISTS oracle.USER_PROCEDURES CASCADE;
CREATE OR REPLACE VIEW oracle.USER_PROCEDURES AS SELECT object_name, object_id, object_type, aggregate, deterministic FROM oracle.DBA_PROCEDURES WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_PROCEDURES for oracle.DBA_PROCEDURES;
CREATE OR REPLACE SYNONYM public.ALL_PROCEDURES for oracle.DBA_PROCEDURES;
CREATE OR REPLACE SYNONYM public.USER_PROCEDURES for oracle.USER_PROCEDURES;




-- =============================================================================
-- DBA_TRIGGERS
-- ALL_TRIGGERS
-- USER_TRIGGERS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_TRIGGERS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TRIGGERS
AS
SELECT case when it.trigger_schema::text = lower(it.trigger_schema::text) then UPPER(it.trigger_schema::text) else it.trigger_schema::text end AS OWNER
     , case when it.trigger_name::text = lower(it.trigger_name::text) then UPPER(it.trigger_name::text) else it.trigger_name::text end AS TRIGGER_NAME
     , UPPER(it.action_timing||' '||it.action_orientation) as TRIGGER_TYPE
     , UPPER(it.event_manipulation) as TRIGGERING_EVENT
     , case when it.event_object_schema::text = lower(it.event_object_schema::text) then UPPER(it.event_object_schema::text) else it.event_object_schema::text end AS TABLE_OWNER
     , 'TABLE' As BASE_OBJECT_TYPE
     , case when it.event_object_table::text = lower(it.event_object_table::text) then UPPER(it.event_object_table::text) else it.event_object_table::text end AS TABLE_NAME
     , 'REFERENCING NEW AS '||coalesce(UPPER(it.action_reference_new_table), 'NEW')||' OLD AS '||coalesce(UPPER(it.action_reference_old_table), 'OLD') as REFERENCING_NAMES
     , it.action_condition as WHEN_CLAUSE
     , case ct.tgenabled when 'D' then 'DISABLED' else 'ENABLED' end as STATUS
     , 'PL/SQL' as ACTION_TYPE
     , it.action_statement as TRIGGER_BODY
     , case when it.action_orientation = 'STATEMENT' and it.action_timing = 'BEFORE' then 'YES' else 'NO' end as BEFORE_STATEMENT
     , case when it.action_orientation = 'ROW' and it.action_timing = 'BEFORE' then 'YES' else 'NO' end as BEFORE_ROW
     , case when it.action_orientation = 'ROW' and it.action_timing = 'AFTER' then 'YES' else 'NO' end as AFTER_ROW
     , case when it.action_orientation = 'STATEMENT' and it.action_timing = 'AFTER' then 'YES' else 'NO' end as AFTER_STATEMENT
     , case when it.action_orientation = 'ROW' and it.action_timing = 'INSTEAD OF' then 'YES' else 'NO' end as INSTEAD_OF_ROW
  FROM information_schema.triggers it
  join pg_catalog.pg_trigger ct on it.trigger_name = ct.tgname
  join pg_catalog.pg_class pc on ct.tgrelid = pc.oid
 WHERE it.trigger_catalog = current_database();

DROP VIEW IF EXISTS oracle.USER_TRIGGERS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TRIGGERS AS SELECT trigger_name, trigger_type, triggering_event, table_owner, base_object_type, table_name, referencing_names, when_clause, status, action_type, trigger_body, before_statement, before_row, after_row, after_statement, instead_of_row FROM oracle.DBA_TRIGGERS WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_TRIGGERS for oracle.DBA_TRIGGERS;
CREATE OR REPLACE SYNONYM public.ALL_TRIGGERS for oracle.DBA_TRIGGERS;
CREATE OR REPLACE SYNONYM public.USER_TRIGGERS for oracle.USER_TRIGGERS;




-- =============================================================================
-- DBA_TRIGGER_COLS
-- ALL_TRIGGER_COLS
-- USER_TRIGGER_COLS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_TRIGGER_COLS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TRIGGER_COLS
AS
SELECT case when trigger_schema::text = lower(trigger_schema::text) then UPPER(trigger_schema::text) else trigger_schema::text end AS TRIGGER_OWNER
     , case when trigger_name::text = lower(trigger_name::text) then UPPER(trigger_name::text) else trigger_name::text end AS TRIGGER_NAME
     , case when event_object_schema::text = lower(event_object_schema::text) then UPPER(event_object_schema::text) else event_object_schema::text end AS TABLE_OWNER
     , case when event_object_table::text = lower(event_object_table::text) then UPPER(event_object_table::text) else event_object_table::text end AS TABLE_NAME
     , case when event_object_column::text = lower(event_object_column::text) then UPPER(event_object_column::text) else event_object_column::text end AS COLUMN_NAME
  FROM information_schema.triggered_update_columns
 WHERE trigger_catalog = current_database();

DROP VIEW IF EXISTS oracle.USER_TRIGGER_COLS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TRIGGER_COLS AS SELECT TRIGGER_NAME, TABLE_OWNER, TABLE_NAME, COLUMN_NAME FROM oracle.DBA_TRIGGER_COLS WHERE TRIGGER_OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_TRIGGER_COLS for oracle.DBA_TRIGGER_COLS;
CREATE OR REPLACE SYNONYM public.ALL_TRIGGER_COLS for oracle.DBA_TRIGGER_COLS;
CREATE OR REPLACE SYNONYM public.USER_TRIGGER_COLS for oracle.USER_TRIGGER_COLS;




-- =============================================================================
-- DBA_TYPES
-- ALL_TYPES
-- USER_TYPES
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_TYPES CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TYPES
AS
SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS OWNER
     , case when t.typname::text = lower(t.typname::text) then UPPER(t.typname::text) else t.typname::text end AS TYPE_NAME
     , t.OID as TYPE_OID
     , case t.typtype when 'b' then 'BASE' when 'c' then 'COMPOSITE' when 'd' then 'DOMAIN' when 'e'  then 'ENUM' when 'p' then 'PSEUDO' when 'r' then 'RANGE' else UPPER(t.typtype::text) end as TYPECODE
     , case when t.typisdefined then 'YES' else 'NO' end as PREDEFINED
  FROM pg_catalog.pg_type as t
  JOIN pg_catalog.pg_namespace as n on t.typnamespace = n.oid
 WHERE t.typtype != 'b'
   and t.typname not in (select relname FROM pg_catalog.pg_class WHERE relkind in ('r', 't', 'S', 'v', 'f'));

DROP VIEW IF EXISTS oracle.USER_TYPES CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TYPES AS SELECT type_name, type_oid, typecode, predefined FROM oracle.DBA_TYPES WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_TYPES for oracle.DBA_TYPES;
CREATE OR REPLACE SYNONYM public.ALL_TYPES for oracle.DBA_TYPES;
CREATE OR REPLACE SYNONYM public.USER_TYPES for oracle.USER_TYPES;




-- =============================================================================
-- DBA_CONSTRAINTS
-- ALL_CONSTRAINTS
-- USER_CONSTRAINTS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_CONSTRAINTS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_CONSTRAINTS
AS
SELECT case when nsp.nspname::text = lower(nsp.nspname::text) then UPPER(nsp.nspname::text) else nsp.nspname::text end AS OWNER
     , case when cons.conname::text = lower(cons.conname::text) then UPPER(cons.conname::text) else cons.conname::text end AS CONSTRAINT_NAME
     , UPPER(cons.contype) as CONSTRAINT_TYPE
     , case when cls_r.relname::text = lower(cls_r.relname::text) then UPPER(cls_r.relname::text) else cls_r.relname::text end AS TABLE_NAME
     , case when nsp_f.nspname::text = lower(nsp_f.nspname::text) then UPPER(nsp_f.nspname::text) else nsp_f.nspname::text end AS R_OWNER
     , case when cls_f.relname::text = lower(cls_f.relname::text) then UPPER(cls_f.relname::text) else cls_f.relname::text end AS R_TABLE_NAME
     , case cons.confdeltype when 'a' then 'NO ACTION' when 'r' then 'RESTRICT' when 'c' then 'CASCADE' when 'n' then 'SET NULL' when 'd' then 'SET DEFAULT' else UPPER(confdeltype::text) end as DELETE_RULE
     , case when cons.convalidated then 'ENABLED' else 'DISABLED' end as STATUS
     , case when cons.condeferrable then 'DEFERRABLE' else 'NOT DEFERRABLE' end as DEFERRABLE
     , case when cons.condeferred then 'DEFERRED' else 'IMMEDIATE' end as DEFERRED
     , case when cons.convalidated then 'VALIDATED' else 'NOT VALIDATED' end as VALIDATED
     , case when nsp_i.nspname::text = lower(nsp_i.nspname::text) then UPPER(nsp_i.nspname::text) else nsp_i.nspname::text end AS INDEX_OWNER
     , case when cls_i.relname::text = lower(cls_i.relname::text) then UPPER(cls_i.relname::text) else cls_i.relname::text end AS INDEX_NAME
     , case when cons.convalidated then 'VALIDATED' else 'NOT VALIDATED' end as INVALID
  FROM pg_catalog.pg_constraint cons
  JOIN pg_catalog.pg_namespace nsp on nsp.oid = cons.connamespace
  LEFT JOIN pg_catalog.pg_class cls_r on cons.conrelid = cls_r.oid
  LEFT JOIN pg_catalog.pg_class cls_f on cons.confrelid = cls_f.oid
  LEFT JOIN pg_catalog.pg_namespace nsp_f on nsp_f.oid = cls_f.relnamespace
  LEFT JOIN pg_catalog.pg_class cls_i on cons.conindid = cls_i.oid
  LEFT JOIN pg_catalog.pg_namespace nsp_i on nsp_i.oid = cls_i.relnamespace
 WHERE nsp.nspname not like 'pg_toast%';

DROP VIEW IF EXISTS oracle.USER_CONSTRAINTS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_CONSTRAINTS AS SELECT constraint_name, constraint_type, table_name, r_owner, r_table_name, delete_rule, status, "deferrable", "deferred", validated, index_owner, index_name, invalid FROM oracle.DBA_CONSTRAINTS WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_CONSTRAINTS for oracle.DBA_CONSTRAINTS;
CREATE OR REPLACE SYNONYM public.ALL_CONSTRAINTS for oracle.DBA_CONSTRAINTS;
CREATE OR REPLACE SYNONYM public.USER_CONSTRAINTS for oracle.USER_CONSTRAINTS;




-- =============================================================================
-- DBA_CONS_COLUMNS
-- ALL_CONS_COLUMNS
-- USER_CONS_COLUMNS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_CONS_COLUMNS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_CONS_COLUMNS
AS
SELECT case when c.nspname::text = lower(c.nspname::text) then UPPER(c.nspname::text) else c.nspname::text end AS OWNER
     , case when c.conname::text = lower(c.conname::text) then UPPER(c.conname::text) else c.conname::text end AS CONSTRAINT_NAME
     , case when c.relname::text = lower(c.relname::text) then UPPER(c.relname::text) else c.relname::text end AS TABLE_NAME
     , case when a.attname::text = lower(a.attname::text) then UPPER(a.attname::text) else a.attname::text end AS COLUMN_NAME
     , c.ord as POSITION
  FROM (select ns.nspname
             , cn.conname
             , cl.relname
             , unnest(cn.conkey) as column_Id
             , case cn.contype when 'c' then NULL else generate_series( 1, array_length(cn.conkey, 1)) end as ord
             , cn.conrelid as table_oid
          FROM pg_catalog.pg_constraint as cn
          join pg_catalog.pg_class as cl on cn.conrelid = cl.oid
          join pg_catalog.pg_namespace as ns on cn.connamespace = ns.oid
         WHERE ns.nspname::text not like 'pg_toast%') as c
  JOIN pg_catalog.pg_attribute a on c.table_oid = a.attrelid and c.column_Id = a.attnum;

DROP VIEW IF EXISTS oracle.USER_CONS_COLUMNS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_CONS_COLUMNS AS SELECT constraint_name, table_name, column_name, position FROM oracle.DBA_CONS_COLUMNS WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_CONS_COLUMNS for oracle.DBA_CONS_COLUMNS;
CREATE OR REPLACE SYNONYM public.ALL_CONS_COLUMNS for oracle.DBA_CONS_COLUMNS;
CREATE OR REPLACE SYNONYM public.USER_CONS_COLUMNS for oracle.USER_CONS_COLUMNS;




-- =============================================================================
-- DBA_VIEWS
-- ALL_VIEWS
-- USER_VIEWS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_VIEWS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_VIEWS
AS
SELECT case when schemaname::text = lower(schemaname::text) then UPPER(schemaname::text) else schemaname::text end AS OWNER
     , case when viewname::text = lower(viewname::text) then UPPER(viewname::text) else viewname::text end AS VIEW_NAME
     , length(definition) as TEXT_LENGTH
     , definition as TEXT
     , definition as TEXT_VC
  FROM pg_catalog.pg_views;

DROP VIEW IF EXISTS oracle.USER_VIEWS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_VIEWS AS SELECT VIEW_NAME, TEXT_LENGTH, "text", TEXT_VC FROM oracle.DBA_VIEWS WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_VIEWS for oracle.DBA_VIEWS;
CREATE OR REPLACE SYNONYM public.ALL_VIEWS for oracle.DBA_VIEWS;
CREATE OR REPLACE SYNONYM public.USER_VIEWS for oracle.USER_VIEWS;




-- =============================================================================
-- DBA_TABLES
-- DBA_ALL_TABLES
-- ALL_TABLES
-- USER_TABLES
-- TAB
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_TABLES CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TABLES
AS
SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS OWNER
     , case when c.relname::text = lower(c.relname::text) then UPPER(c.relname::text) else c.relname::text end AS TABLE_NAME
     , coalesce(UPPER(t.spcname::text), 'DEFAULT') as TABLESPACE_NAME
     , case c.relpersistence when 'p' then 'YES' else 'NO' end as LOGGING
     , c.reltuples::bigint as NUM_ROWS
     , c.relpages::bigint as BLOCKS
     , s.stawidth as AVG_ROW_LEN
     , coalesce(pg_stat_get_last_analyze_time(c.oid), pg_stat_get_last_autoanalyze_time(c.oid)) as LAST_ANALYZED
     , case c.parttype when 'n' then 'NO' else 'YES' end as PARTITIONED
     , case c.relpersistence when 't' then 'YES' else 'NO' end as TEMPORARY
     , case when c.relrowmovement then 'ENABLE' else 'DISABLE' end as ROW_MOVEMENT
     , case c.relcmprs when 2 then 'YES' else 'NO' end as COMPRESSION
  FROM pg_catalog.pg_class c
  join pg_catalog.pg_namespace n on c.relnamespace = n.oid
  left join pg_catalog.pg_tablespace t on c.reltablespace = t.oid
  left join (select starelid, sum(stawidth) as stawidth FROM pg_catalog.pg_statistic group by starelid) s on c.oid = s.starelid
 WHERE c.relkind in ('r', 'f')
   and n.nspname::text not like 'pg_toast%';

DROP VIEW IF EXISTS oracle.USER_TABLES CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TABLES AS SELECT table_name, tablespace_name, logging, num_rows, blocks, avg_row_len, last_analyzed, partitioned, temporary FROM oracle.DBA_TABLES WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_TABLES for oracle.DBA_TABLES;
CREATE OR REPLACE SYNONYM public.DBA_ALL_TABLES for oracle.DBA_TABLES;
CREATE OR REPLACE SYNONYM public.ALL_TABLES for oracle.DBA_TABLES;
CREATE OR REPLACE SYNONYM public.USER_TABLES for oracle.USER_TABLES;
CREATE OR REPLACE SYNONYM public.TAB for oracle.USER_TABLES;




-- =============================================================================
-- DBA_PART_TABLES
-- ALL_PART_TABLES
-- USER_PART_TABLES
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_PART_TABLES CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_PART_TABLES
AS
SELECT OWNER, TABLE_NAME, PARTITIONING_TYPE, PARTITION_COUNT, PARTITIONING_KEY_COUNT, DEF_TABLESPACE_NAME, DEF_LOGGING, INTERVAL
  from (SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS OWNER
             , case when p.relname::text = lower(p.relname::text) then UPPER(p.relname::text) else p.relname::text end AS TABLE_NAME
             , case p.partstrategy
               when 'r' then 'RANGE'
               when 'v' then 'VALUE'
               when 'i' then 'INTERVAL'
               when 'l' then 'LIST'
               when 'h' then 'HASH'
               when 'n' then 'INVALID'
               else UPPER(p.partstrategy::text) end as PARTITIONING_TYPE
             , count(p.parentid) over (partition by p.parentid) - 1 as PARTITION_COUNT
             , array_length(p.partkey::int[], 1) as PARTITIONING_KEY_COUNT
             , coalesce(UPPER(s.spcname::text), 'DEFAULT') as DEF_TABLESPACE_NAME
             , case c.relpersistence when 'p' then 'YES' else 'NO' end as DEF_LOGGING
             , case when arraycontains(p.reloptions, string_to_array('compression=no',',')) then 'NO' else 'YES' end as DEF_COMPRESSION
             , p.interval
             , p.parttype
          FROM pg_catalog.pg_partition p
          join pg_catalog.pg_class c on p.parentid = c.oid
          join pg_catalog.pg_namespace n on c.relnamespace = n.oid
          left join pg_catalog.pg_tablespace s on p.reltablespace = s.oid
       ) as p
 where p.parttype = 'r';

DROP VIEW IF EXISTS oracle.USER_PART_TABLES CASCADE;
CREATE OR REPLACE VIEW oracle.USER_PART_TABLES AS SELECT TABLE_NAME, PARTITIONING_TYPE, PARTITION_COUNT, PARTITIONING_KEY_COUNT, DEF_TABLESPACE_NAME, DEF_LOGGING, INTERVAL FROM oracle.DBA_PART_TABLES WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_PART_TABLES for oracle.DBA_PART_TABLES;
CREATE OR REPLACE SYNONYM public.ALL_PART_TABLES for oracle.DBA_PART_TABLES;
CREATE OR REPLACE SYNONYM public.USER_PART_TABLES for oracle.USER_PART_TABLES;




-- =============================================================================
-- DBA_TAB_PARTITIONS
-- ALL_TAB_PARTITIONS
-- USER_TAB_PARTITIONS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_TAB_PARTITIONS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TAB_PARTITIONS
AS
SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS TABLE_OWNER
     , case when c.relname::text = lower(c.relname::text) then UPPER(c.relname::text) else c.relname::text end AS TABLE_NAME
     , case when p.relname::text = lower(p.relname::text) then UPPER(p.relname::text) else p.relname::text end AS PARTITION_NAME
     , coalesce(array_to_string(p.boundaries, ','), 'MAXVALUE') as HIGH_VALUE
     , length(array_to_string(p.boundaries, ',')) as HIGH_VALUE_LENGTH
     , row_number() over (partition by p.parentid order by p.boundaries) as PARTITION_POSITION
     , coalesce(UPPER(t.spcname::text), 'DEFAULT') as TABLESPACE_NAME
     , case c.relpersistence when 'p' then 'YES' else 'NO' end as LOGGING
     , case when arraycontains(p.reloptions, string_to_array('compression=no',',')) then 'NO' else 'YES' end as COMPRESSION
     , p.reltuples::bigint as NUM_ROWS
     , p.relpages::bigint as BLOCKS
     , s.stawidth as AVG_ROW_LEN
     , coalesce(pg_stat_get_last_analyze_time(p.parentid), pg_stat_get_last_autoanalyze_time(p.parentid)) as LAST_ANALYZED
  FROM pg_catalog.pg_partition p
  join pg_catalog.pg_class c on p.parentid = c.oid
  join pg_catalog.pg_namespace n on c.relnamespace = n.oid
  left join pg_catalog.pg_tablespace t on p.reltablespace = t.oid
  left join (select starelid, sum(stawidth) as stawidth FROM pg_catalog.pg_statistic group by starelid) s on p.parentid = s.starelid
 WHERE p.parttype = 'p';

DROP VIEW IF EXISTS oracle.USER_TAB_PARTITIONS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TAB_PARTITIONS AS SELECT table_name, partition_name, high_value, high_value_length, tablespace_name, logging, compression, num_rows, blocks, avg_row_len, last_analyzed FROM oracle.DBA_TAB_PARTITIONS WHERE TABLE_OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_TAB_PARTITIONS for oracle.DBA_TAB_PARTITIONS;
CREATE OR REPLACE SYNONYM public.ALL_TAB_PARTITIONS for oracle.DBA_TAB_PARTITIONS;
CREATE OR REPLACE SYNONYM public.USER_TAB_PARTITIONS for oracle.USER_TAB_PARTITIONS;




-- =============================================================================
-- DBA_TAB_STATISTICS
-- ALL_TAB_STATISTICS
-- USER_TAB_STATISTICS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_TAB_STATISTICS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TAB_STATISTICS
AS
SELECT OWNER
     , TABLE_NAME
     , Null as PARTITION_NAME
     , null as PARTITION_POSITION
     , 'TABLE' as OBJECT_TYPE
     , NUM_ROWS
     , BLOCKS
     , AVG_ROW_LEN
     , LAST_ANALYZED
  FROM oracle.dba_tables
 WHERE partitioned = 'NO'
 union all
SELECT TABLE_OWNER as OWNER
     , TABLE_NAME
     , PARTITION_NAME
     , PARTITION_POSITION
     , 'PARTITION' as OBJECT_TYPE
     , NUM_ROWS
     , BLOCKS
     , AVG_ROW_LEN
     , LAST_ANALYZED
  FROM oracle.DBA_TAB_PARTITIONS;

DROP VIEW IF EXISTS oracle.USER_TAB_STATISTICS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TAB_STATISTICS AS SELECT table_name, partition_name, partition_position, object_type, num_rows, blocks, avg_row_len, last_analyzed FROM oracle.DBA_TAB_STATISTICS WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_TAB_STATISTICS for oracle.DBA_TAB_STATISTICS;
CREATE OR REPLACE SYNONYM public.ALL_TAB_STATISTICS for oracle.DBA_TAB_STATISTICS;
CREATE OR REPLACE SYNONYM public.USER_TAB_STATISTICS for oracle.USER_TAB_STATISTICS;




-- =============================================================================
-- DBA_TAB_COMMENTS
-- ALL_TAB_COMMENTS
-- USER_TAB_COMMENTS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_TAB_COMMENTS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TAB_COMMENTS
AS
SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS OWNER
     , case when c.relname::text = lower(c.relname::text) then UPPER(c.relname::text) else c.relname::text end AS TABLE_NAME
     , CASE c.relkind
            WHEN 'r'::"char" THEN 'TABLE'::text
            WHEN 'i'::"char" THEN 'INDEX'::text
            WHEN 'I'::"char" THEN 'PARTITIONED INDEX'::text
            WHEN 'S'::"char" THEN 'SEQUENCE'::text
            WHEN 'v'::"char" THEN 'VIEW'::text
            WHEN 'c'::"char" THEN 'COMPOSITE TYPE'::text
            WHEN 't'::"char" THEN 'TOAST'::text
            WHEN 'f'::"char" THEN 'FOREIGN TABLE'::text
            ELSE c.relkind::text
        END AS TABLE_TYPE
     , d.description as COMMENTS
  FROM pg_catalog.pg_class c
  JOIN pg_catalog.pg_namespace n on c.relnamespace  = n.oid
  JOIN pg_catalog.pg_description d on c.oid = d.objoid and d.objsubid = 0 and d.classoid = 'pg_class'::regclass::oid
 WHERE n.nspname not like 'pg_toast%';

DROP VIEW IF EXISTS oracle.USER_TAB_COMMENTS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TAB_COMMENTS AS SELECT table_name, table_type, comments FROM oracle.DBA_TAB_COMMENTS WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_TAB_COMMENTS for oracle.DBA_TAB_COMMENTS;
CREATE OR REPLACE SYNONYM public.ALL_TAB_COMMENTS for oracle.DBA_TAB_COMMENTS;
CREATE OR REPLACE SYNONYM public.USER_TAB_COMMENTS for oracle.USER_TAB_COMMENTS;




-- =============================================================================
-- DBA_TAB_MODIFICATIONS
-- ALL_TAB_MODIFICATIONS
-- USER_TAB_MODIFICATIONS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_TAB_MODIFICATIONS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_TAB_MODIFICATIONS
AS
SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS TABLE_OWNER
     , case when p.relname::text = lower(p.relname::text) then UPPER(p.relname::text) else p.relname::text end AS TABLE_NAME
     , s.n_tup_ins as INSERTS
     , s.n_tup_upd as UPDATES
     , s.n_tup_del as DELETES
     , coalesce(s.last_analyze, s.last_autovacuum) as TIMESTAMP
  FROM pg_catalog.pg_class p
  join pg_catalog.pg_namespace n on p.relnamespace = n.oid
  join pg_catalog.pg_stat_all_tables s on p.oid = s.relid
 WHERE p.relkind = 'r';

DROP VIEW IF EXISTS oracle.USER_TAB_MODIFICATIONS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_TAB_MODIFICATIONS AS SELECT TABLE_NAME, INSERTS, UPDATES, DELETES, "timestamp" FROM oracle.DBA_TAB_MODIFICATIONS WHERE TABLE_OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_TAB_MODIFICATIONS for oracle.DBA_TAB_MODIFICATIONS;
CREATE OR REPLACE SYNONYM public.ALL_TAB_MODIFICATIONS for oracle.DBA_TAB_MODIFICATIONS;
CREATE OR REPLACE SYNONYM public.USER_TAB_MODIFICATIONS for oracle.USER_TAB_MODIFICATIONS;




-- =============================================================================
-- DBA_INDEXES
-- ALL_INDEXES
-- USER_INDEXES
-- IND
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_INDEXES CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_INDEXES
AS
SELECT case when nc.nspname::text = lower(nc.nspname::text) then UPPER(nc.nspname::text) else nc.nspname::text end AS OWNER
     , case when c.relname::text = lower(c.relname::text) then UPPER(c.relname::text) else c.relname::text end AS INDEX_NAME
     , case when nt.nspname::text = lower(nt.nspname::text) then UPPER(nt.nspname::text) else nt.nspname::text end AS TABLE_OWNER
     , case when t.relname::text = lower(t.relname::text) then UPPER(t.relname::text) else t.relname::text end AS TABLE_NAME
     , CASE t.relkind
            WHEN 'r'::"char" THEN 'TABLE'::text
            WHEN 'v'::"char" THEN 'VIEW'::text
            WHEN 'i'::"char" THEN 'INDEX'::text
            WHEN 'I'::"char" THEN 'PARTITIONED INDEX'::text
            WHEN 'S'::"char" THEN 'SEQUENCE'::text
            WHEN 'f'::"char" THEN 'FOREIGN TABLE'::text
            WHEN 'c'::"char" THEN 'COMPOSITE TYPE'::text
            WHEN 't'::"char" THEN 'TOAST'::text
            ELSE t.relkind::text
        END AS TABLE_TYPE
     , case when i.indisunique then 'UNIQUE' else 'NONUNIQUE' end as UNIQUENESS
     , coalesce(UPPER(s.spcname), 'DEFAULT') as TABLESPACE_NAME
     , case c.relpersistence when 'p' then 'YES' else 'NO' end as LOGGING
     , CASE WHEN st.stadistinct >= 0 THEN st.stadistinct ELSE ROUND(ABS(st.stadistinct * c.RELTUPLES)) END as DISTINCT_KEYS
     , case when i.indisvalid then 'VALID' else 'UNUSABLE' end as STATUS
     , c.reltuples as NUM_ROWS
     , coalesce(pg_stat_get_last_analyze_time(t.oid), pg_stat_get_last_autoanalyze_time(t.oid)) as LAST_ANALYZED
     , case when c.relkind = 'I' then 'YES' else 'NO' end as PARTITIONED
     , case c.relpersistence when 't' then 'YES' else 'NO' end as TEMPORARY
  FROM pg_catalog.pg_index i
  join pg_catalog.pg_class c on i.indexrelid = c.oid
  join pg_catalog.pg_class t on i.indrelid = t.oid
  join pg_catalog.pg_namespace nc on nc.oid = c.relnamespace
  join pg_catalog.pg_namespace nt on nt.oid = t.relnamespace
  left join pg_catalog.pg_tablespace s on c.reltablespace = s.oid
  left join pg_catalog.pg_statistic st on i.indnatts = 1 and i.indkey[0] = st.staattnum and st.starelid = t.oid
 WHERE nc.nspname::text not like 'pg_toast%';

DROP VIEW IF EXISTS oracle.USER_INDEXES CASCADE;
CREATE OR REPLACE VIEW oracle.USER_INDEXES AS SELECT index_name, table_owner, table_name, table_type, uniqueness, tablespace_name, logging, distinct_keys, status, num_rows, last_analyzed, partitioned, temporary FROM oracle.DBA_INDEXES WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_INDEXES for oracle.DBA_INDEXES;
CREATE OR REPLACE SYNONYM public.ALL_INDEXES for oracle.DBA_INDEXES;
CREATE OR REPLACE SYNONYM public.USER_INDEXES for oracle.USER_INDEXES;
CREATE OR REPLACE SYNONYM public.IND for oracle.USER_INDEXES;




-- =============================================================================
-- DBA_INDEX_USAGE
-- ALL_INDEX_USAGE
-- USER_INDEX_USAGE
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_INDEX_USAGE CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_INDEX_USAGE
AS
SELECT i.oid as object_id
     , case when i.relname::text = lower(i.relname::text) then UPPER(i.relname::text) else i.relname::text end AS NAME
     , case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS OWNER
     , pg_stat_get_numscans(i.oid) as TOTAL_ACCESS_COUNT
     , pg_stat_get_tuples_returned(i.oid) as TOTAL_ROWS_RETURNED
  FROM pg_catalog.pg_class i
  join pg_catalog.pg_namespace n on n.oid = i.relnamespace
 WHERE i.relkind in ('i') and n.nspname::text not like 'pg_toast%';

DROP VIEW IF EXISTS oracle.USER_INDEX_USAGE CASCADE;
CREATE OR REPLACE VIEW oracle.USER_INDEX_USAGE AS SELECT object_id, name, total_access_count, total_rows_returned FROM oracle.DBA_INDEX_USAGE WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_INDEX_USAGE for oracle.DBA_INDEX_USAGE;
CREATE OR REPLACE SYNONYM public.ALL_INDEX_USAGE for oracle.DBA_INDEX_USAGE;
CREATE OR REPLACE SYNONYM public.USER_INDEX_USAGE for oracle.USER_INDEX_USAGE;




-- =============================================================================
-- DBA_IND_COLUMNS
-- ALL_IND_COLUMNS
-- USER_IND_COLUMNS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_IND_COLUMNS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_IND_COLUMNS
AS
SELECT case when nc.nspname::text = lower(nc.nspname::text) then UPPER(nc.nspname::text) else nc.nspname::text end AS INDEX_OWNER
     , case when c.relname::text = lower(c.relname::text) then UPPER(c.relname::text) else c.relname::text end AS INDEX_NAME
     , case when nt.nspname::text = lower(nt.nspname::text) then UPPER(nt.nspname::text) else nt.nspname::text end AS TABLE_OWNER
     , case when t.relname::text = lower(t.relname::text) then UPPER(t.relname::text) else t.relname::text end AS TABLE_NAME
     , case when a.attname::text = lower(a.attname::text) then UPPER(a.attname::text) else a.attname::text end AS COLUMN_NAME
     , i.ord as COLUMN_POSITION
     , a.attlen as COLUMN_LENGTH
     , case i.indoption when 0 then 'ASC' when 3 then 'DESC' end as DESCEND
  FROM (select indexrelid, indrelid, unnest(indkey) as indkey, unnest(indoption) as indoption
             , generate_series( 1, array_length(indkey, 1)) as ord
          FROM pg_catalog.pg_index
         WHERE indkey::text != '0') i
  join pg_catalog.pg_class c on i.indexrelid = c.oid
  join pg_catalog.pg_class t on i.indrelid = t.oid
  join pg_catalog.pg_namespace nc on nc.oid = c.relnamespace
  join pg_catalog.pg_namespace nt on nt.oid = t.relnamespace
  join pg_catalog.pg_attribute a on a.attrelid = i.indrelid and i.indkey = a.attnum
 WHERE nc.nspname::text not like 'pg_toast%';

DROP VIEW IF EXISTS oracle.USER_IND_COLUMNS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_IND_COLUMNS AS SELECT index_name, table_owner, table_name, column_name, column_position, column_length, descend FROM oracle.DBA_IND_COLUMNS WHERE INDEX_OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_IND_COLUMNS for oracle.DBA_IND_COLUMNS;
CREATE OR REPLACE SYNONYM public.ALL_IND_COLUMNS for oracle.DBA_IND_COLUMNS;
CREATE OR REPLACE SYNONYM public.USER_IND_COLUMNS for oracle.USER_IND_COLUMNS;




-- =============================================================================
-- DBA_IND_PARTITIONS
-- ALL_IND_PARTITIONS
-- USER_IND_PARTITIONS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_IND_PARTITIONS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_IND_PARTITIONS
AS
SELECT case when ni.nspname::text = lower(ni.nspname::text) then UPPER(ni.nspname::text) else ni.nspname::text end AS INDEX_OWNER
     , case when ci.relname::text = lower(ci.relname::text) then UPPER(ci.relname::text) else ci.relname::text end AS INDEX_NAME
     , case when pi.relname::text = lower(pi.relname::text) then UPPER(pi.relname::text) else pi.relname::text end AS PARTITION_NAME
     , case when nt.nspname::text = lower(nt.nspname::text) then UPPER(nt.nspname::text) else nt.nspname::text end AS TABLE_OWNER
     , case when ct.relname::text = lower(ct.relname::text) then UPPER(ct.relname::text) else ct.relname::text end AS TABLE_NAME
     , coalesce(array_to_string(pt.boundaries, ','), 'MAXVALUE') as HIGH_VALUE
     , length(array_to_string(pt.boundaries, ',')) as HIGH_VALUE_LENGTH
     , row_number() over (partition by pt.parentid order by pt.boundaries) as PARTITION_POSITION
     , coalesce(UPPER(t.spcname::text), 'DEFAULT') as TABLESPACE_NAME
     , case ct.relpersistence when 'p' then 'YES' else 'NO' end as LOGGING
     , pi.reltuples as NUM_ROWS
     , coalesce(pg_stat_get_last_analyze_time(ct.oid), pg_stat_get_last_autoanalyze_time(ct.oid)) as LAST_ANALYZED
  FROM pg_catalog.pg_partition pi
  join pg_catalog.pg_partition pt on pi.indextblid = pt.oid
  join pg_catalog.pg_class ci on pi.parentid = ci.oid
  join pg_catalog.pg_class ct on pt.parentid = ct.oid
  join pg_catalog.pg_namespace ni on ci.relnamespace = ni.oid
  join pg_catalog.pg_namespace nt on ct.relnamespace = nt.oid
  left join pg_catalog.pg_tablespace t on pi.reltablespace = t.oid
 WHERE pi.parttype = 'x';

DROP VIEW IF EXISTS oracle.USER_IND_PARTITIONS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_IND_PARTITIONS AS SELECT index_name, partition_name, table_owner, table_name, high_value, high_value_length, partition_position, tablespace_name, logging, num_rows, last_analyzed FROM oracle.DBA_IND_PARTITIONS WHERE INDEX_OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_IND_PARTITIONS for oracle.DBA_IND_PARTITIONS;
CREATE OR REPLACE SYNONYM public.ALL_IND_PARTITIONS for oracle.DBA_IND_PARTITIONS;
CREATE OR REPLACE SYNONYM public.USER_IND_PARTITIONS for oracle.USER_IND_PARTITIONS;




-- =============================================================================
-- DBA_IND_STATISTICS
-- ALL_IND_STATISTICS
-- USER_IND_STATISTICS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_IND_STATISTICS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_IND_STATISTICS
AS
SELECT OWNER
     , INDEX_NAME
     , TABLE_OWNER
     , TABLE_NAME
     , null as PARTITION_NAME
     , null as PARTITION_POSITION
     , 'INDEX' as OBJECT_TYPE
     , DISTINCT_KEYS
     , NUM_ROWS
     , LAST_ANALYZED
  FROM oracle.DBA_INDEXES
 WHERE partitioned = 'NO'
 union all
select INDEX_OWNER as OWNER
     , INDEX_NAME
     , TABLE_OWNER
     , TABLE_NAME
     , PARTITION_NAME
     , PARTITION_POSITION
     , 'PARTITION' as OBJECT_TYPE
     , null as DISTINCT_KEYS
     , NUM_ROWS
     , LAST_ANALYZED
  FROM oracle.DBA_IND_PARTITIONS;

DROP VIEW IF EXISTS oracle.USER_IND_STATISTICS CASCADE;
CREATE OR REPLACE VIEW oracle.USER_IND_STATISTICS AS SELECT * FROM oracle.DBA_IND_STATISTICS WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_IND_STATISTICS for oracle.DBA_IND_STATISTICS;
CREATE OR REPLACE SYNONYM public.ALL_IND_STATISTICS for oracle.DBA_IND_STATISTICS;
CREATE OR REPLACE SYNONYM public.USER_IND_STATISTICS for oracle.USER_IND_STATISTICS;




-- =============================================================================
-- DBA_PART_INDEXES
-- ALL_PART_INDEXES
-- USER_PART_INDEXES
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_PART_INDEXES CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_PART_INDEXES
AS
SELECT case when n.nspname::text = lower(n.nspname::text) then UPPER(n.nspname::text) else n.nspname::text end AS OWNER
     , case when i.relname::text = lower(i.relname::text) then UPPER(i.relname::text) else i.relname::text end AS INDEX_NAME
     , case when tp.relname::text = lower(tp.relname::text) then UPPER(tp.relname::text) else tp.relname::text end AS TABLE_NAME
     , case tp.partstrategy
       when 'r' then 'RANGE'
       when 'v' then 'VALUE'
       when 'i' then 'INTERVAL'
       when 'l' then 'LIST'
       when 'h' then 'HASH'
       when 'n' then 'INVALID'
       else UPPER(tp.partstrategy::text) end as PARTITIONING_TYPE
     , coalesce(ip.part_count, 0) as PARTITION_COUNT
     , array_length(tp.partkey::int[], 1) as PARTITIONING_KEY_COUNT
     , coalesce(UPPER(s.spcname::text), 'DEFAULT') as DEF_TABLESPACE_NAME
     , case i.relpersistence when 'p' then 'YES' else 'NO' end as DEF_LOGGING
  FROM pg_catalog.pg_index it
  join pg_catalog.pg_class i on i.oid = it.indexrelid
  join pg_catalog.pg_namespace n on i.relnamespace = n.oid
  join pg_catalog.pg_partition tp on tp.parentid = it.indrelid and tp.parttype = 'r'
  left join (select parentid, count(*) part_count FROM pg_catalog.pg_partition group by parentid) ip on ip.parentid = it.indexrelid
  left join pg_catalog.pg_tablespace s on i.reltablespace = s.oid
 WHERE n.nspname not like 'pg_toast%';

DROP VIEW IF EXISTS oracle.USER_PART_INDEXES CASCADE;
CREATE OR REPLACE VIEW oracle.USER_PART_INDEXES AS SELECT index_name, table_name, partitioning_type, partition_count, partitioning_key_count, def_tablespace_name, def_logging FROM oracle.DBA_PART_INDEXES WHERE OWNER = (case when current_schema()::text = lower(current_schema()::text) then upper(current_schema()::text) else current_schema()::text end);

CREATE OR REPLACE SYNONYM public.DBA_PART_INDEXES for oracle.DBA_PART_INDEXES;
CREATE OR REPLACE SYNONYM public.ALL_PART_INDEXES for oracle.DBA_PART_INDEXES;
CREATE OR REPLACE SYNONYM public.USER_PART_INDEXES for oracle.USER_PART_INDEXES;




-- =============================================================================
-- DBA_USERS
-- ALL_USERS
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_USERS CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_USERS
AS
SELECT case when usename::text = lower(usename::text) then UPPER(usename::text) else usename::text end AS USERNAME
     , usesysid as USER_ID
     , passwd as PASSWORD
     , valuntil as EXPIRY_DATE
     , upper(respool::text) as PROFILE
  FROM pg_catalog.pg_user;

CREATE OR REPLACE SYNONYM public.DBA_USERS for oracle.DBA_USERS;
CREATE OR REPLACE SYNONYM public.ALL_USERS for oracle.DBA_USERS;




-- =============================================================================
-- V$PARAMETER
-- =============================================================================
DROP VIEW IF EXISTS oracle.V$PARAMETER CASCADE;
CREATE OR REPLACE VIEW oracle.V$PARAMETER
AS
SELECT NAME
     , case vartype when 'bool' then 1 when 'string' then 2 when 'integer' then 3 when 'enum' then 4 when 'real' then 6 end as TYPE
     , vartype as TYPE_NAME
     , setting as VALUE
     , setting as DISPLAY_VALUE
     , boot_val as DEFAULT_VALUE
     , case when setting = boot_val then 'TRUE' else 'FALSE' end as ISDEFAULT
     , case context when 'internal' then 'FLASE' else 'TRUE' end as ISMODIFIED
     , case context when 'internal' then 'TRUE' else 'FALSE' end as ISADJUSTED
     , short_desc as DESCRIPTION
  FROM pg_catalog.pg_settings;

CREATE OR REPLACE SYNONYM public.V$PARAMETER for oracle.V$PARAMETER;
CREATE OR REPLACE SYNONYM public.GV$PARAMETER for oracle.V$PARAMETER;




-- =============================================================================
-- V$SPPARAMETER
-- =============================================================================
DROP VIEW IF EXISTS oracle.V$SPPARAMETER CASCADE;
CREATE OR REPLACE VIEW oracle.V$SPPARAMETER
AS
SELECT NAME
     , case vartype when 'bool' then 1 when 'string' then 2 when 'integer' then 3 when 'enum' then 4 when 'real' then 6 end as TYPE
     , vartype as TYPE_NAME
     , setting as VALUE
     , setting as DISPLAY_VALUE
     , case when sourcefile is null then 'FALSE' else 'TRUE' end as ISSPECIFIED
  FROM pg_catalog.pg_settings;

CREATE OR REPLACE SYNONYM public.V$SPPARAMETER for oracle.V$SPPARAMETER;
CREATE OR REPLACE SYNONYM public.GV$SPPARAMETER for oracle.V$SPPARAMETER;




-- =============================================================================
-- V$PARAMETER_VALID_VALUES
-- =============================================================================
DROP VIEW IF EXISTS oracle.V$PARAMETER_VALID_VALUES CASCADE;
CREATE OR REPLACE VIEW oracle.V$PARAMETER_VALID_VALUES
AS
SELECT NAME
     , row_number() over (partition by name) as ORDINAL
     , VALUE
     , case when boot_val = VALUE then 'TRUE' else 'FALSE' end as ISDEFAULT
  FROM (select name, boot_val, unnest(enumvals) as VALUE FROM pg_catalog.pg_settings) as p;

CREATE OR REPLACE SYNONYM public.V$PARAMETER_VALID_VALUES for oracle.V$PARAMETER_VALID_VALUES;
CREATE OR REPLACE SYNONYM public.GV$PARAMETER_VALID_VALUES for oracle.V$PARAMETER_VALID_VALUES;




-- =============================================================================
-- V$SESSION
-- =============================================================================
DROP VIEW IF EXISTS oracle.V$SESSION CASCADE;
CREATE OR REPLACE VIEW oracle.V$SESSION
AS
SELECT sessionid as SID
     , usename as USERNAME
     , state as STATUS
     , coalesce(client_hostname, client_addr::text) as MACHINE
     , client_port as PORT
     , application_name as PROGRAM
     , query_id as  SQL_ID
     , query as SQL_TEXT
     , connection_info as CLIENT_INFO
     , backend_start as LOGON_TIME
FROM pg_catalog.pg_stat_activity;

CREATE OR REPLACE SYNONYM public.V$SESSION for oracle.V$SESSION;
CREATE OR REPLACE SYNONYM public.GV$SESSION for oracle.V$SESSION;




-- =============================================================================
-- DBA_DETAIL_PRIVILEGES
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_DETAIL_PRIVILEGES CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_DETAIL_PRIVILEGES
AS
SELECT /*+no nestloop*/ t.oid, t.oid_class, t.type, t.privilege_type
     , r.rolname as owner, n.nspname as schema
     , t.name, t.column_name
     , ro.rolname as grantor, re.rolname as grantee
     , t.privilege, t.is_grantable
  FROM (select oid, 'pg_default_acl' as oid_class
             , case defaclobjtype when 'r' then 'RELATION' when 'S' then 'SEQUENCE' when 'f' then 'FUNCTION' when 'T' then 'TYPE' when 'n' then 'SCHEMA' else defaclobjtype::text end as type
             , 'DEFAULT PRIVILEGES' as privilege_type
             , defaclrole as owner
             , defaclnamespace as schema
             , null as NAME
             , NULL as column_name
             , (aclexplode(defaclacl)).grantor AS grantor
             , (aclexplode(defaclacl)).grantee AS grantee
             , (aclexplode(defaclacl)).privilege_type AS privilege
             , (aclexplode(defaclacl)).is_grantable AS is_grantable
          from pg_catalog.pg_default_acl
         where defaclacl is not null
         union all
        select oid, 'pg_class' as oid_class
             , case relkind when 'r' then 'TABLE' when 'S' then 'SEQUENCE' when 'v' then 'VIEW' when 'm' then 'MATERIALIZED VIEW' when 'f' then 'FOREIGN TABLE' when 'p' then 'PARTITIONED TABLE' else relkind::text end as type
             , case relkind when 'S' then 'SEQUENCE' else 'TABLE' end as privilege_type
             , relowner as owner
             , relnamespace as schema
             , relname::text as NAME
             , NULL as column_name
             , (aclexplode(relacl)).grantor AS grantor
             , (aclexplode(relacl)).grantee AS grantee
             , (aclexplode(relacl)).privilege_type AS privilege
             , (aclexplode(relacl)).is_grantable AS is_grantable
          from pg_catalog.pg_class
         where relacl is not null
         union all
        select c.oid, 'pg_class' as oid_class
             , 'COLUMN' as type
             , 'TABLE (COLUMN)' as privilege_type
             , c.relowner as owner
             , c.relnamespace as schema
             , c.relname::text as name
             , a.attname::text as column_name
             , (aclexplode(a.attacl)).grantor AS grantor
             , (aclexplode(a.attacl)).grantee AS grantee
             , (aclexplode(a.attacl)).privilege_type AS privilege
             , (aclexplode(a.attacl)).is_grantable AS is_grantable
          from pg_catalog.pg_attribute as a
          join pg_catalog.pg_class as c on a.attrelid = c.oid
         where a.attacl is not null
         union all
        select oid, 'pg_database' as oid_class
             , 'DATABASE' as type
             , 'DATABASE' as privilege_type
             , datdba as owner
             , null as schema
             , datname::text as name
             , null as column_name
             , (aclexplode(datacl)).grantor AS grantor
             , (aclexplode(datacl)).grantee AS grantee
             , (aclexplode(datacl)).privilege_type AS privilege
             , (aclexplode(datacl)).is_grantable AS is_grantable
          from pg_catalog.pg_database
         where datacl is not null
         union all
        select oid, 'pg_foreign_data_wrapper' as oid_class
             , 'FOREIGN DATA WRAPPER' as type
             , 'FOREIGN DATA WRAPPER' as privilege_type
             , fdwowner as owner
             , null as schema
             , fdwname::text as name
             , null as column_name
             , (aclexplode(fdwacl)).grantor AS grantor
             , (aclexplode(fdwacl)).grantee AS grantee
             , (aclexplode(fdwacl)).privilege_type AS privilege
             , (aclexplode(fdwacl)).is_grantable AS is_grantable
          from pg_catalog.pg_foreign_data_wrapper
         where fdwacl is not null
         union all
        select oid, 'pg_foreign_server' as oid_class
             , 'FOREIGN SERVER' as type
             , 'FOREIGN SERVER' as privilege_type
             , srvowner as owner
             , null as schema
             , srvname::text as name
             , null as column_name
             , (aclexplode(srvacl)).grantor AS grantor
             , (aclexplode(srvacl)).grantee AS grantee
             , (aclexplode(srvacl)).privilege_type AS privilege
             , (aclexplode(srvacl)).is_grantable AS is_grantable
          from pg_catalog.pg_foreign_server
         where srvacl is not null
         union all
        select oid, 'pg_type' as oid_class
             , case typtype when 'b' then 'BASE' when 'c' then 'COMPOSITE' when 'd' then 'DOMAIN' when 'e'  then 'ENUM' when 'p' then 'PSEUDO' when 'r' then 'RANGE' else typtype::text end as type
             , case typtype when 'd' then 'DOMAIN' else 'TYPE' end as privilege_type
             , typowner as owner
             , typnamespace as schema
             , typname::text as name
             , null as column_name
             , (aclexplode(typacl)).grantor AS grantor
             , (aclexplode(typacl)).grantee AS grantee
             , (aclexplode(typacl)).privilege_type AS privilege
             , (aclexplode(typacl)).is_grantable AS is_grantable
          from pg_catalog.pg_type
         where typacl is not null
         union all
        select oid, 'pg_proc' as oid_class
             , case prokind when 'f' then 'FUNCTION' when 'p' then 'PROCEDURE' when 'a' then 'AGGREGATE' when 'w' then 'WINDOW' else prokind::text end as type
             , case prokind when 'p' then 'PROCEDURE' else 'FUNCTION' end as privilege_type
             , proowner as owner
             , pronamespace as schema
             , proname::text as name
             , null as column_name
             , (aclexplode(proacl)).grantor AS grantor
             , (aclexplode(proacl)).grantee AS grantee
             , (aclexplode(proacl)).privilege_type AS privilege
             , (aclexplode(proacl)).is_grantable AS is_grantable
          from pg_catalog.pg_proc
         where proacl is not null
         union all
        select oid, 'pg_language' as oid_class
             , 'LANGUAGE' as type
             , 'LANGUAGE' as privilege_type
             , lanowner as owner
             , null as schema
             , lanname::text as name
             , null as column_name
             , (aclexplode(lanacl)).grantor AS grantor
             , (aclexplode(lanacl)).grantee AS grantee
             , (aclexplode(lanacl)).privilege_type AS privilege
             , (aclexplode(lanacl)).is_grantable AS is_grantable
          from pg_catalog.pg_language
         where lanacl is not null
         union all
        select oid, 'pg_largeobject_metadata' as oid_class
             , 'LARGE OBJECT' as type
             , 'LARGE OBJECT' as privilege_type
             , lomowner as owner
             , null as schema
             , oid::text as name
             , null as column_name
             , (aclexplode(lomacl)).grantor AS grantor
             , (aclexplode(lomacl)).grantee AS grantee
             , (aclexplode(lomacl)).privilege_type AS privilege
             , (aclexplode(lomacl)).is_grantable AS is_grantable
          from pg_catalog.pg_largeobject_metadata
         where lomacl is not null
         union all
        select oid, 'pg_namespace' as oid_class
             , 'SCHEMA' as type
             , 'SCHEMA' as privilege_type
             , nspowner as owner
             , null as schema
             , nspname::text as name
             , null as column_name
             , (aclexplode(nspacl)).grantor AS grantor
             , (aclexplode(nspacl)).grantee AS grantee
             , (aclexplode(nspacl)).privilege_type AS privilege
             , (aclexplode(nspacl)).is_grantable AS is_grantable
          from pg_catalog.pg_namespace
         where nspacl is not null
         union all
        select oid, 'pg_tablespace' as oid_class
             , 'TABLESPACE' as type
             , 'TABLESPACE' as privilege_type
             , spcowner as owner
             , null as schema
             , spcname::text as name
             , null as column_name
             , (aclexplode(spcacl)).grantor AS grantor
             , (aclexplode(spcacl)).grantee AS grantee
             , (aclexplode(spcacl)).privilege_type AS privilege
             , (aclexplode(spcacl)).is_grantable AS is_grantable
          from pg_catalog.pg_tablespace
         where spcacl is not null
       ) t
  join pg_catalog.pg_roles r on t.owner = r.oid
  join pg_catalog.pg_namespace n on t.schema = n.oid
  left join pg_catalog.pg_roles ro on t.grantor = ro.oid
  left join pg_catalog.pg_roles re on t.grantee = re.oid
 where t.grantor != t.grantee
   and t.grantee != 0
   and t.grantor != 0;

CREATE OR REPLACE SYNONYM public.DBA_DETAIL_PRIVILEGES for oracle.DBA_DETAIL_PRIVILEGES;




-- =============================================================================
-- DBA_ALL_PRIVILEGES_SQL
-- =============================================================================
DROP VIEW IF EXISTS oracle.DBA_ALL_PRIVILEGES_SQL CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_ALL_PRIVILEGES_SQL
AS
with all_privs as (select oid, oid_class, type, privilege_type, owner, schema, name, column_name, grantor, grantee, is_grantable
                     from oracle.dba_detail_privileges
                    group by oid, oid_class, type, privilege_type, owner, schema, name, column_name, grantor, grantee, is_grantable
                   having (privilege_type = 'TABLE' and count(*) = 7)
                       or (privilege_type = 'TABLE (COLUMN)' and count(*) = 4)
                       or (privilege_type = 'SEQUENCE' and count(*) = 3)
                       or (privilege_type = 'DATABASE' and count(*) = 3)
                       or (privilege_type = 'LARGE OBJECT' and count(*) = 2)
                       or (privilege_type = 'SCHEMA' and count(*) = 2)
                       or (privilege_type = 'DEFAULT PRIVILEGES' and type = 'RELATION' and count(*) = 7)
                       or (privilege_type = 'DEFAULT PRIVILEGES' and type = 'SEQUENCE' and count(*) = 3)
                       or (privilege_type = 'DEFAULT PRIVILEGES' and type = 'SCHEMA' and count(*) = 2)
                  )
SELECT t.*
     , case when privilege_type = 'TABLE (COLUMN)'
            then 'GRANT '||privilege||' ('||column_name||') on TABLE '||schema||'.'||name||' to '||grantee
            when privilege_type = 'DEFAULT PRIVILEGES'
            then 'alter default privileges for user '||grantor||' GRANT '||privilege||' on '||(case type when 'RELATION' then 'TABLE' else type end)||'S to '||grantee
            else 'GRANT '||privilege||' on '||privilege_type||' '||(case when schema is not null then schema||'.'||name else name end)||' to '||grantee
       end as grant_sql
     , case when privilege_type = 'TABLE (COLUMN)'
            then 'REVOKE '||privilege||' ('||column_name||') on TABLE '||schema||'.'||name||' from '||grantee
            when privilege_type = 'DEFAULT PRIVILEGES'
            then 'alter default privileges for user '||grantor||' REVOKE '||privilege||' on '||(case type when 'RELATION' then 'TABLE' else type end)||'S from '||grantee
            else 'REVOKE '||privilege||' on '||privilege_type||' '||(case when schema is not null then schema||'.'||name else name end)||' from '||grantee
       end as revoke_sql
  from (select oid, oid_class, type, privilege_type, owner, schema, name, column_name, grantor, grantee, 'ALL' as privilege, is_grantable
          from all_privs
         union all
        select oid, oid_class, type, privilege_type, owner, schema, name, column_name, grantor, grantee, privilege, is_grantable
          from oracle.dba_detail_privileges x
         where not exists (select 1 from all_privs where oid = x.oid and grantor = x.grantor and grantee = x.grantee)
       ) t;

DROP VIEW IF EXISTS oracle.DBA_ALL_PRIVILEGES CASCADE;
CREATE OR REPLACE VIEW oracle.DBA_ALL_PRIVILEGES AS SELECT oid, oid_class, type, privilege_type, owner, schema, name, column_name, grantor, grantee, privilege, is_grantable FROM oracle.DBA_ALL_PRIVILEGES_SQL;

CREATE OR REPLACE SYNONYM public.DBA_ALL_PRIVILEGES_SQL for oracle.DBA_ALL_PRIVILEGES_SQL;
CREATE OR REPLACE SYNONYM public.DBA_ALL_PRIVILEGES for oracle.DBA_ALL_PRIVILEGES;


-- Exit current session
\q
