## dbo.get_entity_type_name Function Documentation

### Overview

The `dbo.get_entity_type_name` function retrieves the name of an entity type based on its ID. This function is useful for converting entity type IDs into their corresponding human-readable names, which can be used for display purposes or in queries that require entity type names.

### Function Definition

```sql
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
```

### Parameters

- **p_entity_type_id**: An integer parameter that specifies the ID of the entity type.

### Return Value

- Returns a text string representing the name of the entity type.

### Functional Usage

- **Entity Type Lookup**: This function is used to look up the name of an entity type by its ID. It is particularly useful when you have the ID of an entity type and need to retrieve its corresponding name for display or further processing.

### Related Objects

- **dbo.entity_type**: The table that stores the entity types and their corresponding IDs and names.
- **dbo.get_entity_type_id**: A complementary function that retrieves the ID of an entity type based on its name.

### Sample Usage

To retrieve the name of an entity type with ID 2:

```sql
select dbo.get_entity_type_name(2);
```

### Technical Details

- **Error Handling**: The function does not explicitly handle cases where the entity type ID does not exist in the `dbo.entity_type` table. It is assumed that the ID will always match an existing record.
- **Performance**: The function performs a simple lookup query, making it efficient for retrieving entity type names.

This function is essential for converting entity type IDs into names, facilitating operations that require names instead of IDs within the EV database.