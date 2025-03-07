## dbo.check_vehicle_type_ids Trigger Function Documentation

### Overview

The `dbo.check_vehicle_type_ids` function is a trigger function designed to validate the entity types of the variant, motor, and battery associated with a vehicle before it is inserted into the `dbo.vehicle` table. This function ensures that the correct entity types are used, maintaining data integrity within the EV database.

### Function Definition

```sql
create or replace function dbo.check_vehicle_type_ids()
returns trigger as
$$
begin
    if dbo.get_entity_type_name(new.variant_type_id) != 'Variant' then
        raise exception 'invalid variant_type_id, should be "Variant"';
    end if;

    if dbo.get_entity_type_name(new.motor_type_id) != 'Motor' then
        raise exception 'invalid motor_type_id, should be "Motor"';
    end if;

    if dbo.get_entity_type_name(new.battery_type_id) != 'Battery' then
        raise exception 'invalid battery_type_id, should be "Battery"';
    end if;

    return new;
end;
$$
language plpgsql;
```

### Parameters

- The function does not take any explicit parameters but operates on the `NEW` record that is being inserted into the `dbo.vehicle` table.

### Return Value

- Returns the `NEW` record if all validations pass.
- Raises an exception if any of the entity type IDs are invalid.

### Functional Usage

- **Data Validation**: This function ensures that the `variant_type_id`, `motor_type_id`, and `battery_type_id` fields in the `dbo.vehicle` table correspond to the correct entity types ('Variant', 'Motor', and 'Battery', respectively).
- **Trigger Integration**: The function is designed to be used as a trigger before insert operations on the `dbo.vehicle` table.

### Related Objects

- **dbo.vehicle**: The table on which this trigger function operates, ensuring data integrity for vehicle configurations.
- **dbo.get_entity_type_name**: A helper function that retrieves the name of an entity type based on its ID.
- **Trigger**: The trigger that invokes this function before insert operations on the `dbo.vehicle` table.

### Sample Usage

The trigger function is automatically invoked when a new record is inserted into the `dbo.vehicle` table. Here is how the trigger is defined:

```sql
create or replace trigger check_vehicle_type_ids
before insert on dbo.vehicle
for each row
execute function dbo.check_vehicle_type_ids();
```

### Technical Details

- **Exception Handling**: The function raises an exception if any of the entity type IDs do not match the expected values, preventing the insertion of invalid data.
- **Performance**: The function performs simple checks using the `dbo.get_entity_type_name` function, making it efficient for validating entity types.

This trigger function is crucial for maintaining the integrity of vehicle configurations within the EV database by ensuring that only valid entity types are associated with vehicles.