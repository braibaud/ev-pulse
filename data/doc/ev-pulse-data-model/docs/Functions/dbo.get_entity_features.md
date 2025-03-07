## dbo.get_entity_features Function Documentation

### Overview

The `dbo.get_entity_features` function retrieves a list of features associated with a specific entity, including inherited features from its parent entities. This function is essential for understanding the complete set of features available for an entity, considering the hierarchical structure of the database.

### Function Definition

```sql
create or replace function dbo.get_entity_features(
    p_id uuid,
    p_entity_type_id integer
)
returns table (
    entity_id uuid,
    entity_type_id integer,
    feature_id integer,
    is_optional boolean,
    is_active boolean,
    price real,
    currency text,
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
    select ef.entity_id, ef.entity_type_id, ef.feature_id, ef.is_optional, ef.is_active, ef.price, ef.currency,
           ef.entity_id != eh.id as is_inherited,
           eh.source_entity_id, eh.source_entity_type_id
    from dbo.entity_feature ef
    inner join entity_hierarchy eh on ef.entity_id = eh.id and ef.entity_type_id = eh.entity_type_id
    inner join dbo.feature f on ef.feature_id = f.id
    where f.is_inheritable or ef.entity_id = p_id
    order by is_inherited, eh.id;
end;
$$
language plpgsql;
```

### Parameters

- **p_id**: A UUID representing the ID of the entity for which features are to be retrieved.
- **p_entity_type_id**: An integer representing the type of the entity.

### Returns

- A table containing the following columns:
  - **entity_id**: The ID of the entity.
  - **entity_type_id**: The type of the entity.
  - **feature_id**: The ID of the feature.
  - **is_optional**: A boolean indicating if the feature is optional.
  - **is_active**: A boolean indicating if the feature is active.
  - **price**: The price of the feature.
  - **currency**: The currency of the feature price.
  - **is_inherited**: A boolean indicating if the feature is inherited from a parent entity.
  - **source_entity_id**: The ID of the source entity from which the feature is inherited.
  - **source_entity_type_id**: The type of the source entity from which the feature is inherited.

### Functional Usage

- **Feature Retrieval**: This function is used to retrieve all features associated with an entity, including those inherited from its parent entities.
- **Hierarchical Consideration**: The function considers the hierarchical structure of entities, ensuring that inherited features are included in the results.

### Related Objects

- **dbo.entity**: Represents the entities in the database.
- **dbo.entity_feature**: Stores the features associated with entities.
- **dbo.feature**: Defines the features that can be associated with entities.

### Sample Usage

To retrieve the features for a specific entity:

```sql
select * from dbo.get_entity_features('entity-uuid', 2);
```

### Technical Details

- **Recursive CTE**: The function uses a recursive common table expression (CTE) to traverse the entity hierarchy and retrieve inherited features.
- **Inheritance Logic**: Features are considered inherited if they are associated with a parent entity and are marked as inheritable.

This function is crucial for understanding the complete set of features available for an entity, considering the hierarchical relationships in the database.