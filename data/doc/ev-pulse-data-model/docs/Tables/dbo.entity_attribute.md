## dbo.entity_attribute Table Documentation

### Overview

The `dbo.entity_attribute` table stores the attributes associated with entities in the EV database. Each entry in this table represents a specific attribute value for a given entity, allowing for detailed characterization of entities such as variants, motors, and batteries.

### Table Definition

```sql
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
```

### Columns

- **entity_id**: A UUID that references the entity to which the attribute is associated.
- **entity_type_id**: An integer that specifies the type of the entity.
- **attribute_id**: An integer that references the attribute being defined for the entity.
- **is_active**: A boolean flag indicating whether the attribute value is active.
- **value**: The value of the attribute (e.g., "300 kW" for a power attribute).
- **unit**: The unit of measurement for the attribute value (e.g., "kW" for power).

### Functional Usage

- **Attribute Assignment**: The `dbo.entity_attribute` table allows for the assignment of specific attribute values to entities, enabling detailed descriptions of their characteristics.
- **Inheritance and Override**: Attributes can be inherited from parent entities and overridden if necessary, providing flexibility in data management.
- **Activation Status**: The `is_active` column allows for the activation or deactivation of attribute values without deleting them from the database.

### Related Objects

- **dbo.entity**: References the entities to which attributes are assigned.
- **dbo.attribute**: Defines the attributes that can be assigned to entities.
- **dbo.set_entity_attribute_value**: A function that sets or updates the value of an attribute for an entity.

### Sample Usage

To insert a new attribute value for an entity, you can use the following SQL statement:

```sql
insert into dbo.entity_attribute (entity_id, entity_type_id, attribute_id, is_active, value, unit)
values ('entity-uuid', 2, 1, true, '300', 'kW');
```

To retrieve all active attribute values for a specific entity:

```sql
select * from dbo.entity_attribute where entity_id = 'entity-uuid' and is_active = true;
```

### Technical Details

- **Composite Primary Key**: The combination of `entity_id`, `entity_type_id`, and `attribute_id` serves as the primary key, ensuring that each attribute value is unique for a given entity.
- **Foreign Keys**: The table includes foreign key constraints that reference the `dbo.entity` and `dbo.attribute` tables, ensuring referential integrity.

This table is essential for managing the detailed characteristics of entities within the EV database, enabling structured and organized data management.