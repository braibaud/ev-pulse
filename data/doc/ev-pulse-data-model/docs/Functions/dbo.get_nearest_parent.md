## dbo.get_nearest_parent Function Documentation

### Overview

The `dbo.get_nearest_parent` function is designed to find the nearest parent entity of a specified type for a given entity within the EV database. This function is useful for navigating hierarchical relationships between entities, such as finding the closest ancestor of a particular type (e.g., finding the model of a variant).

### Function Definition

```plsql
create or replace function dbo.get_nearest_parent(
    p_id uuid,
    p_entity_type_id integer,
    p_target_entity_type_id integer,
    p_max_depth integer default 10
) returns uuid as
$$
begin
    return (
        with recursive parent_hierarchy as (
            select id, entity_type_id, parent_id, parent_entity_type_id, 1 as depth
            from dbo.entity
            where id = p_id and entity_type_id = p_entity_type_id
            union all
            select e.id, e.entity_type_id, e.parent_id, e.parent_entity_type_id, ph.depth + 1
            from dbo.entity e
            inner join parent_hierarchy ph on e.id = ph.parent_id and e.entity_type_id = ph.parent_entity_type_id
            where ph.depth < p_max_depth
        )
        select parent_id
        from parent_hierarchy
        where parent_entity_type_id = p_target_entity_type_id
        order by depth, id
        limit 1
    );
end;
$$
language plpgsql;
```

### Parameters

- **p_id**: A UUID that specifies the ID of the entity for which to find the nearest parent.
- **p_entity_type_id**: An integer that specifies the type of the entity.
- **p_target_entity_type_id**: An integer that specifies the type of the parent entity to search for.
- **p_max_depth**: An optional integer that specifies the maximum depth to search in the hierarchy (default is 10).

### Return Value

- Returns a UUID representing the ID of the nearest parent entity of the specified type.

### Functional Usage

- **Hierarchical Navigation**: This function is used to navigate the hierarchical relationships between entities, allowing you to find the nearest ancestor of a specific type.
- **Depth Control**: The `p_max_depth` parameter allows you to control how far up the hierarchy the function will search for a parent entity.

### Related Objects

- **dbo.entity**: The table that stores entities and their hierarchical relationships.
- **dbo.get_nearest_parent_entity**: A related function that returns the entire entity record of the nearest parent, rather than just the ID.

### Sample Usage

To find the nearest parent of type 'Model' for a given variant entity:

```plsql
select dbo.get_nearest_parent('variant-uuid', 2, 1, 5);
```

### Technical Details

- **Recursive CTE**: The function uses a recursive common table expression (CTE) to traverse the entity hierarchy up to the specified maximum depth.
- **Performance**: The function is optimized to stop searching once the nearest parent of the specified type is found, improving performance in large hierarchies.

This function is essential for navigating and understanding the hierarchical relationships between entities within the EV database.