-- months_betwen
CREATE FUNCTION pg_catalog.months_between(d1 timestamp,d2 timestamp)
RETURNS integer AS
'SELECT (extract(year from age(d1,d2))*12 + extract(month from age(d1,d2)))::integer'
LANGUAGE 'sql';


-- sys_guid
CREATE or replace FUNCTION pg_catalog.sys_guid()
RETURNS varchar
AS $$
BEGIN
    RETURN upper(md5(random()::text || clock_timestamp()::text));
END;
$$ LANGUAGE plpgsql;
