CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS public.sensors;

CREATE TABLE public.sensors (
    sensor_id text PRIMARY KEY,
    sensor_name text NOT NULL,
    available_variables text[] NOT NULL,
    valid_start_datetime timestamptz NOT NULL,
    valid_end_datetime timestamptz,
    geom geometry(Point, 4326) NOT NULL
);

INSERT INTO public.sensors (sensor_id, sensor_name, available_variables, valid_start_datetime, valid_end_datetime, geom) VALUES
    ('371', 'Station 35', ARRAY['temperature', 'humidity'], '2001-10-30T14:24:55Z', '2001-10-30T14:24:55Z', ST_SetSRID(ST_MakePoint(-75, 45), 4326)),
    ('377', 'Station 35', ARRAY['temperature', 'humidity', 'pressure'], '2002-10-30T18:31:38Z', '2002-10-30T18:31:38Z', ST_SetSRID(ST_MakePoint(-75, 45), 4326)),
    ('238', 'Station 2147', ARRAY['temperature'], '2007-10-30T08:57:29Z', NULL, ST_SetSRID(ST_MakePoint(-79, 43), 4326)),
    ('297', 'Station 2147', ARRAY['temperature', 'wind_speed'], '2003-10-30T07:37:29Z', '2003-10-30T07:37:29Z', ST_SetSRID(ST_MakePoint(-79, 43), 4326)),
    ('964', 'Station 604', ARRAY['temperature', 'precipitation'], '2000-10-30T18:24:39Z', NULL, ST_SetSRID(ST_MakePoint(-122, 49), 4326));