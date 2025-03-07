## dbo.set_vehicle_attribute_value Function Documentation

### Overview

The `dbo.set_vehicle_attribute_value` function is used to set or update the value of an attribute for a specific vehicle in the EV database. This function ensures that the attribute value is correctly assigned to the vehicle, adhering to the overridability rules defined for the attribute.

### Function Definition

```sql
create or replace function dbo.set_vehicle_attribute_value(
    p_vehicle_id uuid,
    p_attribute_id integer,
    p_value text,
    p_unit text
)
returns void as
$$
declare
    v_existing_attribute dbo.vehicle_attribute%rowtype;
    v_attribute dbo.attribute%rowtype;
begin
    select * into v_attribute
    from dbo.attribute
    where id = p_attribute_id;

    if not v_attribute.is_overridable then
        raise exception 'Cannot override non-overridable attribute';
    end if;

    select * into v_existing_attribute
    from dbo.vehicle_attribute
    where vehicle_id = p_vehicle_id and attribute_id = p_attribute_id;

    if v_existing_attribute is not null and not v_existing_attribute.is_overridable then
        raise exception 'Cannot override non-overridable attribute';
    end if;

    insert into dbo.vehicle_attribute (vehicle_id, attribute_id, is_active, value, unit)
    values (p_vehicle_id, p_attribute_id, true, p_value, p_unit)
    on conflict (vehicle_id, attribute_id) do update
    set value = p_value, unit = p_unit;
end;
$$
language plpgsql;
```

### Parameters

- **p_vehicle_id**: A UUID that specifies the vehicle for which the attribute value is being set.
- **p_attribute_id**: An integer that specifies the attribute to be set.
- **p_value**: The value to be assigned to the attribute.
- **p_unit**: The unit of measurement for the attribute value.

### Functional Usage

- **Attribute Assignment**: This function assigns a value to a specific attribute for a given vehicle. It checks whether the attribute is overridable before making any changes.
- **Conflict Handling**: The function uses the `ON CONFLICT` clause to update the attribute value if it already exists for the vehicle.

### Related Objects

- **dbo.vehicle_attribute**: The table where vehicle-specific attribute values are stored.
- **dbo.attribute**: The table defining the attributes and their properties, such as overridability.

### Sample Usage

To set or update an attribute value for a vehicle:

```sql
select dbo.set_vehicle_attribute_value(
    'vehicle-uuid',
    1,
    'New Attribute Value',
    'Unit'
);
```

### Technical Details

- **Error Handling**: The function raises an exception if an attempt is made to override a non-overridable attribute.
- **Transactional Integrity**: The function ensures that attribute values are correctly assigned or updated, maintaining the integrity of the vehicle's attribute data.

This function is essential for managing vehicle-specific attributes, ensuring that the correct values are assigned and maintained in the EV database.