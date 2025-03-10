## dbo.get_attribute_id Function Documentation

### Overview

The `dbo.get_attribute_id` function retrieves the unique identifier (ID) of an attribute based on its name. This function is essential for mapping attribute names to their corresponding IDs, which are used throughout the database to reference attributes.

### Function Definition

```sql
create or replace function dbo.get_attribute_id(p_attribute_name text)
returns integer as
$$
declare
    v_attribute_id integer;
begin
    select id into v_attribute_id
    from dbo.attribute
    where name = p_attribute_name;

    return v_attribute_id;
end;
$$
language plpgsql;
```

### Parameters

- **p_attribute_name**: The name of the attribute for which to retrieve the ID.

### Returns

- An integer representing the ID of the attribute.

### Functional Usage

- **Attribute ID Retrieval**: This function is used to obtain the ID of an attribute by providing its name. This is particularly useful when you need to reference attributes by their IDs in other database operations or functions.

### Related Objects

- **dbo.attribute**: The table defining attributes and their properties, including the name and ID.

### Sample Usage

To retrieve the ID of an attribute named 'Range':

```sql
select dbo.get_attribute_id('Range');
```

### Technical Details

- **Single Responsibility**: The function has a single responsibility, which is to map attribute names to their IDs. This makes it straightforward and efficient for lookups.
- **Error Handling**: The function assumes that the attribute name exists in the `dbo.attribute` table. Additional error handling can be implemented to manage cases where the attribute name does not exist.

This function is a fundamental utility for working with attributes in the database, enabling easy lookup of attribute IDs based on their names.