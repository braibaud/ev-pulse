## dbo.vehicle_part Table Documentation

### Overview

The `dbo.vehicle_part` table establishes a relationship between vehicles and their constituent parts, which are defined as entities in the `dbo.entity` table. This table is crucial for managing the composition of vehicles and understanding how different parts contribute to the overall vehicle configuration.

### Table Definition

```sql
create table if not exists dbo.vehicle_part (
    vehicle_id uuid not null,
    entity_id uuid not null,
    entity_type_id integer not null,
    part_type text not null,
    is_active boolean not null default true,
    primary key (vehicle_id, entity_id, entity_type_id),
    foreign key (vehicle_id) references dbo.vehicle(vehicle_id),
    foreign key (entity_id, entity_type_id) references dbo.entity(id, entity_type_id)
);
```

### Columns

- **vehicle_id**: A UUID that references the `vehicle_id` in the `dbo.vehicle` table, indicating the vehicle to which the part belongs.
- **entity_id**: A UUID that references the `id` in the `dbo.entity` table, representing the specific part.
- **entity_type_id**: An integer that references the `entity_type_id` in the `dbo.entity` table, specifying the type of the part (e.g., battery, motor).
- **part_type**: A text field describing the type or role of the part within the vehicle (e.g., 'Battery Pack', 'Electric Motor').
- **is_active**: A boolean flag indicating whether the part is active. This can be used to soft-delete parts without removing them from the database.

### Functional Usage

- **Vehicle Composition**: This table is used to define the parts that make up a vehicle. Each vehicle can have multiple parts, and each part can belong to multiple vehicles.
- **Part Management**: The `is_active` flag allows for soft deletion of parts, enabling them to be marked as inactive without removing their data from the database.

### Related Objects

- **dbo.vehicle**: The table defining vehicles to which parts are associated.
- **dbo.entity**: The table defining the parts as entities, including their types and hierarchical relationships.
- **dbo.check_unique_parts**: A trigger function that ensures each part is unique for a vehicle, preventing duplicate parts from being associated with the same vehicle.

### Sample Usage

To associate a part with a vehicle:

```sql
insert into dbo.vehicle_part (vehicle_id, entity_id, entity_type_id, part_type, is_active)
values ('vehicle-uuid', 'part-uuid', 3, 'Battery Pack', true);
```

### Technical Details

- **Composite Primary Key**: The primary key is composed of `vehicle_id`, `entity_id`, and `entity_type_id`, ensuring that each part is uniquely identified within the context of a vehicle.
- **Foreign Key Constraints**: The table enforces referential integrity with the `dbo.vehicle` and `dbo.entity` tables, ensuring that parts are valid and belong to existing vehicles and entities.

This table is essential for managing the composition of vehicles and understanding the relationship between vehicles and their parts.