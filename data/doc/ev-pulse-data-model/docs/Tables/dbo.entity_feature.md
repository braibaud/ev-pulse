## dbo.entity_feature Table Documentation

### Overview

The `dbo.entity_feature` table stores the features associated with entities in the EV database. Each entry in this table represents a specific feature and its price for a given entity, allowing for the detailed characterization of optional or standard features of entities such as variants, motors, and batteries.

### Table Definition

```sql
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
```

### Columns

- **entity_id**: A UUID that references the entity to which the feature is associated.
- **entity_type_id**: An integer that specifies the type of the entity.
- **feature_id**: An integer that references the feature being defined for the entity.
- **is_optional**: A boolean flag indicating whether the feature is optional for the entity.
- **is_active**: A boolean flag indicating whether the feature is active.
- **price**: The price of the feature.
- **currency**: The currency in which the price is specified (e.g., USD, EUR).

### Functional Usage

- **Feature Assignment**: The `dbo.entity_feature` table allows for the assignment of specific features and their prices to entities, enabling detailed descriptions of their optional or standard characteristics.
- **Inheritance and Override**: Features can be inherited from parent entities and overridden if necessary, providing flexibility in data management.
- **Activation Status**: The `is_active` column allows for the activation or deactivation of features without deleting them from the database.

### Related Objects

- **dbo.entity**: References the entities to which features are assigned.
- **dbo.feature**: Defines the features that can be assigned to entities.
- **dbo.set_entity_feature_value**: A function that sets or updates the price of a feature for an entity.

### Sample Usage

To insert a new feature and its price for an entity, you can use the following SQL statement:

```sql
insert into dbo.entity_feature (entity_id, entity_type_id, feature_id, is_optional, is_active, price, currency)
values ('entity-uuid', 2, 1, true, true, 1500.00, 'USD');
```

To retrieve all active features for a specific entity:

```sql
select * from dbo.entity_feature where entity_id = 'entity-uuid' and is_active = true;
```

### Technical Details

- **Composite Primary Key**: The combination of `entity_id`, `entity_type_id`, and `feature_id` serves as the primary key, ensuring that each feature is unique for a given entity.
- **Foreign Keys**: The table includes foreign key constraints that reference the `dbo.entity` and `dbo.feature` tables, ensuring referential integrity.

This table is essential for managing the optional or standard features of entities within the EV database, enabling structured and organized data management.