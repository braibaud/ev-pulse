## dbo.set_entity_attribute_value Function Documentation

### Overview

The `dbo.set_entity_attribute_value` function is designed to set or update the value of an attribute for a specific entity in the EV database. This function supports the propagation of attribute values down the entity hierarchy, allowing child entities to inherit updated values from their parent entities.

### Function Definition

```plsql
create or replace function dbo.set_entity_attribute_value(
    p_entity_id uuid,
    p_entity_type_id integer,
    p_attribute_id integer,
    p_value text,
    p_unit text,
    p_propagate_down boolean default false
)
returns void as
$$
declare
    v_existing_attribute dbo.entity_attribute%rowtype;
    v_attribute dbo.attribute%rowtype;
begin
    select * into v_attribute
    from dbo.attribute
    where id = p_attribute_id;

    if not v_attribute.is_overridable then
        raise exception 'Cannot override non-overridable attribute';
    end if;

    select * into v_existing_attribute
    from dbo.entity_attribute
    where entity_id = p_entity_id and entity_type_id = p_entity_type_id and attribute_id = p_attribute_id;

    if v_existing_attribute is not null and not v_existing_attribute.is_overridable then
        raise exception 'Cannot override non-overridable attribute';
    end if;

    insert into dbo.entity_attribute (entity_id, entity_type_id, attribute_id, is_active, value, unit)
    values (p_entity_id, p_entity_type_id, p_attribute_id, true, p_value, p_unit)
    on conflict (entity_id, entity_type_id, attribute_id) do update
    set value = p_value, unit = p_unit;

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
        insert into dbo.entity_attribute (entity_id, entity_type_id, attribute_id, is_active, value, unit)
        select ce.id, ce.entity_type_id, p_attribute_id, true, p_value, p_unit
        from child_entities ce
        on conflict (entity_id, entity_type_id, attribute_id) do update
        set value = p_value, unit = p_unit;
    end if;
end;
$$
language plpgsql;
```

### Parameters

- **p_entity_id**: The UUID of the entity for which the attribute value is being set.
- **p_entity_type_id**: The integer ID of the entity type.
- **p_attribute_id**: The integer ID of the attribute being set.
- **p_value**: The new value for the attribute.
- **p_unit**: The unit of measurement for the attribute value.
- **p_propagate_down**: A boolean flag indicating whether the attribute value should be propagated to child entities. Default is `false`.

### Functional Usage

- **Attribute Value Management**: This function allows for setting or updating the value of an attribute for a specific entity. It ensures that non-overridable attributes cannot be overridden.
- **Propagation**: When `p_propagate_down` is set to `true`, the function propagates the attribute value to all child entities, ensuring consistency across the entity hierarchy.

### Related Objects

- **dbo.entity_attribute**: Stores the attribute values for entities.
- **dbo.attribute**: Defines the attributes that can be associated with entities.

### Sample Usage

To set an attribute value for an entity and propagate it to its child entities:

```plsql
select dbo.set_entity_attribute_value(
    'entity-uuid',
    2,
    5,
    'New Value',
    'Unit',
    true
);
```

### Technical Details

- **Conflict Handling**: The function uses the `ON CONFLICT` clause to update the attribute value if it already exists for the entity.
- **Recursive Propagation**: The function uses a recursive common table expression (CTE) to propagate the attribute value to all child entities in the hierarchy.

This function is essential for managing attribute values across the entity hierarchy in the EV database, ensuring consistency and reducing redundancy.