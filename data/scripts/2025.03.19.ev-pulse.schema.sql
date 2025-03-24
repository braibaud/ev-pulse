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
-- Name: check_unique_parts(); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.check_unique_parts() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if exists (select 1 from dbo.vehicle_part where vehicle_id = new.vehicle_id and entity_id = new.entity_id and entity_type_id = new.entity_type_id) then
        raise exception 'Each part must be unique for a vehicle';
    end if;
    return new;
end;
$$;


ALTER FUNCTION dbo.check_unique_parts() OWNER TO braibau;

--
-- Name: check_vehicle_has_parts(); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.check_vehicle_has_parts() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if not exists (select 1 from dbo.vehicle_part where vehicle_id = new.vehicle_id) then
        raise exception 'A vehicle must have at least one part';
    end if;
    return new;
end;
$$;


ALTER FUNCTION dbo.check_vehicle_has_parts() OWNER TO braibau;

--
-- Name: create_attribute(text, text, text, boolean, boolean, boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.create_attribute(p_name text, p_attribute_group_name text, p_default_unit text, p_is_active boolean DEFAULT true, p_is_inheritable boolean DEFAULT true, p_is_overridable boolean DEFAULT true) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_attribute_id integer;
    v_attribute_group_id integer;
BEGIN
    -- Check if the attribute group exists, if not create it
    SELECT id INTO v_attribute_group_id
    FROM dbo.attribute_group
    WHERE lower(name) = lower(p_attribute_group_name);

    IF NOT FOUND THEN
        INSERT INTO dbo.attribute_group (name)
        VALUES (initcap(p_attribute_group_name))
        RETURNING id INTO v_attribute_group_id;
    END IF;

    -- Check for duplicate attribute name (case-insensitive)
    IF EXISTS (
        SELECT 1
        FROM dbo.attribute
        WHERE lower(name) = lower(p_name)
    ) THEN
        RAISE EXCEPTION 'Attribute name already exists: %', p_name;
    END IF;

    -- Insert new attribute
    INSERT INTO dbo.attribute (attribute_group_id, is_active, name, default_unit, is_inheritable, is_overridable)
    VALUES (v_attribute_group_id, p_is_active, initcap(p_name), p_default_unit, p_is_inheritable, p_is_overridable)
    RETURNING id INTO v_attribute_id;

    -- Return the created attribute id
    RETURN v_attribute_id;
END;
$$;


ALTER FUNCTION dbo.create_attribute(p_name text, p_attribute_group_name text, p_default_unit text, p_is_active boolean, p_is_inheritable boolean, p_is_overridable boolean) OWNER TO braibau;

--
-- Name: create_entity(text, text, dbo.entity_key, boolean, boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.create_entity(p_name text, p_entity_type_name text, p_parent_key dbo.entity_key, p_is_virtual boolean DEFAULT true, p_is_active boolean DEFAULT true) RETURNS dbo.entity_key
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_entity_type_id integer;
    v_parent_id uuid;
    v_parent_entity_type_id integer;
    v_new_entity_id uuid;
BEGIN
    -- Validate entity type name
    SELECT id INTO v_entity_type_id
    FROM dbo.entity_type
    WHERE name = p_entity_type_name;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid entity type name: %', p_entity_type_name;
    END IF;

    -- Validate parent key if provided
    IF p_parent_key IS NOT NULL THEN
        v_parent_id := p_parent_key.id;
        v_parent_entity_type_id := p_parent_key.entity_type_id;

        IF NOT EXISTS (SELECT 1 FROM dbo.entity WHERE id = v_parent_id AND entity_type_id = v_parent_entity_type_id) THEN
            RAISE EXCEPTION 'Invalid parent key';
        END IF;
    END IF;

    -- Check for duplicate creation
    IF EXISTS (
        SELECT 1
        FROM dbo.entity
        WHERE name = p_name
          AND entity_type_id = v_entity_type_id
          AND COALESCE(parent_id, '00000000-0000-0000-0000-000000000000'::uuid) = COALESCE(v_parent_id, '00000000-0000-0000-0000-000000000000'::uuid)
          AND COALESCE(parent_entity_type_id, -1) = COALESCE(v_parent_entity_type_id, -1)
    ) THEN
        RAISE EXCEPTION 'Duplicate entity creation detected';
    END IF;

    -- Insert new entity
    INSERT INTO dbo.entity (id, entity_type_id, parent_id, parent_entity_type_id, name, is_virtual, is_active)
    VALUES (gen_random_uuid(), v_entity_type_id, v_parent_id, v_parent_entity_type_id, p_name, p_is_virtual, p_is_active)
    RETURNING id INTO v_new_entity_id;

    -- Return the created entity_key
    RETURN (v_new_entity_id, v_entity_type_id)::dbo.entity_key;
END;
$$;


ALTER FUNCTION dbo.create_entity(p_name text, p_entity_type_name text, p_parent_key dbo.entity_key, p_is_virtual boolean, p_is_active boolean) OWNER TO braibau;

--
-- Name: create_feature(text, text, text, boolean, boolean, boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.create_feature(p_name text, p_feature_group_name text, p_default_currency text, p_is_active boolean DEFAULT true, p_is_inheritable boolean DEFAULT true, p_is_overridable boolean DEFAULT true) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_feature_id integer;
    v_feature_group_id integer;
BEGIN
    -- Check if the feature group exists, if not create it
    SELECT id INTO v_feature_group_id
    FROM dbo.feature_group
    WHERE lower(name) = lower(p_feature_group_name);

    IF NOT FOUND THEN
        INSERT INTO dbo.feature_group (name)
        VALUES (initcap(p_feature_group_name))
        RETURNING id INTO v_feature_group_id;
    END IF;

    -- Check for duplicate feature name (case-insensitive)
    IF EXISTS (
        SELECT 1
        FROM dbo.feature
        WHERE lower(name) = lower(p_name)
    ) THEN
        RAISE EXCEPTION 'Feature name already exists: %', p_name;
    END IF;

    -- Insert new feature
    INSERT INTO dbo.feature (feature_group_id, is_active, name, default_currency, is_inheritable, is_overridable)
    VALUES (v_feature_group_id, p_is_active, initcap(p_name), p_default_currency, p_is_inheritable, p_is_overridable)
    RETURNING id INTO v_feature_id;

    -- Return the created feature id
    RETURN v_feature_id;
END;
$$;


ALTER FUNCTION dbo.create_feature(p_name text, p_feature_group_name text, p_default_currency text, p_is_active boolean, p_is_inheritable boolean, p_is_overridable boolean) OWNER TO braibau;

--
-- Name: create_vehicule(text, dbo.entity_key[], boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.create_vehicule(p_name text, p_entities dbo.entity_key[], p_is_active boolean DEFAULT true) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_vehicle_id uuid;
    v_entity_id uuid;
    v_entity_type_id integer;
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
        v_entity_id := v_entity_key.id;
        v_entity_type_id := v_entity_key.entity_type_id;

        -- Validate entity existence
        IF NOT EXISTS (SELECT 1 FROM dbo.entity WHERE id = v_entity_id AND entity_type_id = v_entity_type_id) THEN
            RAISE EXCEPTION 'Invalid entity key: (%)', v_entity_key;
        END IF;

        -- Insert into vehicle_part
        INSERT INTO dbo.vehicle_part (vehicle_id, entity_id, entity_type_id, is_active)
        VALUES (v_vehicle_id, v_entity_id, v_entity_type_id, true);
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
    where name = p_attribute_name;

    return v_attribute_id;
end;
$$;


ALTER FUNCTION dbo.get_attribute_id(p_attribute_name text) OWNER TO braibau;

--
-- Name: get_entity_attributes(uuid, integer); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_entity_attributes(p_id uuid, p_entity_type_id integer) RETURNS TABLE(entity_id uuid, entity_type_id integer, attribute_id integer, is_active boolean, value text, unit text, is_inherited boolean, source_entity_id uuid, source_entity_type_id integer)
    LANGUAGE plpgsql
    AS $$
begin
    return query
    with recursive entity_hierarchy as (
        select id, entity_type_id, parent_id, parent_entity_type_id, id as source_entity_id, entity_type_id as source_entity_type_id
        from dbo.entity
        where id = p_id and entity_type_id = p_entity_type_id
        union all
        select e.id, e.entity_type_id, e.parent_id, e.parent_entity_type_id, eh.source_entity_id, eh.source_entity_type_id
        from dbo.entity e
        inner join entity_hierarchy eh on e.id = eh.parent_id and e.entity_type_id = eh.parent_entity_type_id
    )
    select ea.entity_id, ea.entity_type_id, ea.attribute_id, ea.is_active, ea.value, ea.unit,
           ea.entity_id != eh.id as is_inherited,
           eh.source_entity_id, eh.source_entity_type_id
    from dbo.entity_attribute ea
    inner join entity_hierarchy eh on ea.entity_id = eh.id and ea.entity_type_id = eh.entity_type_id
    inner join dbo.attribute a on ea.attribute_id = a.id
    where a.is_inheritable or ea.entity_id = p_id
    order by is_inherited, eh.id;
end;
$$;


ALTER FUNCTION dbo.get_entity_attributes(p_id uuid, p_entity_type_id integer) OWNER TO braibau;

--
-- Name: get_entity_features(uuid, integer); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_entity_features(p_id uuid, p_entity_type_id integer) RETURNS TABLE(entity_id uuid, entity_type_id integer, feature_id integer, is_optional boolean, is_active boolean, price real, currency text, is_inherited boolean, source_entity_id uuid, source_entity_type_id integer)
    LANGUAGE plpgsql
    AS $$
begin
    return query
    with recursive entity_hierarchy as (
        select id, entity_type_id, parent_id, parent_entity_type_id, id as source_entity_id, entity_type_id as source_entity_type_id
        from dbo.entity
        where id = p_id and entity_type_id = p_entity_type_id
        union all
        select e.id, e.entity_type_id, e.parent_id, e.parent_entity_type_id, eh.source_entity_id, eh.source_entity_type_id
        from dbo.entity e
        inner join entity_hierarchy eh on e.id = eh.parent_id and e.entity_type_id = eh.parent_entity_type_id
    )
    select ef.entity_id, ef.entity_type_id, ef.feature_id, ef.is_optional, ef.is_active, ef.price, ef.currency,
           ef.entity_id != eh.id as is_inherited,
           eh.source_entity_id, eh.source_entity_type_id
    from dbo.entity_feature ef
    inner join entity_hierarchy eh on ef.entity_id = eh.id and ef.entity_type_id = eh.entity_type_id
    inner join dbo.feature f on ef.feature_id = f.id
    where f.is_inheritable or ef.entity_id = p_id
    order by is_inherited, eh.id;
end;
$$;


ALTER FUNCTION dbo.get_entity_features(p_id uuid, p_entity_type_id integer) OWNER TO braibau;

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
    where name = p_entity_type_name;

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
    where name = p_feature_name;

    return v_feature_id;
end;
$$;


ALTER FUNCTION dbo.get_feature_id(p_feature_name text) OWNER TO braibau;

--
-- Name: get_nearest_parent(uuid, integer, integer, integer); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_nearest_parent(p_id uuid, p_entity_type_id integer, p_target_entity_type_id integer, p_max_depth integer DEFAULT 10) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
begin
    return (
        with recursive parent_hierarchy as (
            select id, entity_type_id, parent_id, parent_entity_type_id, 1 as depth
            from dbo.entity
            where id = p_id and entity_type_id = p_entity_type_id
            union all
            select e.id, e.entity_type_id, e.parent_id, e.parent_entity_type_id, ph.depth + 1
            from dbo.entity e
            inner join parent_hierarchy ph on e.id = ph.parent_id and e.entity_type_id = ph.parent_entity_type_id
            where ph.depth < p_max_depth
        )
        select parent_id
        from parent_hierarchy
        where parent_entity_type_id = p_target_entity_type_id
        order by depth, id
        limit 1
    );
end;
$$;


ALTER FUNCTION dbo.get_nearest_parent(p_id uuid, p_entity_type_id integer, p_target_entity_type_id integer, p_max_depth integer) OWNER TO braibau;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: entity; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.entity (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type_id integer NOT NULL,
    parent_id uuid,
    parent_entity_type_id integer,
    name text NOT NULL,
    is_virtual boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE dbo.entity OWNER TO braibau;

--
-- Name: get_nearest_parent_entity(uuid, integer, integer, integer); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.get_nearest_parent_entity(p_id uuid, p_entity_type_id integer, p_target_entity_type_id integer, p_max_depth integer DEFAULT 10) RETURNS dbo.entity
    LANGUAGE plpgsql
    AS $$
declare
    v_parent_id uuid;
    v_parent_entity dbo.entity%rowtype;
begin
    v_parent_id := dbo.get_nearest_parent(p_id, p_entity_type_id, p_target_entity_type_id, p_max_depth);

    if v_parent_id is not null then
        select * into v_parent_entity
        from dbo.entity
        where id = v_parent_id and entity_type_id = p_target_entity_type_id;

        return v_parent_entity;
    else
        return null;
    end if;
end;
$$;


ALTER FUNCTION dbo.get_nearest_parent_entity(p_id uuid, p_entity_type_id integer, p_target_entity_type_id integer, p_max_depth integer) OWNER TO braibau;

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
-- Name: set_entity_attribute_value(uuid, integer, integer, text, text, boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.set_entity_attribute_value(p_entity_id uuid, p_entity_type_id integer, p_attribute_id integer, p_value text, p_unit text, p_propagate_down boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    v_existing_attribute dbo.entity_attribute%rowtype;
    v_attribute dbo.attribute%rowtype;
begin
    select * into v_attribute
    from dbo.attribute
    where id = p_attribute_id;

    if not v_attribute.is_overridable then
        raise exception 'Cannot override non-overridable attribute';
    end if;

    select * into v_existing_attribute
    from dbo.entity_attribute
    where entity_id = p_entity_id and entity_type_id = p_entity_type_id and attribute_id = p_attribute_id;

    if v_existing_attribute is not null and not v_existing_attribute.is_overridable then
        raise exception 'Cannot override non-overridable attribute';
    end if;

    insert into dbo.entity_attribute (entity_id, entity_type_id, attribute_id, is_active, value, unit)
    values (p_entity_id, p_entity_type_id, p_attribute_id, true, p_value, p_unit)
    on conflict (entity_id, entity_type_id, attribute_id) do update
    set value = p_value, unit = p_unit;

    if p_propagate_down then
        with recursive child_entities as (
            select id, entity_type_id
            from dbo.entity
            where parent_id = p_entity_id and parent_entity_type_id = p_entity_type_id
            union all
            select e.id, e.entity_type_id
            from dbo.entity e
            inner join child_entities ce on e.parent_id = ce.id and e.parent_entity_type_id = ce.entity_type_id
        )
        insert into dbo.entity_attribute (entity_id, entity_type_id, attribute_id, is_active, value, unit)
        select ce.id, ce.entity_type_id, p_attribute_id, true, p_value, p_unit
        from child_entities ce
        on conflict (entity_id, entity_type_id, attribute_id) do update
        set value = p_value, unit = p_unit;
    end if;
end;
$$;


ALTER FUNCTION dbo.set_entity_attribute_value(p_entity_id uuid, p_entity_type_id integer, p_attribute_id integer, p_value text, p_unit text, p_propagate_down boolean) OWNER TO braibau;

--
-- Name: set_entity_feature_value(uuid, integer, integer, real, text, boolean); Type: FUNCTION; Schema: dbo; Owner: braibau
--

CREATE FUNCTION dbo.set_entity_feature_value(p_entity_id uuid, p_entity_type_id integer, p_feature_id integer, p_price real, p_currency text, p_propagate_down boolean DEFAULT false) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
    v_existing_feature dbo.entity_feature%rowtype;
    v_feature dbo.feature%rowtype;
begin
    select * into v_feature
    from dbo.feature
    where id = p_feature_id;

    if not v_feature.is_overridable then
        raise exception 'Cannot override non-overridable feature';
    end if;

    select * into v_existing_feature
    from dbo.entity_feature
    where entity_id = p_entity_id and entity_type_id = p_entity_type_id and feature_id = p_feature_id;

    if v_existing_feature is not null and not v_existing_feature.is_overridable then
        raise exception 'Cannot override non-overridable feature';
    end if;

    insert into dbo.entity_feature (entity_id, entity_type_id, feature_id, is_active, price, currency)
    values (p_entity_id, p_entity_type_id, p_feature_id, true, p_price, p_currency)
    on conflict (entity_id, entity_type_id, feature_id) do update
    set price = p_price, currency = p_currency;

    if p_propagate_down then
        with recursive child_entities as (
            select id, entity_type_id
            from dbo.entity
            where parent_id = p_entity_id and parent_entity_type_id = p_entity_type_id
            union all
            select e.id, e.entity_type_id
            from dbo.entity e
            inner join child_entities ce on e.parent_id = ce.id and e.parent_entity_type_id = ce.entity_type_id
        )
        insert into dbo.entity_feature (entity_id, entity_type_id, feature_id, is_active, price, currency)
        select ce.id, ce.entity_type_id, p_feature_id, true, p_price, p_currency
        from child_entities ce
        on conflict (entity_id, entity_type_id, feature_id) do update
        set price = p_price, currency = p_currency;
    end if;
end;
$$;


ALTER FUNCTION dbo.set_entity_feature_value(p_entity_id uuid, p_entity_type_id integer, p_feature_id integer, p_price real, p_currency text, p_propagate_down boolean) OWNER TO braibau;

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
    attribute_group_id integer,
    is_active boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    default_unit text,
    is_inheritable boolean DEFAULT true NOT NULL,
    is_overridable boolean DEFAULT true NOT NULL
);


ALTER TABLE dbo.attribute OWNER TO braibau;

--
-- Name: attribute_group; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.attribute_group (
    id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    name text NOT NULL
);


ALTER TABLE dbo.attribute_group OWNER TO braibau;

--
-- Name: attribute_group_id_seq; Type: SEQUENCE; Schema: dbo; Owner: braibau
--

CREATE SEQUENCE dbo.attribute_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dbo.attribute_group_id_seq OWNER TO braibau;

--
-- Name: attribute_group_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: braibau
--

ALTER SEQUENCE dbo.attribute_group_id_seq OWNED BY dbo.attribute_group.id;


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
-- Name: entity_attribute; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.entity_attribute (
    entity_id uuid NOT NULL,
    entity_type_id integer NOT NULL,
    attribute_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    value text NOT NULL,
    unit text
);


ALTER TABLE dbo.entity_attribute OWNER TO braibau;

--
-- Name: entity_feature; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.entity_feature (
    entity_id uuid NOT NULL,
    entity_type_id integer NOT NULL,
    feature_id integer NOT NULL,
    is_optional boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    price real NOT NULL,
    currency text
);


ALTER TABLE dbo.entity_feature OWNER TO braibau;

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
    feature_group_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    name text NOT NULL,
    default_currency text,
    is_inheritable boolean DEFAULT true NOT NULL,
    is_overridable boolean DEFAULT true NOT NULL
);


ALTER TABLE dbo.feature OWNER TO braibau;

--
-- Name: feature_group; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.feature_group (
    id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    name text NOT NULL
);


ALTER TABLE dbo.feature_group OWNER TO braibau;

--
-- Name: feature_group_id_seq; Type: SEQUENCE; Schema: dbo; Owner: braibau
--

CREATE SEQUENCE dbo.feature_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE dbo.feature_group_id_seq OWNER TO braibau;

--
-- Name: feature_group_id_seq; Type: SEQUENCE OWNED BY; Schema: dbo; Owner: braibau
--

ALTER SEQUENCE dbo.feature_group_id_seq OWNED BY dbo.feature_group.id;


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
-- Name: related_entities; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.related_entities (
    entity1_id uuid NOT NULL,
    entity1_type_id integer NOT NULL,
    entity2_id uuid NOT NULL,
    entity2_type_id integer NOT NULL
);


ALTER TABLE dbo.related_entities OWNER TO braibau;

--
-- Name: vehicle; Type: TABLE; Schema: dbo; Owner: braibau
--

CREATE TABLE dbo.vehicle (
    vehicle_id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    is_active boolean DEFAULT true NOT NULL
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
    entity_id uuid NOT NULL,
    entity_type_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE dbo.vehicle_part OWNER TO braibau;

--
-- Name: attribute id; Type: DEFAULT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.attribute ALTER COLUMN id SET DEFAULT nextval('dbo.attribute_id_seq'::regclass);


--
-- Name: attribute_group id; Type: DEFAULT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.attribute_group ALTER COLUMN id SET DEFAULT nextval('dbo.attribute_group_id_seq'::regclass);


--
-- Name: feature id; Type: DEFAULT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.feature ALTER COLUMN id SET DEFAULT nextval('dbo.feature_id_seq'::regclass);


--
-- Name: feature_group id; Type: DEFAULT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.feature_group ALTER COLUMN id SET DEFAULT nextval('dbo.feature_group_id_seq'::regclass);


--
-- Data for Name: attribute; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.attribute (id, attribute_group_id, is_active, name, default_unit, is_inheritable, is_overridable) FROM stdin;
\.


--
-- Data for Name: attribute_group; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.attribute_group (id, is_active, name) FROM stdin;
1	t	Performance
2	t	Dimensions
3	t	Weight
4	t	Fuel Efficiency
5	t	Electric Range
6	t	Charging
7	t	Materials
8	t	Pricing
9	t	Warranty
10	t	Certifications
11	t	Safety
12	t	Manufacturing Details
\.


--
-- Data for Name: entity; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.entity (id, entity_type_id, parent_id, parent_entity_type_id, name, is_virtual, is_active) FROM stdin;
\.


--
-- Data for Name: entity_attribute; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.entity_attribute (entity_id, entity_type_id, attribute_id, is_active, value, unit) FROM stdin;
\.


--
-- Data for Name: entity_feature; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.entity_feature (entity_id, entity_type_id, feature_id, is_optional, is_active, price, currency) FROM stdin;
\.


--
-- Data for Name: entity_type; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.entity_type (id, is_active, name) FROM stdin;
0	t	Brand
1	t	Model
2	t	Variant
3	t	Battery
4	t	Motor
5	t	Option Pack
\.


--
-- Data for Name: feature; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.feature (id, feature_group_id, is_active, name, default_currency, is_inheritable, is_overridable) FROM stdin;
\.


--
-- Data for Name: feature_group; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.feature_group (id, is_active, name) FROM stdin;
1	t	Interior
2	t	Exterior
3	t	Technology
4	t	Colors
5	t	Safety
6	t	Comfort
7	t	Performance
8	t	Connectivity
9	t	Entertainment
10	t	Efficiency
\.


--
-- Data for Name: related_entities; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.related_entities (entity1_id, entity1_type_id, entity2_id, entity2_type_id) FROM stdin;
\.


--
-- Data for Name: vehicle; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.vehicle (vehicle_id, name, is_active) FROM stdin;
\.


--
-- Data for Name: vehicle_attribute; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.vehicle_attribute (vehicle_id, attribute_id, is_active, value, unit) FROM stdin;
\.


--
-- Data for Name: vehicle_feature; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.vehicle_feature (vehicle_id, feature_id, is_optional, is_active, price, currency) FROM stdin;
\.


--
-- Data for Name: vehicle_part; Type: TABLE DATA; Schema: dbo; Owner: braibau
--

COPY dbo.vehicle_part (vehicle_id, entity_id, entity_type_id, is_active) FROM stdin;
\.


--
-- Name: attribute_group_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: braibau
--

SELECT pg_catalog.setval('dbo.attribute_group_id_seq', 12, true);


--
-- Name: attribute_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: braibau
--

SELECT pg_catalog.setval('dbo.attribute_id_seq', 1, false);


--
-- Name: feature_group_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: braibau
--

SELECT pg_catalog.setval('dbo.feature_group_id_seq', 10, true);


--
-- Name: feature_id_seq; Type: SEQUENCE SET; Schema: dbo; Owner: braibau
--

SELECT pg_catalog.setval('dbo.feature_id_seq', 1, false);


--
-- Name: attribute_group attribute_group_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.attribute_group
    ADD CONSTRAINT attribute_group_pkey PRIMARY KEY (id);


--
-- Name: attribute attribute_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.attribute
    ADD CONSTRAINT attribute_pkey PRIMARY KEY (id);


--
-- Name: entity_attribute entity_attribute_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_attribute
    ADD CONSTRAINT entity_attribute_pkey PRIMARY KEY (entity_id, entity_type_id, attribute_id);


--
-- Name: entity_feature entity_feature_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_feature
    ADD CONSTRAINT entity_feature_pkey PRIMARY KEY (entity_id, entity_type_id, feature_id);


--
-- Name: entity entity_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity
    ADD CONSTRAINT entity_pkey PRIMARY KEY (id, entity_type_id);


--
-- Name: entity_type entity_type_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_type
    ADD CONSTRAINT entity_type_pkey PRIMARY KEY (id);


--
-- Name: feature_group feature_group_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.feature_group
    ADD CONSTRAINT feature_group_pkey PRIMARY KEY (id);


--
-- Name: feature feature_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.feature
    ADD CONSTRAINT feature_pkey PRIMARY KEY (id);


--
-- Name: related_entities related_entities_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.related_entities
    ADD CONSTRAINT related_entities_pkey PRIMARY KEY (entity1_id, entity1_type_id, entity2_id, entity2_type_id);


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
    ADD CONSTRAINT vehicle_part_pkey PRIMARY KEY (vehicle_id, entity_id, entity_type_id);


--
-- Name: vehicle vehicle_pkey; Type: CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle
    ADD CONSTRAINT vehicle_pkey PRIMARY KEY (vehicle_id);


--
-- Name: idx_entity_parent_id_parent_type; Type: INDEX; Schema: dbo; Owner: braibau
--

CREATE INDEX idx_entity_parent_id_parent_type ON dbo.entity USING btree (parent_id, parent_entity_type_id);


--
-- Name: vehicle_part check_unique_parts; Type: TRIGGER; Schema: dbo; Owner: braibau
--

CREATE TRIGGER check_unique_parts BEFORE INSERT ON dbo.vehicle_part FOR EACH ROW EXECUTE FUNCTION dbo.check_unique_parts();


--
-- Name: vehicle check_vehicle_has_parts; Type: TRIGGER; Schema: dbo; Owner: braibau
--

CREATE TRIGGER check_vehicle_has_parts AFTER INSERT ON dbo.vehicle FOR EACH ROW EXECUTE FUNCTION dbo.check_vehicle_has_parts();


--
-- Name: attribute attribute_attribute_group_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.attribute
    ADD CONSTRAINT attribute_attribute_group_id_fkey FOREIGN KEY (attribute_group_id) REFERENCES dbo.attribute_group(id);


--
-- Name: entity_attribute entity_attribute_attribute_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_attribute
    ADD CONSTRAINT entity_attribute_attribute_id_fkey FOREIGN KEY (attribute_id) REFERENCES dbo.attribute(id);


--
-- Name: entity_attribute entity_attribute_entity_id_entity_type_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_attribute
    ADD CONSTRAINT entity_attribute_entity_id_entity_type_id_fkey FOREIGN KEY (entity_id, entity_type_id) REFERENCES dbo.entity(id, entity_type_id);


--
-- Name: entity entity_entity_type_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity
    ADD CONSTRAINT entity_entity_type_id_fkey FOREIGN KEY (entity_type_id) REFERENCES dbo.entity_type(id);


--
-- Name: entity_feature entity_feature_entity_id_entity_type_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_feature
    ADD CONSTRAINT entity_feature_entity_id_entity_type_id_fkey FOREIGN KEY (entity_id, entity_type_id) REFERENCES dbo.entity(id, entity_type_id);


--
-- Name: entity_feature entity_feature_feature_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity_feature
    ADD CONSTRAINT entity_feature_feature_id_fkey FOREIGN KEY (feature_id) REFERENCES dbo.feature(id);


--
-- Name: entity entity_parent_id_parent_entity_type_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.entity
    ADD CONSTRAINT entity_parent_id_parent_entity_type_id_fkey FOREIGN KEY (parent_id, parent_entity_type_id) REFERENCES dbo.entity(id, entity_type_id);


--
-- Name: feature feature_feature_group_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.feature
    ADD CONSTRAINT feature_feature_group_id_fkey FOREIGN KEY (feature_group_id) REFERENCES dbo.feature_group(id);


--
-- Name: related_entities related_entities_entity1_id_entity1_type_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.related_entities
    ADD CONSTRAINT related_entities_entity1_id_entity1_type_id_fkey FOREIGN KEY (entity1_id, entity1_type_id) REFERENCES dbo.entity(id, entity_type_id);


--
-- Name: related_entities related_entities_entity2_id_entity2_type_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.related_entities
    ADD CONSTRAINT related_entities_entity2_id_entity2_type_id_fkey FOREIGN KEY (entity2_id, entity2_type_id) REFERENCES dbo.entity(id, entity_type_id);


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
-- Name: vehicle_part vehicle_part_entity_id_entity_type_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_part
    ADD CONSTRAINT vehicle_part_entity_id_entity_type_id_fkey FOREIGN KEY (entity_id, entity_type_id) REFERENCES dbo.entity(id, entity_type_id);


--
-- Name: vehicle_part vehicle_part_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: dbo; Owner: braibau
--

ALTER TABLE ONLY dbo.vehicle_part
    ADD CONSTRAINT vehicle_part_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES dbo.vehicle(vehicle_id);


--
-- PostgreSQL database dump complete
--

