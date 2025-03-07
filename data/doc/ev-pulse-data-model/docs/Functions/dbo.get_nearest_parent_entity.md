## dbo.get_nearest_parent_entity Function Documentation

### Overview

The `dbo.get_nearest_parent_entity` function is designed to retrieve the nearest parent entity of a specified type for a given entity within the EV database. This function is particularly useful for navigating hierarchical relationships and determining inheritance paths among entities.

### Function Definition

```sql
create or replace function dbo.get_nearest_parent_entity(
    p_id uuid,
    p_entity_type_id integer,
    p_target_entity_type_id integer,
    p_max_depth integer default 10
)
returns dbo.entity as
$$
declare
    v_parent_id uuid;
    v_parent_entity dbo.entity%rowtype;
begin
    v_parent_id := dbo.get_nearest_parent(p_id, p_entity_type_id, p_target_entity_type_id, p_max_depth);

    if v_parent_id is not null then
        select * into v_parent_entity
        from dbo.entity
        where id = v_parent_id and entity_type_id = p_target_entity_type_id;

        return v_parent_entity;
    else
        return null;
    end if;
end;
$$
language plpgsql;
```

### Parameters

- **p_id**: The UUID of the entity for which to find the nearest parent.
- **p_entity_type_id**: The entity type ID of the entity.
- **p_target_entity_type_id**: The entity type ID of the target parent entity.
- **p_max_depth**: The maximum depth to search for the parent entity (default is 10).

### Return Value

- Returns a record of type `dbo.entity` representing the nearest parent entity of the specified type. If no such parent is found, it returns `null`.

### Functional Usage

- **Hierarchical Navigation**: This function is used to navigate the hierarchical structure of entities, allowing for the retrieval of the nearest parent entity of a specified type.
- **Inheritance Management**: It aids in managing inheritance by identifying the closest ancestor from which attributes or features can be inherited.

### Related Objects

- **dbo.entity**: The table storing entity information, including hierarchical relationships.
- **dbo.get_nearest_parent**: A helper function that retrieves the nearest parent ID of a specified type.

### Sample Usage

To find the nearest parent entity of type 'Model' for a given 'Variant' entity:

```sql
select * from dbo.get_nearest_parent_entity('variant-uuid', 2, 1, 10);
```

### Technical Details

- **Recursive Query**: The function utilizes a recursive common table expression (CTE) to traverse the entity hierarchy up to the specified maximum depth.
- **Error Handling**: The function returns `null` if no parent entity of the specified type is found within the maximum depth.

This function is essential for managing and querying hierarchical data within the EV database, enabling efficient navigation and inheritance of attributes and features among entities.