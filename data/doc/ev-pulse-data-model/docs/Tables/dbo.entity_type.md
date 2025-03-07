## dbo.entity_type Table Documentation

### Overview

The `dbo.entity_type` table defines the various types of entities that can be managed within the EV database. Each entity type is associated with a unique identifier and a name, allowing for the categorization of entities such as brands, models, variants, batteries, and motors.

### Table Definition

```plsql
create table if not exists dbo.entity_type (
    id integer not null,
    is_active boolean not null default true,
    name text not null,
    primary key (id)
);
```

### Columns

- **id**: An integer that serves as the unique identifier for the entity type.
- **is_active**: A boolean flag indicating whether the entity type is active.
- **name**: The name of the entity type (e.g., Brand, Model, Variant, Battery, Motor).

### Functional Usage

- **Entity Categorization**: The `dbo.entity_type` table is used to categorize entities in the `dbo.entity` table. Each entity is associated with an entity type, which defines its role within the database.
- **Activation Status**: The `is_active` column allows for the activation or deactivation of entity types without deleting them from the database.

### Related Objects

- **dbo.entity**: References the `entity_type` table to define the type of each entity.
- **dbo.get_entity_type_id(p_entity_type_name)**: A function that returns the ID of an entity type based on its name.
- **dbo.get_entity_type_name(p_entity_type_id)**: A function that returns the name of an entity type based on its ID.

### Sample Usage

To insert a new entity type, you can use the following SQL statement:

```plsql
insert into dbo.entity_type (id, name)
values (5, 'New Entity Type');
```

To retrieve the ID of an entity type by name:

```plsql
select dbo.get_entity_type_id('Variant');
```

### Technical Details

- **Predefined Entity Types**: The table is initialized with predefined entity types such as Brand, Model, Variant, Battery, and Motor.
- **Constraint Management**: The `id` column serves as the primary key, ensuring that each entity type has a unique identifier.

This table is essential for managing the different categories of entities within the EV database, enabling structured and organized data management.