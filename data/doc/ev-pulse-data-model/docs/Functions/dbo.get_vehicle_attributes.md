## dbo.get_vehicle_attributes Function Documentation

### Overview

The `dbo.get_vehicle_attributes` function retrieves a comprehensive list of attributes associated with a specific vehicle, including both direct attributes and those inherited from its parts. This function is essential for understanding the complete set of attributes that apply to a vehicle, considering the hierarchical structure of the database.

### Function Definition

```sql
create or replace function dbo.get_vehicle_attributes(
    p_vehicle_id uuid
)
returns table (
    entity_id uuid,
    entity_type_id integer,
    entity_name text,
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
    -- Get attributes directly associated with the vehicle
    return query
    select va.vehicle_id as entity_id,
           null::integer as entity_type_id,
           v.name as entity_name,
           va.attribute_id,
           va.is_active,
           va.value,
           va.unit,
           false as is_inherited,
           va.vehicle_id as source_entity_id,
           null::integer as source_entity_type_id
    from dbo.vehicle_attribute va
    join dbo.vehicle v on va.vehicle_id = v.vehicle_id
    where va.vehicle_id = p_vehicle_id

    union all

    -- Get attributes inherited from vehicle parts
    select ea.entity_id,
           ea.entity_type_id,
           e.name as entity_name,
           ea.attribute_id,
           ea.is_active,
           ea.value,
           ea.unit,
           ea.entity_id != ea.source_entity_id as is_inherited,
           ea.source_entity_id,
           ea.source_entity_type_id
    from dbo.vehicle_part vp
    join dbo.entity e on vp.entity_id = e.id and vp.entity_type_id = e.entity_type_id
    join dbo.get_entity_attributes(vp.entity_id, vp.entity_type_id) ea on true
    where vp.vehicle_id = p_vehicle_id
    order by vehicle_part, is_inherited, entity_id;
end;
$$
language plpgsql;
```

### Parameters

- **p_vehicle_id**: The UUID of the vehicle for which to retrieve attributes.

### Returns

- A table containing the following columns:
  - **entity_id**: The UUID of the entity (vehicle or part).
  - **entity_type_id**: The type ID of the entity (null for direct vehicle attributes).
  - **entity_name**: The name of the entity.
  - **attribute_id**: The ID of the attribute.
  - **is_active**: A boolean indicating whether the attribute is active.
  - **value**: The value of the attribute.
  - **unit**: The unit of the attribute value.
  - **is_inherited**: A boolean indicating whether the attribute is inherited from a part.
  - **source_entity_id**: The UUID of the source entity from which the attribute is inherited.
  - **source_entity_type_id**: The type ID of the source entity.

### Functional Usage

- **Attribute Retrieval**: This function is used to retrieve all attributes associated with a vehicle, including those inherited from its parts.
- **Hierarchical Traversal**: The function uses a union to combine direct vehicle attributes with those inherited from parts, providing a comprehensive view of the vehicle's attributes.

### Related Objects

- **dbo.vehicle**: The table defining vehicles.
- **dbo.vehicle_attribute**: The table storing attributes directly associated with vehicles.
- **dbo.vehicle_part**: The table defining the parts of a vehicle.
- **dbo.entity**: The table defining entities and their hierarchical relationships.
- **dbo.get_entity_attributes**: The function used to retrieve attributes for entities.

### Sample Usage

To retrieve the attributes for a specific vehicle:

```sql
select * from dbo.get_vehicle_attributes('vehicle-uuid');
```

### Technical Details

- **Union Operation**: The function uses a union to combine direct vehicle attributes with those inherited from parts, ensuring a comprehensive list of attributes.
- **Inheritance Logic**: The function considers the hierarchical structure of the vehicle and its parts to determine inherited attributes.

This function is crucial for understanding the complete set of attributes that apply to a vehicle, considering both direct and inherited attributes from its parts.