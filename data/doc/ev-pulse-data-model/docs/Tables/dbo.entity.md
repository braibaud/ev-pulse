## dbo.entity Table Documentation

### Overview

The `dbo.entity` table is a central component of the EV database, representing various types of entities such as brands, models, variants, batteries, and motors. Each entity can inherit attributes and features from a parent entity, allowing for efficient data management and reduced redundancy.

### Table Definition

```sql
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
```

### Columns

- **id**: A unique identifier for the entity, generated using `gen_random_uuid()`.
- **entity_type_id**: An integer that specifies the type of the entity (e.g., Brand, Model, Variant, Battery, Motor).
- **parent_id**: A UUID that references the parent entity, allowing for hierarchical relationships.
- **parent_entity_type_id**: An integer that specifies the type of the parent entity.
- **name**: The name of the entity.
- **is_virtual**: A boolean flag indicating whether the entity is virtual.
- **is_active**: A boolean flag indicating whether the entity is active.

### Functional Usage

- **Entity Hierarchy**: The `parent_id` and `parent_entity_type_id` columns enable the creation of a hierarchical structure, where entities can inherit attributes and features from their parent entities.
- **Entity Types**: The `entity_type_id` column links to the `dbo.entity_type` table, which defines the types of entities (e.g., Brand, Model, Variant).

### Related Objects

- **dbo.entity_type**: Defines the types of entities.
- **dbo.entity_attribute**: Stores attributes associated with entities.
- **dbo.entity_feature**: Stores features associated with entities.
- **dbo.vehicle**: References entities for variants, motors, and batteries.

### Sample Usage

To insert a new entity, you can use the following SQL statement:

```sql
insert into dbo.entity (entity_type_id, parent_id, parent_entity_type_id, name, is_virtual, is_active)
values (2, 'parent-uuid', 1, 'Variant Name', true, true);
```

### Technical Details

- **Index**: An index `idx_entity_parent_id_parent_type` is created on the `parent_id` and `parent_entity_type_id` columns to optimize queries involving parent-child relationships.
- **Inheritance**: Attributes and features can be inherited from parent entities, reducing the need for duplicate data entry.

This table is crucial for managing the hierarchical relationships and inheritance of attributes and features among different entities in the EV database.