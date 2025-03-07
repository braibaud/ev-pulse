## dbo.get_vehicle_attributes Function Documentation

### Overview

The `dbo.get_vehicle_attributes` function retrieves a comprehensive list of attributes associated with a specific vehicle, including those inherited from its components (variant, motor, and battery). This function is essential for understanding the complete attribute profile of an electric vehicle.

### Function Definition

```plsql
create or replace function dbo.get_vehicle_attributes(
    p_vehicle_id uuid
)
returns table (
    vehicle_part text,
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
declare
    v_variant_id uuid;
    v_motor_id uuid;
    v_battery_id uuid;
begin
    select variant_id, motor_id, battery_id
    into v_variant_id, v_motor_id, v_battery_id
    from dbo.vehicle
    where vehicle_id = p_vehicle_id;

    return query
    select 'Variant' as vehicle_part, ea.*
    from dbo.get_entity_attributes(v_variant_id, dbo.get_entity_type_id('Variant')) ea
    union all
    select 'Motor' as vehicle_part, ea.*
    from dbo.get_entity_attributes(v_motor_id, dbo.get_entity_type_id('Motor')) ea
    union all
    select 'Battery' as vehicle_part, ea.*
    from dbo.get_entity_attributes(v_battery_id, dbo.get_entity_type_id('Battery')) ea
    order by vehicle_part, is_inherited, entity_id;
end;
$$
language plpgsql;
```

### Parameters

- **p_vehicle_id**: A UUID that specifies the vehicle for which to retrieve attributes.

### Returns

- A table containing the following columns:
  - **vehicle_part**: The part of the vehicle (Variant, Motor, Battery) to which the attribute belongs.
  - **entity_id**: The UUID of the entity associated with the attribute.
  - **entity_type_id**: The type of the entity (e.g., Variant, Motor, Battery).
  - **attribute_id**: The ID of the attribute.
  - **is_active**: A boolean indicating whether the attribute is active.
  - **value**: The value of the attribute.
  - **unit**: The unit of measurement for the attribute value.
  - **is_inherited**: A boolean indicating whether the attribute is inherited from a parent entity.
  - **source_entity_id**: The UUID of the source entity from which the attribute is inherited.
  - **source_entity_type_id**: The type of the source entity.

### Functional Usage

- **Attribute Aggregation**: This function aggregates attributes from the variant, motor, and battery components of a vehicle, providing a unified view of the vehicle's attributes.
- **Inheritance Handling**: The function handles attribute inheritance, indicating whether an attribute is directly associated with the vehicle part or inherited from a parent entity.

### Related Objects

- **dbo.vehicle**: The table storing vehicle configurations, referenced to retrieve component IDs.
- **dbo.get_entity_attributes**: A function called to retrieve attributes for each vehicle component.
- **dbo.get_entity_type_id**: A function used to retrieve the entity type ID based on the entity type name.

### Sample Usage

To retrieve attributes for a specific vehicle:

```plsql
select * from dbo.get_vehicle_attributes('vehicle-uuid');
```

### Technical Details

- **Union All**: The function uses `UNION ALL` to combine attributes from the variant, motor, and battery, ensuring that all relevant attributes are included in the result set.
- **Ordering**: The results are ordered by vehicle part and inheritance status, making it easier to understand the origin of each attribute.

This function is crucial for obtaining a comprehensive overview of a vehicle's attributes, considering the inheritance and composition of its parts.