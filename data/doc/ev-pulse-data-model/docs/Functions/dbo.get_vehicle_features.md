## dbo.get_vehicle_features Function Documentation

### Overview

The `dbo.get_vehicle_features` function retrieves a comprehensive list of features associated with a specific vehicle, including both vehicle-level features and those inherited from its parts. This function is essential for understanding the complete set of features that apply to a vehicle, considering the hierarchical structure of the database.

### Function Definition

```sql
create or replace function dbo.get_vehicle_features(
    p_vehicle_id uuid
)
returns table (
    entity_id uuid,
    entity_type_id integer,
    entity_name text,
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
    -- Get features directly associated with the vehicle
    return query
    select vf.vehicle_id as entity_id,
           null::integer as entity_type_id,
           v.name as entity_name,
           vf.feature_id,
           vf.is_optional,
           vf.is_active,
           vf.price,
           vf.currency,
           false as is_inherited,
           vf.vehicle_id as source_entity_id,
           null::integer as source_entity_type_id
    from dbo.vehicle_feature vf
    join dbo.vehicle v on vf.vehicle_id = v.vehicle_id
    where vf.vehicle_id = p_vehicle_id

    union all

    -- Get features inherited from vehicle parts
    select ef.entity_id,
           ef.entity_type_id,
           e.name as entity_name,
           ef.feature_id,
           ef.is_optional,
           ef.is_active,
           ef.price,
           ef.currency,
           ef.entity_id != ef.source_entity_id as is_inherited,
           ef.source_entity_id,
           ef.source_entity_type_id
    from dbo.vehicle_part vp
    join dbo.entity e on vp.entity_id = e.id and vp.entity_type_id = e.entity_type_id
    join dbo.get_entity_features(vp.entity_id, vp.entity_type_id) ef on true
    where vp.vehicle_id = p_vehicle_id
    order by vehicle_part, is_inherited, entity_id;
end;
$$
language plpgsql;
```

### Parameters

- **p_vehicle_id**: The UUID of the vehicle for which to retrieve features.

### Returns

- A table containing the following columns:
  - **entity_id**: The UUID of the entity (vehicle or part).
  - **entity_type_id**: The type ID of the entity (null for vehicle-level features).
  - **entity_name**: The name of the entity.
  - **feature_id**: The ID of the feature.
  - **is_optional**: A boolean indicating whether the feature is optional.
  - **is_active**: A boolean indicating whether the feature is active.
  - **price**: The price of the feature.
  - **currency**: The currency of the feature price.
  - **is_inherited**: A boolean indicating whether the feature is inherited from a part.
  - **source_entity_id**: The UUID of the source entity from which the feature is inherited.
  - **source_entity_type_id**: The type ID of the source entity.

### Functional Usage

- **Feature Retrieval**: This function is used to retrieve all features associated with a vehicle, including those inherited from its parts.
- **Hierarchical Traversal**: The function uses a union to combine vehicle-level features with those inherited from parts, providing a comprehensive view of all applicable features.

### Related Objects

- **dbo.vehicle**: The table defining vehicles.
- **dbo.vehicle_feature**: The table storing features associated with vehicles.
- **dbo.vehicle_part**: The table defining the parts of a vehicle.
- **dbo.entity**: The table defining entities and their hierarchical relationships.
- **dbo.get_entity_features**: The function used to retrieve features for an entity.

### Sample Usage

To retrieve the features for a specific vehicle:

```sql
select * from dbo.get_vehicle_features('vehicle-uuid');
```

### Technical Details

- **Union Operation**: The function uses a union to combine features directly associated with the vehicle and those inherited from its parts.
- **Inheritance Logic**: The function considers the hierarchical structure of the vehicle and its parts to determine inherited features.

This function is crucial for understanding the complete set of features that apply to a vehicle, considering both direct associations and inheritance from parts.