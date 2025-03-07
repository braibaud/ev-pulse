## dbo.get_entity_attributes Function Documentation

### Overview

The `dbo.get_entity_attributes` function retrieves a list of attributes associated with a specific entity, including inherited attributes from its parent entities. This function is essential for understanding the complete set of attributes that apply to an entity, considering the hierarchical structure of the database.

### Function Definition

```sql
create or replace function dbo.get_entity_attributes(
    p_id uuid,
    p_entity_type_id integer
)
returns table (
    entity_id uuid,
    entity_type_id integer,
    attribute_id integer,
    is_active boolean,
    value text,
    unit text,
    is_inherited boolean,
    source_entity_id uuid,
    source_entity_type_id integer
) as
$$
begin
    return query
    with recursive entity_hierarchy as (
        select id, entity_type_id, parent_id, parent_entity_type_id, id as source_entity_id, entity_type_id as source_entity_type_id
        from dbo.entity
        where id = p_id and entity_type_id = p_entity_type_id
        union all
        select e.id, e.entity_type_id, e.parent_id, e.parent_entity_type_id, eh.source_entity_id, eh.source_entity_type_id
        from dbo.entity e
        inner join entity_hierarchy eh on e.id = eh.parent_id and e.entity_type_id = eh.parent_entity_type_id
    )
    select ea.entity_id, ea.entity_type_id, ea.attribute_id, ea.is_active, ea.value, ea.unit,
           ea.entity_id != eh.id as is_inherited,
           eh.source_entity_id, eh.source_entity_type_id
    from dbo.entity_attribute ea
    inner join entity_hierarchy eh on ea.entity_id = eh.id and ea.entity_type_id = eh.entity_type_id
    inner join dbo.attribute a on ea.attribute_id = a.id
    where a.is_inheritable or ea.entity_id = p_id
    order by is_inherited, eh.id;
end;
$$
language plpgsql;
```

### Parameters

- **p_id**: The UUID of the entity for which to retrieve attributes.
- **p_entity_type_id**: The integer ID representing the type of the entity.

### Returns

- A table containing the following columns:
  - **entity_id**: The UUID of the entity.
  - **entity_type_id**: The type ID of the entity.
  - **attribute_id**: The ID of the attribute.
  - **is_active**: A boolean indicating whether the attribute is active.
  - **value**: The value of the attribute.
  - **unit**: The unit of the attribute value.
  - **is_inherited**: A boolean indicating whether the attribute is inherited from a parent entity.
  - **source_entity_id**: The UUID of the source entity from which the attribute is inherited.
  - **source_entity_type_id**: The type ID of the source entity.

### Functional Usage

- **Attribute Retrieval**: This function is used to retrieve all attributes associated with an entity, including those inherited from its parent entities.
- **Hierarchical Traversal**: The function uses a recursive common table expression (CTE) to traverse the entity hierarchy and collect attributes from parent entities.

### Related Objects

- **dbo.entity**: The table defining entities and their hierarchical relationships.
- **dbo.entity_attribute**: The table storing attributes associated with entities.
- **dbo.attribute**: The table defining attributes and their inheritability.

### Sample Usage

To retrieve the attributes for a specific entity:

```sql
select * from dbo.get_entity_attributes('entity-uuid', 2);
```

### Technical Details

- **Recursive CTE**: The function uses a recursive CTE to traverse the entity hierarchy, allowing it to collect attributes from parent entities.
- **Inheritance Logic**: The function considers the `is_inheritable` flag of attributes to determine whether they should be inherited from parent entities.

This function is crucial for understanding the complete set of attributes that apply to an entity, considering the hierarchical structure and inheritance rules of the database.