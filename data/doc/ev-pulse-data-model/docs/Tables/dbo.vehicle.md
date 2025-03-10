## dbo.vehicle Table Documentation

### Overview

The `dbo.vehicle` table represents the core entity for storing information about electric vehicles (EVs) in the database. Each entry in this table corresponds to a unique vehicle, identified by a UUID. This table is central to managing vehicle-specific data and linking to other related entities such as vehicle parts, attributes, and features.

### Table Definition

```sql
create table if not exists dbo.vehicle (
    vehicle_id uuid default gen_random_uuid(),
    name text not null,
    is_active boolean not null default true,
    primary key (vehicle_id)
);
```

### Columns

- **vehicle_id**: A UUID that uniquely identifies each vehicle. It is generated automatically using the `gen_random_uuid()` function from the `pgcrypto` extension.
- **name**: The name of the vehicle. This field is mandatory and should contain a descriptive name for the vehicle.
- **is_active**: A boolean flag indicating whether the vehicle is active. This can be used to soft-delete vehicles without removing them from the database.

### Functional Usage

- **Vehicle Management**: This table is used to manage the list of vehicles in the system. Each vehicle can have multiple parts, attributes, and features associated with it.
- **Unique Identification**: The `vehicle_id` serves as a unique identifier for each vehicle, ensuring that each vehicle can be distinctly referenced in related tables.

### Related Objects

- **dbo.vehicle_part**: This table links vehicles to their constituent parts, which are defined as entities in the `dbo.entity` table.
- **dbo.vehicle_attribute**: This table stores attributes specific to a vehicle, such as performance metrics or dimensions.
- **dbo.vehicle_feature**: This table stores features specific to a vehicle, such as optional extras or technology packages.
- **dbo.check_vehicle_has_parts**: A trigger function that ensures each vehicle has at least one part associated with it.

### Sample Usage

To insert a new vehicle into the table:

```sql
insert into dbo.vehicle (name, is_active)
values ('EcoCar Model X', true);
```

### Technical Details

- **UUID Generation**: The `vehicle_id` is automatically generated using the `gen_random_uuid()` function, ensuring a globally unique identifier for each vehicle.
- **Soft Delete**: The `is_active` flag allows for soft deletion of vehicles, enabling them to be marked as inactive without removing their data from the database.

This table is fundamental for managing vehicle data and serves as a central point for linking to other related entities in the database.