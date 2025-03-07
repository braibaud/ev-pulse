## dbo.vehicle_attribute Table Documentation

### Overview

The `dbo.vehicle_attribute` table stores the attributes associated with specific vehicles in the EV database. Each entry in this table represents an attribute value for a given vehicle, allowing for the detailed characterization of vehicle-specific characteristics such as performance metrics, dimensions, or safety features.

### Table Definition

```plsql
create table if not exists dbo.vehicle_attribute (
    vehicle_id uuid not null,
    attribute_id integer not null,
    is_active boolean not null default true,
    value text not null,
    unit text,
    primary key (vehicle_id, attribute_id),
    foreign key (vehicle_id) references dbo.vehicle(vehicle_id),
    foreign key (attribute_id) references dbo.attribute(id)
);
```

### Columns

- **vehicle_id**: A UUID that references the vehicle to which the attribute is associated.
- **attribute_id**: An integer that references the attribute being defined for the vehicle.
- **is_active**: A boolean flag indicating whether the attribute value is active.
- **value**: The value of the attribute (e.g., "300 kW" for a power attribute).
- **unit**: The unit of measurement for the attribute value (e.g., "kW" for power).

### Functional Usage

- **Attribute Assignment**: The `dbo.vehicle_attribute` table allows for the assignment of specific attribute values to vehicles, enabling detailed descriptions of their characteristics.
- **Activation Status**: The `is_active` column allows for the activation or deactivation of attribute values without deleting them from the database.

### Related Objects

- **dbo.vehicle**: References the vehicles to which attributes are assigned.
- **dbo.attribute**: Defines the attributes that can be assigned to vehicles.
- **dbo.set_vehicle_attribute_value**: A function that sets or updates the value of an attribute for a vehicle.

### Sample Usage

To insert a new attribute value for a vehicle, you can use the following SQL statement:

```plsql
insert into dbo.vehicle_attribute (vehicle_id, attribute_id, is_active, value, unit)
values ('vehicle-uuid', 1, true, '300', 'kW');
```

To retrieve all active attribute values for a specific vehicle:

```plsql
select * from dbo.vehicle_attribute where vehicle_id = 'vehicle-uuid' and is_active = true;
```

### Technical Details

- **Composite Primary Key**: The combination of `vehicle_id` and `attribute_id` serves as the primary key, ensuring that each attribute value is unique for a given vehicle.
- **Foreign Keys**: The table includes foreign key constraints that reference the `dbo.vehicle` and `dbo.attribute` tables, ensuring referential integrity.

This table is essential for managing the detailed characteristics of vehicles within the EV database, enabling structured and organized data management.