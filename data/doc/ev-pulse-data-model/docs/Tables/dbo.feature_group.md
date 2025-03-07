## dbo.feature_group Table Documentation

### Overview

The `dbo.feature_group` table is used to categorize features into logical groups within the EV database. This grouping helps in organizing and managing features that share common characteristics or purposes, such as interior features, exterior features, or safety features.

### Table Definition

```plsql
create table if not exists dbo.feature_group (
    id serial,
    is_active boolean not null default true,
    name text not null,
    primary key (id)
);
```

### Columns

- **id**: A serial integer that serves as the unique identifier for the feature group.
- **is_active**: A boolean flag indicating whether the feature group is active.
- **name**: The name of the feature group (e.g., Interior, Exterior, Safety).

### Functional Usage

- **Feature Organization**: The `dbo.feature_group` table allows for the logical grouping of features, making it easier to manage and query related features.
- **Activation Status**: The `is_active` column allows for the activation or deactivation of feature groups without deleting them from the database.

### Related Objects

- **dbo.feature**: References the `feature_group` table to define the group of each feature.

### Sample Usage

To insert a new feature group, you can use the following SQL statement:

```plsql
insert into dbo.feature_group (name)
values ('New Feature Group');
```

To retrieve all active feature groups:

```plsql
select * from dbo.feature_group where is_active = true;
```

### Technical Details

- **Auto-Increment ID**: The `id` column is defined as a serial type, which automatically generates a unique identifier for each new feature group.
- **Constraint Management**: The `id` column serves as the primary key, ensuring that each feature group has a unique identifier.

This table is crucial for organizing features into meaningful categories, enhancing data management and query efficiency within the EV database.