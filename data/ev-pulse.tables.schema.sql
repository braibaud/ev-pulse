-- Drop triggers if they exist
drop trigger if exists check_vehicle_has_parts on dbo.vehicle;
drop trigger if exists check_unique_parts on dbo.vehicle_part;

-- Drop tables in the reverse order of their dependencies
drop table if exists dbo.vehicle_attribute cascade;
drop table if exists dbo.vehicle_feature cascade;
drop table if exists dbo.vehicle_part cascade;
drop table if exists dbo.vehicle cascade;
drop table if exists dbo.related_entities cascade;
drop table if exists dbo.entity_attribute cascade;
drop table if exists dbo.entity_feature cascade;
drop table if exists dbo.entity cascade;
drop table if exists dbo.feature cascade;
drop table if exists dbo.attribute cascade;
drop table if exists dbo.feature_group cascade;
drop table if exists dbo.attribute_group cascade;
drop table if exists dbo.entity_type cascade;

-- Recreate tables
create table if not exists dbo.entity_type (
    id integer not null,
    is_active boolean not null default true,
    name text not null,
    primary key (id)
);

create table if not exists dbo.attribute_group (
    id serial,
    is_active boolean not null default true,
    name text not null,
    primary key (id)
);

create table if not exists dbo.feature_group (
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
    name text not null,
    is_active boolean not null default true,
    primary key (vehicle_id)
);

create table if not exists dbo.vehicle_part (
    vehicle_id uuid not null,
    entity_id uuid not null,
    entity_type_id integer not null,
    part_type text not null,
    is_active boolean not null default true,
    primary key (vehicle_id, entity_id, entity_type_id),
    foreign key (vehicle_id) references dbo.vehicle(vehicle_id),
    foreign key (entity_id, entity_type_id) references dbo.entity(id, entity_type_id)
);

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

-- Recreate triggers
create or replace function dbo.check_vehicle_has_parts()
returns trigger as
$$
begin
    if not exists (select 1 from dbo.vehicle_part where vehicle_id = new.vehicle_id) then
        raise exception 'A vehicle must have at least one part';
    end if;
    return new;
end;
$$
language plpgsql;

create trigger check_vehicle_has_parts
after insert on dbo.vehicle
for each row
execute function dbo.check_vehicle_has_parts();

create or replace function dbo.check_unique_parts()
returns trigger as
$$
begin
    if exists (select 1 from dbo.vehicle_part where vehicle_id = new.vehicle_id and entity_id = new.entity_id and entity_type_id = new.entity_type_id) then
        raise exception 'Each part must be unique for a vehicle';
    end if;
    return new;
end;
$$
language plpgsql;

create trigger check_unique_parts
before insert on dbo.vehicle_part
for each row
execute function dbo.check_unique_parts();
