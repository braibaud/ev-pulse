## dbo.attribute_group Table Documentation

### Overview

The `dbo.attribute_group` table is used to categorize attributes into logical groups within the EV database. This grouping helps in organizing and managing attributes that share common characteristics or purposes, such as performance, dimensions, or safety.

### Table Definition

```sql
create table if not exists dbo.attribute_group (
    id serial,
    is_active boolean not null default true,
    name text not null,
    primary key (id)
);
```

### Columns

- **id**: A serial integer that serves as the unique identifier for the attribute group.
- **is_active**: A boolean flag indicating whether the attribute group is active.
- **name**: The name of the attribute group (e.g., Performance, Dimensions, Safety).

### Functional Usage

- **Attribute Organization**: The `dbo.attribute_group` table allows for the logical grouping of attributes, making it easier to manage and query related attributes.
- **Activation Status**: The `is_active` column allows for the activation or deactivation of attribute groups without deleting them from the database.

### Related Objects

- **dbo.attribute**: References the `attribute_group` table to define the group of each attribute.

### Sample Usage

To insert a new attribute group, you can use the following SQL statement:

```sql
insert into dbo.attribute_group (name)
values ('New Attribute Group');
```

To retrieve all active attribute groups:

```sql
select * from dbo.attribute_group where is_active = true;
```

### Technical Details

- **Auto-Increment ID**: The `id` column is defined as a serial type, which automatically generates a unique identifier for each new attribute group.
- **Constraint Management**: The `id` column serves as the primary key, ensuring that each attribute group has a unique identifier.

This table is crucial for organizing attributes into meaningful categories, enhancing data management and query efficiency within the EV database.