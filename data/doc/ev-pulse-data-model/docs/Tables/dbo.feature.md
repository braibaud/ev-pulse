## dbo.feature Table Documentation

### Overview

The `dbo.feature` table defines various features that can be associated with entities in the EV database. These features represent optional or standard characteristics of entities, such as interior features, exterior features, or safety features. Each feature is linked to a feature group for better organization and management.

### Table Definition

```sql
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
```

### Columns

- **id**: A serial integer that serves as the unique identifier for the feature.
- **feature_group_id**: An integer that references the feature group to which the feature belongs.
- **is_active**: A boolean flag indicating whether the feature is active.
- **name**: The name of the feature (e.g., Leather Seats, Sunroof, Adaptive Cruise Control).
- **default_currency**: The default currency for the feature's price (e.g., USD, EUR).
- **is_inheritable**: A boolean flag indicating whether the feature can be inherited by child entities.
- **is_overridable**: A boolean flag indicating whether the feature's price can be overridden by child entities.

### Functional Usage

- **Feature Management**: The `dbo.feature` table allows for the definition and management of various features that describe optional or standard characteristics of entities.
- **Inheritance and Override**: Features can be inherited by child entities and overridden if necessary, providing flexibility in data management.
- **Grouping**: Features are grouped using the `feature_group_id` column, which references the `dbo.feature_group` table.

### Related Objects

- **dbo.feature_group**: Defines the groups to which features belong.
- **dbo.entity_feature**: Associates features with entities and stores their prices.

### Sample Usage

To insert a new feature, you can use the following SQL statement:

```sql
insert into dbo.feature (feature_group_id, name, default_currency, is_inheritable, is_overridable)
values (1, 'Leather Seats', 'USD', true, true);
```

To retrieve all active features in a specific group:

```sql
select * from dbo.feature where feature_group_id = 1 and is_active = true;
```

### Technical Details

- **Auto-Increment ID**: The `id` column is defined as a serial type, which automatically generates a unique identifier for each new feature.
- **Constraint Management**: The `id` column serves as the primary key, ensuring that each feature has a unique identifier. The `feature_group_id` column is a foreign key that references the `dbo.feature_group` table.

This table is essential for defining optional or standard characteristics of entities within the EV database, enabling detailed and structured data management.