## dbo.get_vehicle_features Function Documentation

### Overview

The `dbo.get_vehicle_features` function retrieves a comprehensive list of features associated with a specific electric vehicle (EV). This includes features inherited from the vehicle's components, such as the variant, motor, and battery. The function returns a detailed table outlining each feature, its source, and whether it is inherited.

### Function Definition

```plsql
create or replace function dbo.get_vehicle_features(
    p_vehicle_id uuid
)
returns table (
    vehicle_part text,
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
    select 'Variant' as vehicle_part, ef.*
    from dbo.get_entity_features(v_variant_id, dbo.get_entity_type_id('Variant')) ef
    union all
    select 'Motor' as vehicle_part, ef.*
    from dbo.get_entity_features(v_motor_id, dbo.get_entity_type_id('Motor')) ef
    union all
    select 'Battery' as vehicle_part, ef.*
    from dbo.get_entity_features(v_battery_id, dbo.get_entity_type_id('Battery')) ef
    order by vehicle_part, is_inherited, entity_id;
end;
$$
language plpgsql;
```

### Parameters

- **p_vehicle_id**: A UUID that uniquely identifies the vehicle for which features are to be retrieved.

### Returns

The function returns a table with the following columns:

- **vehicle_part**: The part of the vehicle the feature is associated with (e.g., Variant, Motor, Battery).
- **entity_id**: The unique identifier of the entity associated with the feature.
- **entity_type_id**: The type of the entity (e.g., Variant, Motor, Battery).
- **feature_id**: The unique identifier of the feature.
- **is_optional**: A boolean indicating whether the feature is optional.
- **is_active**: A boolean indicating whether the feature is active.
- **price**: The price of the feature.
- **currency**: The currency in which the price is specified.
- **is_inherited**: A boolean indicating whether the feature is inherited from a parent entity.
- **source_entity_id**: The unique identifier of the source entity from which the feature is inherited.
- **source_entity_type_id**: The type of the source entity.

### Functional Usage

- **Feature Retrieval**: This function is used to retrieve all features associated with a vehicle, including those inherited from its components.
- **Inheritance Handling**: The function handles the inheritance of features, indicating whether a feature is directly associated with the vehicle or inherited from a parent entity.

### Related Objects

- **dbo.vehicle**: The table storing vehicle information, including references to the variant, motor, and battery.
- **dbo.get_entity_features**: A function that retrieves features for a specific entity, used within this function to gather features for the vehicle's components.

### Sample Usage

To retrieve the features for a specific vehicle:

```plsql
select * from dbo.get_vehicle_features('vehicle-uuid');
```

### Technical Details

- **Recursive Query**: The function uses a recursive query to traverse the hierarchy of entities and gather inherited features.
- **Union All**: The results from different vehicle parts (Variant, Motor, Battery) are combined using `UNION ALL` to provide a comprehensive list of features.

This function is essential for understanding the complete set of features associated with an electric vehicle, including those inherited from its components.