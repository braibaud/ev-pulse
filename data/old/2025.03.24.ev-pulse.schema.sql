--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4 (Postgres.app)
-- Dumped by pg_dump version 17.4 (Postgres.app)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: dbo; Type: SCHEMA; Schema: -; Owner: braibau
--

CREATE SCHEMA dbo;


ALTER SCHEMA dbo OWNER TO braibau;

--
-- Name: entity_key; Type: TYPE; Schema: dbo; Owner: braibau
--

CREATE TYPE dbo.entity_key AS (
	id uuid,
	entity_type_id integer
);


ALTER TYPE dbo.entity_key OWNER TO braibau;

--
-- Name: pair_real; Type: TYPE; Schema: dbo; Owner: braibau
--

CREATE TYPE dbo.pair_real AS (
	name text,
	value real
);


ALTER TYPE dbo.pair_real OWNER TO braibau;

--
-- Name: pair_text; Type: TYPE; Schema: dbo; Owner: braibau
--

CREATE TYPE dbo.pair_text AS (
	name text,
	value text
);


ALTER TYPE dbo.pair_text OWNER TO braibau;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: entity_attribute; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.entity_attribute (
    entity_key dbo.entity_key NOT NULL,
    attribute_id integer NOT NULL,
    value text,
    unit text,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE dbo.entity_attribute OWNER TO braibau;

--
-- Name: assign_entity_attributes(dbo.entity_key, dbo.pair_text[], text); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.assign_entity_attributes(p_entity_key dbo.entity_key, p_entity_attributes dbo.pair_text[], p_add_or_replace_attributes text DEFAULT 'ADD'::text) RETURNS SETOF dbo.entity_attribute
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_attribute_rec record;
BEGIN
    -- Check if the entity exists
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.entity
        WHERE key = p_entity_key
    )
    THEN RAISE EXCEPTION 'Invalid entity key';
    END IF;

    -- Handle ADD or REPLACE logic for attributes
    IF p_add_or_replace_attributes = 'REPLACE' THEN
        -- Delete existing attributes for the entity
        DELETE FROM dbo.entity_attribute
        WHERE entity_key = p_entity_key;
    ELSIF p_add_or_replace_attributes != 'ADD' THEN
        RAISE EXCEPTION 'Invalid value for p_add_or_replace_attributes: %', p_add_or_replace_attributes;
    END IF;

    -- Insert or update attributes
    FOR v_attribute_rec IN
        SELECT dbo.get_attribute_id(entity_attribute_pairs.name) as id,
               entity_attribute_pairs.value as value
        FROM unnest(p_entity_attributes) as entity_attribute_pairs
        WHERE dbo.get_attribute_id(entity_attribute_pairs.name) IS NOT NULL
    LOOP
        INSERT INTO dbo.entity_attribute (
            entity_key,
            attribute_id,
            is_active,
            value,
            unit
        )
        VALUES (
            p_entity_key,
            v_attribute_rec.id,
            true,
            v_attribute_rec.value,
            NULL
        )
        ON CONFLICT (
            entity_key,
            attribute_id
        )
        DO UPDATE SET value = v_attribute_rec.value;
    END LOOP;

    -- Return the entity attributes
    RETURN QUERY
    SELECT *
    FROM dbo.entity_attribute
    WHERE entity_key = p_entity_key;
END;
$$;


ALTER FUNCTION dbo.assign_entity_attributes(p_entity_key dbo.entity_key, p_entity_attributes dbo.pair_text[], p_add_or_replace_attributes text) OWNER TO braibau;

--
-- Name: entity_feature; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.entity_feature (
    entity_key dbo.entity_key NOT NULL,
    feature_id integer NOT NULL,
    price real,
    currency text,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE dbo.entity_feature OWNER TO braibau;

--
-- Name: assign_entity_features(dbo.entity_key, dbo.pair_real[], text); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.assign_entity_features(p_entity_key dbo.entity_key, p_entity_features dbo.pair_real[], p_add_or_replace_features text DEFAULT 'ADD'::text) RETURNS SETOF dbo.entity_feature
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_feature_rec record;
BEGIN
    -- Check if the entity exists
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.entity
        WHERE key = p_entity_key
    )
    THEN RAISE EXCEPTION 'Invalid entity key';
    END IF;

    -- Handle ADD or REPLACE logic for features
    IF p_add_or_replace_features = 'REPLACE' THEN
        -- Delete existing features for the entity
        DELETE FROM dbo.entity_feature
        WHERE entity_key = p_entity_key;
    ELSIF p_add_or_replace_features != 'ADD' THEN
        RAISE EXCEPTION 'Invalid value for p_add_or_replace_features: %', p_add_or_replace_features;
    END IF;

    -- Insert or update features
    FOR v_feature_rec IN
        SELECT dbo.get_feature_id(entity_feature_pairs.name) as id,
               entity_feature_pairs.value as value
        FROM unnest(p_entity_features) as entity_feature_pairs
        WHERE dbo.get_feature_id(entity_feature_pairs.name) IS NOT NULL
    LOOP
        INSERT INTO dbo.entity_feature (
            entity_key,
            feature_id,
            is_active,
            price,
            currency
        )
        VALUES (
            p_entity_key,
            v_feature_rec.id,
            true,
            v_feature_rec.value,
            NULL
        )
        ON CONFLICT (
            entity_key,
            feature_id
        )
        DO UPDATE SET price = v_feature_rec.value;
    END LOOP;

    -- Return the entity features
    RETURN QUERY
    SELECT *
    FROM dbo.entity_feature
    WHERE entity_key = p_entity_key;
END;
$$;


ALTER FUNCTION dbo.assign_entity_features(p_entity_key dbo.entity_key, p_entity_features dbo.pair_real[], p_add_or_replace_features text) OWNER TO braibau;

--
-- Name: check_unique_name_entity_type(); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.check_unique_name_entity_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if a record with the same name and entity_type_id already exists
    IF EXISTS (
        SELECT 1
        FROM dbo.entity
        WHERE name = NEW.name
          AND (key).entity_type_id = (NEW.key).entity_type_id
          AND (key).id <> (NEW.key).id -- Allow updating the same record
    ) THEN
        RAISE EXCEPTION 'Duplicate entry: name and entity_type_id must be unique';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION dbo.check_unique_name_entity_type() OWNER TO braibau;

--
-- Name: check_unique_vehicle_parts(); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.check_unique_vehicle_parts() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if exists (select 1 from dbo.vehicle_part where vehicle_id = new.vehicle_id and entity_key = new.entity_key) then
        raise exception 'Each part must be unique for a vehicle';
    end if;
    return new;
end;
$$;


ALTER FUNCTION dbo.check_unique_vehicle_parts() OWNER TO braibau;

--
-- Name: create_attribute(text, text, text, boolean, boolean, boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.create_attribute(p_name text, p_group_name text, p_default_unit text, p_is_active boolean DEFAULT true, p_is_inheritable boolean DEFAULT true, p_is_overridable boolean DEFAULT true) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_attribute_id integer;
    v_group_id integer;
BEGIN
    -- Check if the group exists, if not create it
    SELECT id INTO v_group_id
    FROM dbo.group
    WHERE lower(name) = lower(p_group_name);

    IF NOT FOUND THEN
        INSERT INTO dbo.group (name)
        VALUES (p_group_name)
        RETURNING id INTO v_group_id;
    END IF;

    -- Check for duplicate attribute name (case-insensitive)
    IF EXISTS (
        SELECT 1
        FROM dbo.attribute
        WHERE lower(name) = lower(p_name)
    ) THEN
        SELECT id into v_attribute_id
        FROM dbo.attribute
        WHERE lower(name) = lower(p_name);
    ELSE
        -- Insert new attribute
        INSERT INTO dbo.attribute (group_id, is_active, name, default_unit, is_inheritable, is_overridable)
        VALUES (v_group_id, p_is_active, p_name, p_default_unit, p_is_inheritable, p_is_overridable)
        RETURNING id INTO v_attribute_id;
    END IF;

    -- Return the created attribute id
    RETURN v_attribute_id;
END;
$$;


ALTER FUNCTION dbo.create_attribute(p_name text, p_group_name text, p_default_unit text, p_is_active boolean, p_is_inheritable boolean, p_is_overridable boolean) OWNER TO braibau;

--
-- Name: create_entity(text, text, dbo.entity_key, boolean, boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.create_entity(p_name text, p_entity_type_name text, p_parent_key dbo.entity_key, p_is_virtual boolean, p_is_active boolean) RETURNS dbo.entity_key
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_entity_type_id integer;
    v_new_entity_key dbo.entity_key;
BEGIN
    -- Validate entity type name
    SELECT id INTO v_entity_type_id
    FROM dbo.entity_type
    WHERE name = p_entity_type_name;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid entity-type name: %', p_entity_type_name;
    END IF;

    -- Check for duplicate creation
    IF EXISTS (
        SELECT 1
        FROM dbo.entity
        WHERE name = p_name
          AND (key).entity_type_id = v_entity_type_id
    ) THEN
        SELECT (key).id, (key).entity_type_id INTO v_new_entity_key
        FROM dbo.entity
        WHERE name = p_name
          AND (key).entity_type_id = v_entity_type_id;
    ELSE
        -- Insert new entity
        INSERT INTO dbo.entity (
            key,
            parent_key,
            name,
            is_virtual,
            is_active
        )
        VALUES (
            (gen_random_uuid()::uuid, v_entity_type_id)::dbo.entity_key,
            p_parent_key,
            p_name,
            p_is_virtual,
            p_is_active
        )
        RETURNING (key).id, (key).entity_type_id INTO v_new_entity_key;
    END IF;

    -- Return the created entity_key
    RETURN v_new_entity_key;
END;
$$;


ALTER FUNCTION dbo.create_entity(p_name text, p_entity_type_name text, p_parent_key dbo.entity_key, p_is_virtual boolean, p_is_active boolean) OWNER TO braibau;

--
-- Name: create_feature(text, text, text, boolean, boolean, boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.create_feature(p_name text, p_group_name text, p_default_currency text, p_is_active boolean DEFAULT true, p_is_inheritable boolean DEFAULT true, p_is_overridable boolean DEFAULT true) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_feature_id integer;
    v_group_id integer;
BEGIN
    -- Check if the group exists, if not create it
    SELECT id INTO v_group_id
    FROM dbo.group
    WHERE lower(name) = lower(p_group_name);

    IF NOT FOUND THEN
        INSERT INTO dbo.group (name)
        VALUES (p_group_name)
        RETURNING id INTO v_group_id;
    END IF;

    -- Check for duplicate feature name (case-insensitive)
    IF EXISTS (
        SELECT 1
        FROM dbo.feature
        WHERE lower(name) = lower(p_name)
    ) THEN
        SELECT id INTO v_feature_id
        FROM dbo.feature
        WHERE lower(name) = lower(p_name);
    ELSE
        -- Insert new feature
        INSERT INTO dbo.feature (group_id, is_active, name, default_currency, is_inheritable, is_overridable)
        VALUES (v_group_id, p_is_active, p_name, p_default_currency, p_is_inheritable, p_is_overridable)
        RETURNING id INTO v_feature_id;
    END IF;

    -- Return the created feature id
    RETURN v_feature_id;
END;
$$;


ALTER FUNCTION dbo.create_feature(p_name text, p_group_name text, p_default_currency text, p_is_active boolean, p_is_inheritable boolean, p_is_overridable boolean) OWNER TO braibau;

--
-- Name: create_option_pack(dbo.entity_key, text, text[], text); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.create_option_pack(p_parent_entity_key dbo.entity_key, p_option_pack_name text, p_feature_names text[], p_add_or_replace_features text DEFAULT 'ADD'::text) RETURNS dbo.entity_key
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_option_pack_entity_key dbo.entity_key;
    v_feature_id integer;
    v_existing_option_pack dbo.entity%ROWTYPE;
    v_feature_rec record;
BEGIN
    -- Check if the parent entity exists
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.entity
        WHERE key = p_parent_entity_key
    )
    THEN RAISE EXCEPTION 'Invalid parent entity key';
    END IF;

    -- Check if the option pack already exists for the given parent
    SELECT e.* INTO v_existing_option_pack
    FROM dbo.entity e
    WHERE e.name = p_option_pack_name
      AND e.parent_key = p_parent_entity_key
      AND (e.key).entity_type_id = dbo.get_entity_type_id('Option Pack');

    IF FOUND THEN
        RAISE NOTICE 'Option pack already exists';
        v_option_pack_entity_key := v_existing_option_pack.key;

        -- Handle ADD or REPLACE logic for features
        IF p_add_or_replace_features = 'REPLACE' THEN
            -- Delete existing features for the option pack
            DELETE FROM dbo.entity_feature
            WHERE entity_key = v_option_pack_entity_key;
        ELSIF p_add_or_replace_features != 'ADD' THEN
            RAISE EXCEPTION 'Invalid value for p_add_or_replace_features: %', p_add_or_replace_features;
        END IF;
    ELSE
        -- Create a new option pack entity
        INSERT INTO dbo.entity (
            key,
            parent_key,
            name,
            is_virtual,
            is_active
        )
        VALUES (
            (gen_random_uuid(), dbo.get_entity_type_id('Option Pack')),
            p_parent_entity_key,
            p_option_pack_name,
            true,
            true
        )
        RETURNING key
        INTO v_option_pack_entity_key;
    END IF;

    -- Add features to the option pack
    FOR v_feature_rec IN
        SELECT dbo.get_feature_id(feature_name) as id
        FROM unnest(p_feature_names) AS feature_name
        WHERE dbo.get_feature_id(feature_name) IS NOT NULL
    LOOP
        INSERT INTO dbo.entity_feature (
            entity_key,
            feature_id,
            is_active,
            price,
            currency
        )
        VALUES (
            v_option_pack_entity_key,
            v_feature_rec.id,
            true,
            NULL,
            NULL
        )
        ON CONFLICT (
            entity_key,
            feature_id
        )
        DO NOTHING;
    END LOOP;

    -- Return the created or existing option pack entity key
    RETURN v_option_pack_entity_key;
END;
$$;


ALTER FUNCTION dbo.create_option_pack(p_parent_entity_key dbo.entity_key, p_option_pack_name text, p_feature_names text[], p_add_or_replace_features text) OWNER TO braibau;

--
-- Name: create_vehicule(text, dbo.entity_key[], boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.create_vehicule(p_name text, p_entities dbo.entity_key[], p_is_active boolean DEFAULT true) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_vehicle_id uuid;
    v_entity_key dbo.entity_key;
BEGIN
    -- Check for duplicate entities in the array
    FOR i IN 1..array_length(p_entities, 1) LOOP
        FOR j IN (i + 1)..array_length(p_entities, 1) LOOP
            IF p_entities[i] = p_entities[j] THEN
                RAISE EXCEPTION 'Duplicate entities detected in the array';
            END IF;
        END LOOP;
    END LOOP;

    -- Insert new vehicle
    INSERT INTO dbo.vehicle (vehicle_id, name, is_active)
    VALUES (gen_random_uuid(), p_name, p_is_active)
    RETURNING vehicle_id INTO v_vehicle_id;

    -- Insert vehicle parts
    FOREACH v_entity_key IN ARRAY p_entities LOOP
        -- Validate entity existence
        IF NOT EXISTS (SELECT 1 FROM dbo.entity WHERE id = v_entity_key.id AND entity_type_id = v_entity_key.entity_type_id) THEN
            RAISE EXCEPTION 'Invalid entity key: (%)', v_entity_key;
        END IF;

        -- Insert into vehicle_part
        INSERT INTO dbo.vehicle_part (vehicle_id, entity_key, is_active)
        VALUES (v_vehicle_id, v_entity_key, true);
    END LOOP;

    -- Return the created vehicle_id
    RETURN v_vehicle_id;
END;
$$;


ALTER FUNCTION dbo.create_vehicule(p_name text, p_entities dbo.entity_key[], p_is_active boolean) OWNER TO braibau;

--
-- Name: get_attribute_id(text); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_attribute_id(p_attribute_name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    v_attribute_id integer;
begin
    select id into v_attribute_id
    from dbo.attribute
    where lower(name) = lower(p_attribute_name);

    return v_attribute_id;
end;
$$;


ALTER FUNCTION dbo.get_attribute_id(p_attribute_name text) OWNER TO braibau;

--
-- Name: get_entity_attributes(dbo.entity_key); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_entity_attributes(p_key dbo.entity_key) RETURNS TABLE(entity_key dbo.entity_key, attribute_id integer, is_active boolean, value text, unit text, is_inherited boolean, source_entity_key dbo.entity_key)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE entity_hierarchy AS (
        SELECT key, parent_key, key AS source_entity_key
        FROM dbo.entity
        WHERE key = p_key
        UNION ALL
        SELECT e.key, e.parent_key, eh.source_entity_key
        FROM dbo.entity e
        INNER JOIN entity_hierarchy eh ON e.key = eh.parent_key
    )
    SELECT ea.entity_key, ea.attribute_id, ea.is_active, ea.value, ea.unit,
           ea.entity_key != eh.key AS is_inherited,
           eh.source_entity_key
    FROM dbo.entity_attribute ea
    INNER JOIN entity_hierarchy eh ON ea.entity_key = eh.key
    INNER JOIN dbo.attribute a ON ea.attribute_id = a.id
    WHERE a.is_inheritable OR ea.entity_key = p_key
    ORDER BY is_inherited, eh.key;
END;
$$;


ALTER FUNCTION dbo.get_entity_attributes(p_key dbo.entity_key) OWNER TO braibau;

--
-- Name: get_entity_features(dbo.entity_key); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_entity_features(p_key dbo.entity_key) RETURNS TABLE(entity_key dbo.entity_key, feature_id integer, is_optional boolean, is_active boolean, price real, currency text, is_inherited boolean, source_entity_key dbo.entity_key)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH RECURSIVE entity_hierarchy AS (
        SELECT key, parent_key, key AS source_entity_key
        FROM dbo.entity
        WHERE key = p_key
        UNION ALL
        SELECT e.key, e.parent_key, eh.source_entity_key
        FROM dbo.entity e
        INNER JOIN entity_hierarchy eh ON e.key = eh.parent_key
    )
    SELECT ef.entity_key, ef.feature_id, ef.is_optional, ef.is_active, ef.price, ef.currency,
           ef.entity_key != eh.key AS is_inherited,
           eh.source_entity_key
    FROM dbo.entity_feature ef
    INNER JOIN entity_hierarchy eh ON ef.entity_key = eh.key
    INNER JOIN dbo.feature f ON ef.feature_id = f.id
    WHERE f.is_inheritable OR ef.entity_key = p_key
    ORDER BY is_inherited, eh.key;
END;
$$;


ALTER FUNCTION dbo.get_entity_features(p_key dbo.entity_key) OWNER TO braibau;

--
-- Name: get_entity_type_id(text); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_entity_type_id(p_entity_type_name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    v_entity_type_id integer;
begin
    select id into v_entity_type_id
    from dbo.entity_type
    where lower(name) = lower(p_entity_type_name);

    return v_entity_type_id;
end;
$$;


ALTER FUNCTION dbo.get_entity_type_id(p_entity_type_name text) OWNER TO braibau;

--
-- Name: get_entity_type_name(integer); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_entity_type_name(p_entity_type_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
    v_entity_type_name text;
begin
    select name into v_entity_type_name
    from dbo.entity_type
    where id = p_entity_type_id;

    return v_entity_type_name;
end;
$$;


ALTER FUNCTION dbo.get_entity_type_name(p_entity_type_id integer) OWNER TO braibau;

--
-- Name: get_feature_id(text); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_feature_id(p_feature_name text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    v_feature_id integer;
begin
    select id into v_feature_id
    from dbo.feature
    where lower(name) = lower(p_feature_name);

    return v_feature_id;
end;
$$;


ALTER FUNCTION dbo.get_feature_id(p_feature_name text) OWNER TO braibau;

--
-- Name: get_nearest_parent(dbo.entity_key, integer, integer); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_nearest_parent(p_key dbo.entity_key, p_target_entity_type_id integer, p_max_depth integer DEFAULT 10) RETURNS dbo.entity_key
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN (
        WITH RECURSIVE parent_hierarchy AS (
            SELECT key, parent_key, 1 AS depth
            FROM dbo.entity
            WHERE key = p_key
            UNION ALL
            SELECT e.key, e.parent_key, ph.depth + 1
            FROM dbo.entity e
            INNER JOIN parent_hierarchy ph ON e.key = ph.parent_key
            WHERE ph.depth < p_max_depth
        )
        SELECT parent_key
        FROM parent_hierarchy
        WHERE parent_key.entity_type_id = p_target_entity_type_id
        ORDER BY depth, key
        LIMIT 1
    );
END;
$$;


ALTER FUNCTION dbo.get_nearest_parent(p_key dbo.entity_key, p_target_entity_type_id integer, p_max_depth integer) OWNER TO braibau;

--
-- Name: entity; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.entity (
    key dbo.entity_key NOT NULL,
    parent_key dbo.entity_key,
    name text NOT NULL,
    is_virtual boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    description text,
    CONSTRAINT chk_entity_key_entity_type_id_not_null CHECK (((key).entity_type_id IS NOT NULL))
);


ALTER TABLE dbo.entity OWNER TO braibau;

--
-- Name: get_nearest_parent_entity(dbo.entity_key, integer, integer); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_nearest_parent_entity(p_key dbo.entity_key, p_target_entity_type_id integer, p_max_depth integer DEFAULT 10) RETURNS dbo.entity
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_parent_key dbo.entity_key;
    v_parent_entity dbo.entity%ROWTYPE;
BEGIN
    v_parent_key := dbo.get_nearest_parent(p_key, p_target_entity_type_id, p_max_depth);

    IF v_parent_key IS NOT NULL THEN
        SELECT * INTO v_parent_entity
        FROM dbo.entity
        WHERE key = v_parent_key;

        RETURN v_parent_entity;
    ELSE
        RETURN NULL;
    END IF;
END;
$$;


ALTER FUNCTION dbo.get_nearest_parent_entity(p_key dbo.entity_key, p_target_entity_type_id integer, p_max_depth integer) OWNER TO braibau;

--
-- Name: get_vehicle_attributes(uuid); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_vehicle_attributes(p_vehicle_id uuid) RETURNS TABLE(entity_id uuid, entity_type_id integer, entity_name text, attribute_id integer, is_active boolean, value text, unit text, is_inherited boolean, source_entity_id uuid, source_entity_type_id integer)
    LANGUAGE plpgsql
    AS $$
begin
    return query
    select va.vehicle_id as entity_id,
           null::integer as entity_type_id,
           v.name as entity_name,
           va.attribute_id,
           va.is_active,
           va.value,
           va.unit,
           false as is_inherited,
           va.vehicle_id as source_entity_id,
           null::integer as source_entity_type_id
    from dbo.vehicle_attribute va
    join dbo.vehicle v on va.vehicle_id = v.vehicle_id
    where va.vehicle_id = p_vehicle_id

    union all

    select ea.entity_id,
           ea.entity_type_id,
           e.name as entity_name,
           ea.attribute_id,
           ea.is_active,
           ea.value,
           ea.unit,
           ea.entity_id != ea.source_entity_id as is_inherited,
           ea.source_entity_id,
           ea.source_entity_type_id
    from dbo.vehicle_part vp
    join dbo.entity e on vp.entity_id = e.id and vp.entity_type_id = e.entity_type_id
    join dbo.get_entity_attributes(vp.entity_id, vp.entity_type_id) ea on true
    where vp.vehicle_id = p_vehicle_id
    order by vehicle_part, is_inherited, entity_id;
end;
$$;


ALTER FUNCTION dbo.get_vehicle_attributes(p_vehicle_id uuid) OWNER TO braibau;

--
-- Name: get_vehicle_features(uuid); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_vehicle_features(p_vehicle_id uuid) RETURNS TABLE(entity_id uuid, entity_type_id integer, entity_name text, feature_id integer, is_optional boolean, is_active boolean, price real, currency text, is_inherited boolean, source_entity_id uuid, source_entity_type_id integer)
    LANGUAGE plpgsql
    AS $$
begin
    return query
    select vf.vehicle_id as entity_id,
           null::integer as entity_type_id,
           v.name as entity_name,
           vf.feature_id,
           vf.is_optional,
           vf.is_active,
           vf.price,
           vf.currency,
           false as is_inherited,
           vf.vehicle_id as source_entity_id,
           null::integer as source_entity_type_id
    from dbo.vehicle_feature vf
    join dbo.vehicle v on vf.vehicle_id = v.vehicle_id
    where vf.vehicle_id = p_vehicle_id

    union all

    select ef.entity_id,
           ef.entity_type_id,
           e.name as entity_name,
           ef.feature_id,
           ef.is_optional,
           ef.is_active,
           ef.price,
           ef.currency,
           ef.entity_id != ef.source_entity_id as is_inherited,
           ef.source_entity_id,
           ef.source_entity_type_id
    from dbo.vehicle_part vp
    join dbo.entity e on vp.entity_id = e.id and vp.entity_type_id = e.entity_type_id
    join dbo.get_entity_features(vp.entity_id, vp.entity_type_id) ef on true
    where vp.vehicle_id = p_vehicle_id
    order by vehicle_part, is_inherited, entity_id;
end;
$$;


ALTER FUNCTION dbo.get_vehicle_features(p_vehicle_id uuid) OWNER TO braibau;

--
-- Name: set_entity_attribute_value(dbo.entity_key, integer, text, text, boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.set_entity_attribute_value(p_key dbo.entity_key, p_attribute_id integer, p_value text, p_unit text, p_propagate_down boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_existing_attribute dbo.entity_attribute%ROWTYPE;
    v_attribute dbo.attribute%ROWTYPE;
BEGIN
    SELECT * INTO v_attribute
    FROM dbo.attribute
    WHERE id = p_attribute_id;

    IF NOT v_attribute.is_overridable THEN
        RAISE EXCEPTION 'Cannot override non-overridable attribute';
    END IF;

    SELECT * INTO v_existing_attribute
    FROM dbo.entity_attribute
    WHERE entity_key = p_key AND attribute_id = p_attribute_id;

    IF v_existing_attribute IS NOT NULL AND NOT v_existing_attribute.is_overridable THEN
        RAISE EXCEPTION 'Cannot override non-overridable attribute';
    END IF;

    INSERT INTO dbo.entity_attribute (entity_key, attribute_id, is_active, value, unit)
    VALUES (p_key, p_attribute_id, true, p_value, p_unit)
    ON CONFLICT (entity_key, attribute_id) DO UPDATE
    SET value = p_value, unit = p_unit;

    IF p_propagate_down THEN
        WITH RECURSIVE child_entities AS (
            SELECT key
            FROM dbo.entity
            WHERE parent_key = p_key
            UNION ALL
            SELECT e.key
            FROM dbo.entity e
            INNER JOIN child_entities ce ON e.parent_key = ce.key
        )
        INSERT INTO dbo.entity_attribute (entity_key, attribute_id, is_active, value, unit)
        SELECT ce.key, p_attribute_id, true, p_value, p_unit
        FROM child_entities ce
        ON CONFLICT (entity_key, attribute_id) DO UPDATE
        SET value = p_value, unit = p_unit;
    END IF;
END;
$$;


ALTER FUNCTION dbo.set_entity_attribute_value(p_key dbo.entity_key, p_attribute_id integer, p_value text, p_unit text, p_propagate_down boolean) OWNER TO braibau;

--
-- Name: set_entity_feature_value(dbo.entity_key, integer, real, text, boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.set_entity_feature_value(p_key dbo.entity_key, p_feature_id integer, p_price real, p_currency text, p_propagate_down boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_existing_feature dbo.entity_feature%ROWTYPE;
    v_feature dbo.feature%ROWTYPE;
BEGIN
    SELECT * INTO v_feature
    FROM dbo.feature
    WHERE id = p_feature_id;

    IF NOT v_feature.is_overridable THEN
        RAISE EXCEPTION 'Cannot override non-overridable feature';
    END IF;

    SELECT * INTO v_existing_feature
    FROM dbo.entity_feature
    WHERE entity_key = p_key AND feature_id = p_feature_id;

    IF v_existing_feature IS NOT NULL AND NOT v_existing_feature.is_overridable THEN
        RAISE EXCEPTION 'Cannot override non-overridable feature';
    END IF;

    INSERT INTO dbo.entity_feature (entity_key, feature_id, is_active, price, currency)
    VALUES (p_key, p_feature_id, true, p_price, p_currency)
    ON CONFLICT (entity_key, feature_id) DO UPDATE
    SET price = p_price, currency = p_currency;

    IF p_propagate_down THEN
        WITH RECURSIVE child_entities AS (
            SELECT key
            FROM dbo.entity
            WHERE parent_key = p_key
            UNION ALL
            SELECT e.key
            FROM dbo.entity e
            INNER JOIN child_entities ce ON e.parent_key = ce.key
        )
        INSERT INTO dbo.entity_feature (entity_key, feature_id, is_active, price, currency)
        SELECT ce.key, p_feature_id, true, p_price, p_currency
        FROM child_entities ce
        ON CONFLICT (entity_key, feature_id) DO UPDATE
        SET price = p_price, currency = p_currency;
    END IF;
END;
$$;


ALTER FUNCTION dbo.set_entity_feature_value(p_key dbo.entity_key, p_feature_id integer, p_price real, p_currency text, p_propagate_down boolean) OWNER TO braibau;

--
-- Name: set_vehicle_attribute_value(uuid, integer, text, text); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.set_vehicle_attribute_value(p_vehicle_id uuid, p_attribute_id integer, p_value text, p_unit text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    v_existing_attribute dbo.vehicle_attribute%rowtype;
    v_attribute dbo.attribute%rowtype;
begin
    select * into v_attribute
    from dbo.attribute
    where id = p_attribute_id;

    if not v_attribute.is_overridable then
        raise exception 'Cannot override non-overridable attribute';
    end if;

    select * into v_existing_attribute
    from dbo.vehicle_attribute
    where vehicle_id = p_vehicle_id and attribute_id = p_attribute_id;

    if v_existing_attribute is not null and not v_existing_attribute.is_overridable then
        raise exception 'Cannot override non-overridable attribute';
    end if;

    insert into dbo.vehicle_attribute (vehicle_id, attribute_id, is_active, value, unit)
    values (p_vehicle_id, p_attribute_id, true, p_value, p_unit)
    on conflict (vehicle_id, attribute_id) do update
    set value = p_value, unit = p_unit;
end;
$$;


ALTER FUNCTION dbo.set_vehicle_attribute_value(p_vehicle_id uuid, p_attribute_id integer, p_value text, p_unit text) OWNER TO braibau;

--
-- Name: set_vehicle_feature_value(uuid, integer, real, text); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.set_vehicle_feature_value(p_vehicle_id uuid, p_feature_id integer, p_price real, p_currency text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    v_existing_feature dbo.vehicle_feature%rowtype;
    v_feature dbo.feature%rowtype;
begin
    select * into v_feature
    from dbo.feature
    where id = p_feature_id;

    if not v_feature.is_overridable then
        raise exception 'Cannot override non-overridable feature';
    end if;

    select * into v_existing_feature
    from dbo.vehicle_feature
    where vehicle_id = p_vehicle_id and feature_id = p_feature_id;

    if v_existing_feature is not null and not v_existing_feature.is_overridable then
        raise exception 'Cannot override non-overridable feature';
    end if;

    insert into dbo.vehicle_feature (vehicle_id, feature_id, is_active, price, currency)
    values (p_vehicle_id, p_feature_id, true, p_price, p_currency)
    on conflict (vehicle_id, feature_id) do update
    set price = p_price, currency = p_currency;
end;
$$;


ALTER FUNCTION dbo.set_vehicle_feature_value(p_vehicle_id uuid, p_feature_id integer, p_price real, p_currency text) OWNER TO braibau;

--
-- Name: attribute; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.attribute (
    id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    default_unit text,
    is_inheritable boolean DEFAULT true NOT NULL,
    is_overridable boolean DEFAULT true NOT NULL,
    group_id integer NOT NULL,
    description text
);


ALTER TABLE dbo.attribute OWNER TO braibau;

--
-- Name: attribute_id_seq; Type: SEQUENCE; Schema: dbo; Owner: braibau
--

CREATE SEQUENCE dbo.attribute_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dbo.attribute_id_seq OWNER TO braibau;

--
-- Name: attribute_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: braibau
--

ALTER SEQUENCE dbo.attribute_id_seq OWNED BY dbo.attribute.id;


--
-- Name: entity_type; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.entity_type (
    id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    name text NOT NULL
);


ALTER TABLE dbo.entity_type OWNER TO braibau;

--
-- Name: feature; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.feature (
    id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    default_currency text,
    is_inheritable boolean DEFAULT true NOT NULL,
    is_overridable boolean DEFAULT true NOT NULL,
    group_id integer NOT NULL,
    description text
);


ALTER TABLE dbo.feature OWNER TO braibau;

--
-- Name: feature_id_seq; Type: SEQUENCE; Schema: dbo; Owner: braibau
--

CREATE SEQUENCE dbo.feature_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dbo.feature_id_seq OWNER TO braibau;

--
-- Name: feature_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: braibau
--

ALTER SEQUENCE dbo.feature_id_seq OWNED BY dbo.feature.id;


--
-- Name: group; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo."group" (
    id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    name text NOT NULL
);


ALTER TABLE dbo."group" OWNER TO braibau;

--
-- Name: group_id_seq; Type: SEQUENCE; Schema: dbo; Owner: braibau
--

CREATE SEQUENCE dbo.group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER SEQUENCE dbo.group_id_seq OWNER TO braibau;

--
-- Name: group_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: braibau
--

ALTER SEQUENCE dbo.group_id_seq OWNED BY dbo."group".id;


--
-- Name: related_entities; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.related_entities (
    entity1_key dbo.entity_key NOT NULL,
    entity2_key dbo.entity_key NOT NULL
);


ALTER TABLE dbo.related_entities OWNER TO braibau;

--
-- Name: vehicle; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.vehicle (
    vehicle_id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    description text
);


ALTER TABLE dbo.vehicle OWNER TO braibau;

--
-- Name: vehicle_attribute; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.vehicle_attribute (
    vehicle_id uuid NOT NULL,
    attribute_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    value text NOT NULL,
    unit text
);


ALTER TABLE dbo.vehicle_attribute OWNER TO braibau;

--
-- Name: vehicle_feature; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.vehicle_feature (
    vehicle_id uuid NOT NULL,
    feature_id integer NOT NULL,
    is_optional boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    price real NOT NULL,
    currency text
);


ALTER TABLE dbo.vehicle_feature OWNER TO braibau;

--
-- Name: vehicle_part; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.vehicle_part (
    vehicle_id uuid NOT NULL,
    entity_key dbo.entity_key NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE dbo.vehicle_part OWNER TO braibau;

--
-- Name: attribute id; Type: DEFAULT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.attribute ALTER COLUMN id SET DEFAULT nextval('dbo.attribute_id_seq'::regclass);


--
-- Name: feature id; Type: DEFAULT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.feature ALTER COLUMN id SET DEFAULT nextval('dbo.feature_id_seq'::regclass);


--
-- Name: group id; Type: DEFAULT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo."group" ALTER COLUMN id SET DEFAULT nextval('dbo.group_id_seq'::regclass);


--
-- Name: attribute attribute_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.attribute
    ADD CONSTRAINT attribute_pkey PRIMARY KEY (id);


--
-- Name: entity_attribute entity_attribute_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_attribute
    ADD CONSTRAINT entity_attribute_pkey PRIMARY KEY (entity_key, attribute_id);


--
-- Name: entity_feature entity_feature_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_feature
    ADD CONSTRAINT entity_feature_pkey PRIMARY KEY (entity_key, feature_id);


--
-- Name: entity entity_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (key);


--
-- Name: entity_type entity_type_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_type
    ADD CONSTRAINT entity_type_pkey PRIMARY KEY (id);


--
-- Name: feature feature_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.feature
    ADD CONSTRAINT feature_pkey PRIMARY KEY (id);


--
-- Name: group group_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo."group"
    ADD CONSTRAINT group_pkey PRIMARY KEY (id);


--
-- Name: related_entities related_entities_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.related_entities
    ADD CONSTRAINT related_entities_pkey PRIMARY KEY (entity1_key, entity2_key);


--
-- Name: attribute unique_attribute_name; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.attribute
    ADD CONSTRAINT unique_attribute_name UNIQUE (name);


--
-- Name: entity_type unique_entity_type_name; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_type
    ADD CONSTRAINT unique_entity_type_name UNIQUE (name);


--
-- Name: feature unique_feature_name; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.feature
    ADD CONSTRAINT unique_feature_name UNIQUE (name);


--
-- Name: vehicle_attribute vehicle_attribute_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_attribute
    ADD CONSTRAINT vehicle_attribute_pkey PRIMARY KEY (vehicle_id, attribute_id);


--
-- Name: vehicle_feature vehicle_feature_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_feature
    ADD CONSTRAINT vehicle_feature_pkey PRIMARY KEY (vehicle_id, feature_id);


--
-- Name: vehicle_part vehicle_part_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_part
    ADD CONSTRAINT vehicle_part_pkey PRIMARY KEY (vehicle_id, entity_key);


--
-- Name: vehicle vehicle_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle
    ADD CONSTRAINT vehicle_pkey PRIMARY KEY (vehicle_id);


--
-- Name: idx_attribute_group_id; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_attribute_group_id ON dbo.attribute USING btree (group_id);


--
-- Name: idx_entity_attribute_attribute_id; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_entity_attribute_attribute_id ON dbo.entity_attribute USING btree (attribute_id);


--
-- Name: idx_entity_attribute_entity_key; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_entity_attribute_entity_key ON dbo.entity_attribute USING btree (entity_key);


--
-- Name: idx_entity_feature_entity_key; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_entity_feature_entity_key ON dbo.entity_feature USING btree (entity_key);


--
-- Name: idx_entity_feature_feature_id; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_entity_feature_feature_id ON dbo.entity_feature USING btree (feature_id);


--
-- Name: idx_entity_parent_key; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_entity_parent_key ON dbo.entity USING btree (parent_key);


--
-- Name: idx_feature_group_id; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_feature_group_id ON dbo.feature USING btree (group_id);


--
-- Name: idx_related_entities_entity1_key; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_related_entities_entity1_key ON dbo.related_entities USING btree (entity1_key);


--
-- Name: idx_related_entities_entity2_key; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_related_entities_entity2_key ON dbo.related_entities USING btree (entity2_key);


--
-- Name: idx_vehicle_attribute_vehicle_id; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_vehicle_attribute_vehicle_id ON dbo.vehicle_attribute USING btree (vehicle_id);


--
-- Name: idx_vehicle_feature_feature_id; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_vehicle_feature_feature_id ON dbo.vehicle_feature USING btree (feature_id);


--
-- Name: idx_vehicle_feature_vehicle_id; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_vehicle_feature_vehicle_id ON dbo.vehicle_feature USING btree (vehicle_id);


--
-- Name: idx_vehicle_name; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_vehicle_name ON dbo.vehicle USING btree (name);


--
-- Name: idx_vehicle_part_entity_key; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_vehicle_part_entity_key ON dbo.vehicle_part USING btree (entity_key);


--
-- Name: idx_vehicle_part_vehicle_id; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_vehicle_part_vehicle_id ON dbo.vehicle_part USING btree (vehicle_id);


--
-- Name: vehicle_part check_unique_parts; Type: TRIGGER; Schema: dbo; Owner: braibau
--

CREATE TRIGGER check_unique_parts BEFORE INSERT ON dbo.vehicle_part FOR EACH ROW EXECUTE FUNCTION dbo.check_unique_vehicle_parts();


--
-- Name: entity unique_name_entity_type_trigger; Type: TRIGGER; Schema: dbo; Owner: braibau
--

CREATE TRIGGER unique_name_entity_type_trigger BEFORE INSERT OR UPDATE ON dbo.entity FOR EACH ROW EXECUTE FUNCTION dbo.check_unique_name_entity_type();


--
-- Name: entity_attribute attribute_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_attribute
    ADD CONSTRAINT attribute_fkey FOREIGN KEY (attribute_id) REFERENCES dbo.attribute(id);


--
-- Name: entity_feature entity_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_feature
    ADD CONSTRAINT entity_fkey FOREIGN KEY (entity_key) REFERENCES dbo.entity(key);


--
-- Name: entity_attribute entity_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_attribute
    ADD CONSTRAINT entity_fkey FOREIGN KEY (entity_key) REFERENCES dbo.entity(key);


--
-- Name: vehicle_part entity_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_part
    ADD CONSTRAINT entity_fkey FOREIGN KEY (entity_key) REFERENCES dbo.entity(key);


--
-- Name: entity_feature feature_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_feature
    ADD CONSTRAINT feature_fkey FOREIGN KEY (feature_id) REFERENCES dbo.feature(id);


--
-- Name: attribute fk_group; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.attribute
    ADD CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES dbo."group"(id);


--
-- Name: feature fk_group; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.feature
    ADD CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES dbo."group"(id);


--
-- Name: entity parent_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity
    ADD CONSTRAINT parent_fkey FOREIGN KEY (parent_key) REFERENCES dbo.entity(key);


--
-- Name: related_entities related_entities_entity1_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.related_entities
    ADD CONSTRAINT related_entities_entity1_fkey FOREIGN KEY (entity1_key) REFERENCES dbo.entity(key);


--
-- Name: related_entities related_entities_entity2_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.related_entities
    ADD CONSTRAINT related_entities_entity2_fkey FOREIGN KEY (entity2_key) REFERENCES dbo.entity(key);


--
-- Name: vehicle_attribute vehicle_attribute_attribute_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_attribute
    ADD CONSTRAINT vehicle_attribute_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES dbo.attribute(id);


--
-- Name: vehicle_attribute vehicle_attribute_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_attribute
    ADD CONSTRAINT vehicle_attribute_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicle(vehicle_id);


--
-- Name: vehicle_feature vehicle_feature_feature_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_feature
    ADD CONSTRAINT vehicle_feature_feature_id_fkey FOREIGN KEY (feature_id) REFERENCES dbo.feature(id);


--
-- Name: vehicle_feature vehicle_feature_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_feature
    ADD CONSTRAINT vehicle_feature_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicle(vehicle_id);


--
-- Name: vehicle_part vehicle_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_part
    ADD CONSTRAINT vehicle_fkey FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicle(vehicle_id);


--
-- PostgreSQL database dump complete
--

