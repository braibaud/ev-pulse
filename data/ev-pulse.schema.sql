create schema if not exists dbo;
create extension if not exists "pgcrypto";

create table if not exists dbo.attribute_group (
    id serial,
    is_active boolean not null default true,
    name text not null,
    primary key (id)
);

create table if not exists dbo.attribute (
    id serial,
    attribute_group_id integer,
    is_active boolean not null default true,
    name text not null,
    default_unit text,
    is_inheritable boolean not null default true,
    is_overridable boolean not null default true,
    primary key (id),
    foreign key (attribute_group_id) references dbo.attribute_group (id)
);

create table if not exists dbo.feature_group (
    id serial,
    is_active boolean not null default true,
    name text not null,
    primary key (id)
);

create table if not exists dbo.feature (
    id serial,
    feature_group_id integer not null,
    is_active boolean not null default true,
    name text not null,
    default_currency text,
    is_inheritable boolean not null default true,
    is_overridable boolean not null default true,
    primary key (id),
    foreign key (feature_group_id) references dbo.feature_group (id)
);

create table if not exists dbo.entity_type (
    id integer not null,
    is_active boolean not null default true,
    name text not null,
    primary key (id)
);

delete from dbo.entity_type;

insert into
    dbo.entity_type (id, name)
values
    (0, 'Brand'),
    (1, 'Model'),
    (2, 'Variant'),
    (3, 'Battery'),
    (4, 'Motor');

create or replace function dbo.get_entity_type_id(p_entity_type_name text)
returns integer as
$$
declare
    v_entity_type_id integer;
begin
    select id into v_entity_type_id
    from dbo.entity_type
    where name = p_entity_type_name;

    return v_entity_type_id;
end;
$$
language plpgsql;

create or replace function dbo.get_entity_type_name(p_entity_type_id integer)
returns text as
$$
declare
    v_entity_type_name text;
begin
    select name into v_entity_type_name
    from dbo.entity_type
    where id = p_entity_type_id;

    return v_entity_type_name;
end;
$$
language plpgsql;

create table if not exists dbo.entity (
    id uuid default gen_random_uuid(),
    entity_type_id integer not null,
    parent_id uuid null,
    parent_entity_type_id integer null,
    name text not null,
    is_virtual boolean not null default true,
    is_active boolean not null default true,
    primary key (id, entity_type_id),
    foreign key (parent_id, parent_entity_type_id) references dbo.entity(id, entity_type_id),
    foreign key (entity_type_id) references dbo.entity_type(id)
);

create index if not exists idx_entity_parent_id_parent_type on dbo.entity(parent_id, parent_entity_type_id);

create table if not exists dbo.entity_feature (
    entity_id uuid not null,
    entity_type_id integer not null,
    feature_id integer not null,
    is_optional boolean not null default true,
    is_active boolean not null default true,
    price real not null,
    currency text,
    primary key (entity_id, entity_type_id, feature_id),
    foreign key (entity_id, entity_type_id) references dbo.entity(id, entity_type_id),
    foreign key (feature_id) references dbo.feature(id)
);

create table if not exists dbo.entity_attribute (
    entity_id uuid not null,
    entity_type_id integer not null,
    attribute_id integer not null,
    is_active boolean not null default true,
    value text not null,
    unit text,
    primary key (entity_id, entity_type_id, attribute_id),
    foreign key (entity_id, entity_type_id) references dbo.entity(id, entity_type_id),
    foreign key (attribute_id) references dbo.attribute(id)
);

create table if not exists dbo.vehicle (
    vehicle_id uuid default gen_random_uuid(),
    variant_id uuid not null,
    variant_type_id integer not null,
    motor_id uuid not null,
    motor_type_id integer not null,
    battery_id uuid not null,
    battery_type_id integer not null,
    is_active boolean not null default true,
    primary key (vehicle_id),
    unique (variant_id, motor_id, battery_id),
    foreign key (variant_id, variant_type_id) references dbo.entity(id, entity_type_id),
    foreign key (motor_id, motor_type_id) references dbo.entity(id, entity_type_id),
    foreign key (battery_id, battery_type_id) references dbo.entity(id, entity_type_id)
);

create or replace function dbo.check_vehicle_type_ids()
returns trigger as
$$
begin
    if dbo.get_entity_type_name(new.variant_type_id) != 'Variant' then
        raise exception 'invalid variant_type_id, should be "Variant"';
    end if;

    if dbo.get_entity_type_name(new.motor_type_id) != 'Motor' then
        raise exception 'invalid motor_type_id, should be "Motor"';
    end if;

    if dbo.get_entity_type_name(new.battery_type_id) != 'Battery' then
        raise exception 'invalid battery_type_id, should be "Battery"';
    end if;

    return new;
end;
$$
language plpgsql;

create or replace trigger check_vehicle_type_ids
before insert on dbo.vehicle
for each row
execute function dbo.check_vehicle_type_ids();

create table if not exists dbo.vehicle_feature (
    vehicle_id uuid not null,
    feature_id integer not null,
    is_optional boolean not null default true,
    is_active boolean not null default true,
    price real not null,
    currency text,
    primary key (vehicle_id, feature_id),
    foreign key (vehicle_id) references dbo.vehicle(vehicle_id),
    foreign key (feature_id) references dbo.feature(id)
);

create table if not exists dbo.vehicle_attribute (
    vehicle_id uuid not null,
    attribute_id integer not null,
    is_active boolean not null default true,
    value text not null,
    unit text,
    primary key (vehicle_id, attribute_id),
    foreign key (vehicle_id) references dbo.vehicle(vehicle_id),
    foreign key (attribute_id) references dbo.attribute(id)
);

create table if not exists dbo.related_entities (
    entity1_id uuid not null,
    entity1_type_id integer not null,
    entity2_id uuid not null,
    entity2_type_id integer not null,
    primary key (entity1_id, entity1_type_id, entity2_id, entity2_type_id),
    foreign key (entity1_id, entity1_type_id) references dbo.entity(id, entity_type_id),
    foreign key (entity2_id, entity2_type_id) references dbo.entity(id, entity_type_id)
);

create or replace function dbo.get_nearest_parent(
    p_id uuid,
    p_entity_type_id integer,
    p_target_entity_type_id integer,
    p_max_depth integer default 10
) returns uuid as
$$
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
$$
language plpgsql;

create or replace function dbo.get_nearest_parent_entity(
    p_id uuid,
    p_entity_type_id integer,
    p_target_entity_type_id integer,
    p_max_depth integer default 10
)
returns dbo.entity as
$$
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
$$
language plpgsql;

delete from dbo.attribute_group;

insert into
    dbo.attribute_group (name)
values
    ('Performance'),
    ('Dimensions'),
    ('Weight'),
    ('Fuel Efficiency'),
    ('Electric Range'),
    ('Charging'),
    ('Materials'),
    ('Pricing'),
    ('Warranty'),
    ('Certifications'),
    ('Safety'),
    ('Manufacturing Details');

delete from dbo.feature_group;

insert into
    dbo.feature_group (name)
values
    ('Interior'),
    ('Exterior'),
    ('Technology'),
    ('Colors'),
    ('Safety'),
    ('Comfort'),
    ('Performance'),
    ('Connectivity'),
    ('Entertainment'),
    ('Efficiency');

create or replace function dbo.set_entity_attribute_value(
    p_entity_id uuid,
    p_entity_type_id integer,
    p_attribute_id integer,
    p_value text,
    p_unit text,
    p_propagate_down boolean default false
)
returns void as
$$
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
$$
language plpgsql;

create or replace function dbo.set_entity_feature_value(
    p_entity_id uuid,
    p_entity_type_id integer,
    p_feature_id integer,
    p_price real,
    p_currency text,
    p_propagate_down boolean default false
)
returns void as
$$
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
$$
language plpgsql;

create or replace function dbo.set_vehicle_attribute_value(
    p_vehicle_id uuid,
    p_attribute_id integer,
    p_value text,
    p_unit text
)
returns void as
$$
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
$$
language plpgsql;

create or replace function dbo.set_vehicle_feature_value(
    p_vehicle_id uuid,
    p_feature_id integer,
    p_price real,
    p_currency text
)
returns void as
$$
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
$$
language plpgsql;

create or replace function dbo.get_entity_features(
    p_id uuid,
    p_entity_type_id integer
)
returns table (
    entity_id uuid,
    entity_type_id integer,
    feature_id integer,
    is_optional boolean,
    is_active boolean,
    price real,
    currency text,
    is_inherited boolean,
    source_entity_id uuid,
    source_entity_type_id integer
) as
$$
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
$$
language plpgsql;

create or replace function dbo.get_entity_attributes(
    p_id uuid,
    p_entity_type_id integer
)
returns table (
    entity_id uuid,
    entity_type_id integer,
    attribute_id integer,
    is_active boolean,
    value text,
    unit text,
    is_inherited boolean,
    source_entity_id uuid,
    source_entity_type_id integer
) as
$$
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
$$
language plpgsql;

create or replace function dbo.get_vehicle_features(
    p_vehicle_id uuid
)
returns table (
    vehicle_part text,
    entity_id uuid,
    entity_type_id integer,
    feature_id integer,
    is_optional boolean,
    is_active boolean,
    price real,
    currency text,
    is_inherited boolean,
    source_entity_id uuid,
    source_entity_type_id integer
) as
$$
declare
    v_variant_id uuid;
    v_motor_id uuid;
    v_battery_id uuid;
begin
    select variant_id, motor_id, battery_id
    into v_variant_id, v_motor_id, v_battery_id
    from dbo.vehicle
    where vehicle_id = p_vehicle_id;

    return query
    select 'Variant' as vehicle_part, ef.*
    from dbo.get_entity_features(v_variant_id, dbo.get_entity_type_id('Variant')) ef
    union all
    select 'Motor' as vehicle_part, ef.*
    from dbo.get_entity_features(v_motor_id, dbo.get_entity_type_id('Motor')) ef
    union all
    select 'Battery' as vehicle_part, ef.*
    from dbo.get_entity_features(v_battery_id, dbo.get_entity_type_id('Battery')) ef
    order by vehicle_part, is_inherited, entity_id;
end;
$$
language plpgsql;

create or replace function dbo.get_vehicle_attributes(
    p_vehicle_id uuid
)
returns table (
    vehicle_part text,
    entity_id uuid,
    entity_type_id integer,
    attribute_id integer,
    is_active boolean,
    value text,
    unit text,
    is_inherited boolean,
    source_entity_id uuid,
    source_entity_type_id integer
) as
$$
declare
    v_variant_id uuid;
    v_motor_id uuid;
    v_battery_id uuid;
begin
    select variant_id, motor_id, battery_id
    into v_variant_id, v_motor_id, v_battery_id
    from dbo.vehicle
    where vehicle_id = p_vehicle_id;

    return query
    select 'Variant' as vehicle_part, ea.*
    from dbo.get_entity_attributes(v_variant_id, dbo.get_entity_type_id('Variant')) ea
    union all
    select 'Motor' as vehicle_part, ea.*
    from dbo.get_entity_attributes(v_motor_id, dbo.get_entity_type_id('Motor')) ea
    union all
    select 'Battery' as vehicle_part, ea.*
    from dbo.get_entity_attributes(v_battery_id, dbo.get_entity_type_id('Battery')) ea
    order by vehicle_part, is_inherited, entity_id;
end;
$$
language plpgsql;


create or replace function dbo.get_attribute_id(p_attribute_name text)
returns integer as
$$
declare
    v_attribute_id integer;
begin
    select id into v_attribute_id
    from dbo.attribute
    where name = p_attribute_name;

    return v_attribute_id;
end;
$$
language plpgsql;


create or replace function dbo.get_feature_id(p_feature_name text)
returns integer as
$$
declare
    v_feature_id integer;
begin
    select id into v_feature_id
    from dbo.feature
    where name = p_feature_name;

    return v_feature_id;
end;
$$
language plpgsql;