## dbo.vehicle Table Documentation

### Overview

The `dbo.vehicle` table represents electric vehicles (EVs) within the database. Each vehicle is defined by its unique ID and is composed of a variant, motor, and battery, each of which is an entity in the `dbo.entity` table. This table ensures that each vehicle configuration is unique and allows for the management of vehicle-specific attributes and features.

### Table Definition

```plsql
create table if not exists dbo.vehicle (
    vehicle_id uuid default gen_random_uuid(),
    variant_id uuid not null,
    variant_type_id integer not null,
    motor_id uuid not null,
    motor_type_id integer not null,
    battery_id uuid not null,
    battery_type_id integer not null,
    is_active boolean not null default true,
    primary key (vehicle_id),
    unique (variant_id, motor_id, battery_id),
    foreign key (variant_id, variant_type_id) references dbo.entity(id, entity_type_id),
    foreign key (motor_id, motor_type_id) references dbo.entity(id, entity_type_id),
    foreign key (battery_id, battery_type_id) references dbo.entity(id, entity_type_id)
);
```

### Columns

- **vehicle_id**: A unique identifier for the vehicle, generated using `gen_random_uuid()`.
- **variant_id**: A UUID that references the variant entity associated with the vehicle.
- **variant_type_id**: An integer that specifies the type of the variant entity.
- **motor_id**: A UUID that references the motor entity associated with the vehicle.
- **motor_type_id**: An integer that specifies the type of the motor entity.
- **battery_id**: A UUID that references the battery entity associated with the vehicle.
- **battery_type_id**: An integer that specifies the type of the battery entity.
- **is_active**: A boolean flag indicating whether the vehicle is active.

### Functional Usage

- **Vehicle Configuration**: The `dbo.vehicle` table allows for the configuration of electric vehicles by associating them with specific variants, motors, and batteries.
- **Uniqueness**: The combination of `variant_id`, `motor_id`, and `battery_id` must be unique, ensuring that each vehicle configuration is distinct.
- **Activation Status**: The `is_active` column allows for the activation or deactivation of vehicles without deleting them from the database.

### Related Objects

- **dbo.entity**: References entities for variants, motors, and batteries.
- **dbo.vehicle_feature**: Stores features associated with vehicles.
- **dbo.vehicle_attribute**: Stores attributes associated with vehicles.
- **dbo.check_vehicle_type_ids**: A trigger function that ensures the correct entity types are used for variants, motors, and batteries.

### Sample Usage

To insert a new vehicle configuration, you can use the following SQL statement:

```plsql
insert into dbo.vehicle (variant_id, variant_type_id, motor_id, motor_type_id, battery_id, battery_type_id, is_active)
values ('variant-uuid', 2, 'motor-uuid', 4, 'battery-uuid', 3, true);
```

### Technical Details

- **UUID Generation**: The `vehicle_id` column is automatically populated with a unique UUID using `gen_random_uuid()`.
- **Constraint Management**: The `vehicle_id` column serves as the primary key, ensuring that each vehicle has a unique identifier. The combination of `variant_id`, `motor_id`, and `battery_id` is also unique.
- **Foreign Keys**: The table includes foreign key constraints that reference the `dbo.entity` table for variants, motors, and batteries, ensuring referential integrity.

This table is crucial for managing electric vehicle configurations and ensuring that each vehicle is associated with the correct components.