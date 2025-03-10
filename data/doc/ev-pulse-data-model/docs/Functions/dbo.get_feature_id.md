## dbo.get_feature_id Function Documentation

### Overview

The `dbo.get_feature_id` function retrieves the unique identifier (ID) of a feature based on its name. This function is essential for mapping feature names to their corresponding IDs, which are used throughout the database to reference features.

### Function Definition

```sql
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
```

### Parameters

- **p_feature_name**: The name of the feature for which to retrieve the ID.

### Returns

- An integer representing the ID of the feature.

### Functional Usage

- **Feature ID Retrieval**: This function is used to obtain the ID of a feature by providing its name. This is particularly useful when you need to reference features by their IDs in other database operations or functions.

### Related Objects

- **dbo.feature**: The table defining features and their properties, including the name and ID.

### Sample Usage

To retrieve the ID of a feature named 'Sunroof':

```sql
select dbo.get_feature_id('Sunroof');
```

### Technical Details

- **Single Responsibility**: The function has a single responsibility, which is to map feature names to their IDs. This makes it straightforward and efficient for lookups.
- **Error Handling**: The function assumes that the feature name exists in the `dbo.feature` table. Additional error handling can be implemented to manage cases where the feature name does not exist.

This function is a fundamental utility for working with features in the database, enabling easy lookup of feature IDs based on their names.