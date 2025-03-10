## dbo.check_vehicle_has_parts Function Documentation

### Overview

The `dbo.check_vehicle_has_parts` function is a trigger function that ensures a vehicle has at least one associated part. This function is crucial for maintaining data integrity by enforcing that every vehicle entry in the database is associated with at least one part, reflecting the real-world requirement that a vehicle must be composed of various components.

### Function Definition

```sql
create or replace function dbo.check_vehicle_has_parts()
returns trigger as
$$
begin
    if not exists (select 1 from dbo.vehicle_part where vehicle_id = new.vehicle_id) then
        raise exception 'A vehicle must have at least one part';
    end if;
    return new;
end;
$$
language plpgsql;
```

### Parameters

- This function does not take any explicit parameters but operates on the `NEW` record that is being inserted into the `dbo.vehicle` table.

### Returns

- **trigger**: The function returns the `NEW` record if the condition is met, allowing the insert operation to proceed.

### Functional Usage

- **Data Integrity**: This function ensures that every vehicle in the database has at least one associated part, maintaining the integrity and completeness of vehicle data.
- **Trigger Execution**: The function is designed to be executed as an `AFTER INSERT` trigger on the `dbo.vehicle` table.

### Related Objects

- **dbo.vehicle**: The table representing vehicles, which must have at least one part.
- **dbo.vehicle_part**: The table representing the parts that make up a vehicle.

### Sample Usage

The function is automatically invoked by the trigger mechanism when a new vehicle is inserted into the `dbo.vehicle` table. Here is how the trigger is defined:

```sql
create or replace trigger check_vehicle_has_parts
after insert on dbo.vehicle
for each row
execute function dbo.check_vehicle_has_parts();
```

### Technical Details

- **Exception Handling**: The function raises an exception if no parts are found for the vehicle, preventing the insert operation from completing.
- **Trigger Timing**: The function is executed after the insert operation on the `dbo.vehicle` table, ensuring that the check is performed once the new vehicle record is available.

This function plays a vital role in enforcing business rules related to vehicle composition, ensuring that the database accurately reflects real-world constraints.