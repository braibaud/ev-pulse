## dbo.set_entity_feature_value Function Documentation

### Overview

The `dbo.set_entity_feature_value` function is designed to set or update the value of a feature for a specific entity within the EV database. This function supports the propagation of feature values to child entities, ensuring consistency across hierarchical relationships.

### Function Definition

```sql
create or replace function dbo.set_entity_feature_value(
    p_entity_id uuid,
    p_entity_type_id integer,
    p_feature_id integer,
    p_price real,
    p_currency text,
    p_propagate_down boolean default false
)
returns void as
$$
declare
    v_existing_feature dbo.entity_feature%rowtype;
    v_feature dbo.feature%rowtype;
begin
    select * into v_feature
    from dbo.feature
    where id = p_feature_id;

    if not v_feature.is_overridable then
        raise exception 'Cannot override non-overridable feature';
    end if;

    select * into v_existing_feature
    from dbo.entity_feature
    where entity_id = p_entity_id and entity_type_id = p_entity_type_id and feature_id = p_feature_id;

    if v_existing_feature is not null and not v_existing_feature.is_overridable then
        raise exception 'Cannot override non-overridable feature';
    end if;

    insert into dbo.entity_feature (entity_id, entity_type_id, feature_id, is_active, price, currency)
    values (p_entity_id, p_entity_type_id, p_feature_id, true, p_price, p_currency)
    on conflict (entity_id, entity_type_id, feature_id) do update
    set price = p_price, currency = p_currency;

    if p_propagate_down then
        with recursive child_entities as (
            select id, entity_type_id
            from dbo.entity
            where parent_id = p_entity_id and parent_entity_type_id = p_entity_type_id
            union all
            select e.id, e.entity_type_id
            from dbo.entity e
            inner join child_entities ce on e.parent_id = ce.id and e.parent_entity_type_id = ce.entity_type_id
        )
        insert into dbo.entity_feature (entity_id, entity_type_id, feature_id, is_active, price, currency)
        select ce.id, ce.entity_type_id, p_feature_id, true, p_price, p_currency
        from child_entities ce
        on conflict (entity_id, entity_type_id, feature_id) do update
        set price = p_price, currency = p_currency;
    end if;
end;
$$
language plpgsql;
```

### Parameters

- **p_entity_id**: The UUID of the entity for which the feature value is being set.
- **p_entity_type_id**: The integer ID representing the type of the entity.
- **p_feature_id**: The integer ID of the feature being set.
- **p_price**: The price of the feature.
- **p_currency**: The currency in which the price is specified.
- **p_propagate_down**: A boolean flag indicating whether the feature value should be propagated to child entities. Default is `false`.

### Functional Usage

- **Feature Value Management**: This function allows setting or updating the price and currency of a feature for a specific entity.
- **Propagation**: When `p_propagate_down` is set to `true`, the feature value is propagated to all child entities, ensuring consistency across the hierarchy.
- **Override Check**: The function checks if the feature is overridable before making any updates. If the feature is not overridable, an exception is raised.

### Related Objects

- **dbo.entity_feature**: Stores the feature values associated with entities.
- **dbo.feature**: Defines the features that can be associated with entities.
- **dbo.entity**: Represents the entities to which features are assigned.

### Sample Usage

To set a feature value for an entity and propagate it to child entities:

```sql
select dbo.set_entity_feature_value(
    'entity-uuid',
    2,
    10,
    1500.00,
    'USD',
    true
);
```

### Technical Details

- **Conflict Handling**: The function uses the `ON CONFLICT` clause to update the feature value if it already exists for the entity.
- **Recursive Propagation**: The function uses a recursive common table expression (CTE) to propagate the feature value to all child entities.

This function is essential for managing feature values across hierarchical entity relationships in the EV database, ensuring consistency and reducing redundancy.