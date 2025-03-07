## dbo.get_entity_type_id Function Documentation

### Overview

The `dbo.get_entity_type_id` function retrieves the ID of an entity type based on its name. This function is useful for converting human-readable entity type names into their corresponding IDs, which are used in various tables and operations within the EV database.

### Function Definition

```sql
create or replace function dbo.get_entity_type_id(p_entity_type_name text)
returns integer as
$$
declare
    v_entity_type_id integer;
begin
    select id into v_entity_type_id
    from dbo.entity_type
    where name = p_entity_type_name;

    return v_entity_type_id;
end;
$$
language plpgsql;
```

### Parameters

- **p_entity_type_name**: A text parameter that specifies the name of the entity type (e.g., 'Variant', 'Motor').

### Return Value

- Returns an integer representing the ID of the entity type.

### Functional Usage

- **Entity Type Lookup**: This function is used to look up the ID of an entity type by its name. It is particularly useful when you have the name of an entity type and need to retrieve its corresponding ID for use in queries or other operations.

### Related Objects

- **dbo.entity_type**: The table that stores the entity types and their corresponding IDs and names.
- **dbo.get_entity_type_name**: A complementary function that retrieves the name of an entity type based on its ID.

### Sample Usage

To retrieve the ID of an entity type named 'Variant':

```sql
select dbo.get_entity_type_id('Variant');
```

### Technical Details

- **Error Handling**: The function does not explicitly handle cases where the entity type name does not exist in the `dbo.entity_type` table. It is assumed that the name will always match an existing record.
- **Performance**: The function performs a simple lookup query, making it efficient for retrieving entity type IDs.

This function is essential for converting entity type names into IDs, facilitating operations that require IDs instead of names within the EV database.