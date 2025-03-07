## dbo.vehicle_feature Table Documentation

### Overview

The `dbo.vehicle_feature` table stores the features associated with specific vehicles in the EV database. Each entry in this table represents a feature and its price for a given vehicle, allowing for the detailed characterization of optional or standard features for each vehicle configuration.

### Table Definition

```plsql
create table if not exists dbo.vehicle_feature (
    vehicle_id uuid not null,
    feature_id integer not null,
    is_optional boolean not null default true,
    is_active boolean not null default true,
    price real not null,
    currency text,
    primary key (vehicle_id, feature_id),
    foreign key (vehicle_id) references dbo.vehicle(vehicle_id),
    foreign key (feature_id) references dbo.feature(id)
);
```

### Columns

- **vehicle_id**: A UUID that references the vehicle to which the feature is associated.
- **feature_id**: An integer that references the feature being defined for the vehicle.
- **is_optional**: A boolean flag indicating whether the feature is optional for the vehicle.
- **is_active**: A boolean flag indicating whether the feature is active.
- **price**: The price of the feature.
- **currency**: The currency in which the price is specified (e.g., USD, EUR).

### Functional Usage

- **Feature Assignment**: The `dbo.vehicle_feature` table allows for the assignment of specific features and their prices to vehicles, enabling detailed descriptions of their optional or standard characteristics.
- **Activation Status**: The `is_active` column allows for the activation or deactivation of features without deleting them from the database.

### Related Objects

- **dbo.vehicle**: References the vehicles to which features are assigned.
- **dbo.feature**: Defines the features that can be assigned to vehicles.
- **dbo.set_vehicle_feature_value**: A function that sets or updates the price of a feature for a vehicle.

### Sample Usage

To insert a new feature and its price for a vehicle, you can use the following SQL statement:

```plsql
insert into dbo.vehicle_feature (vehicle_id, feature_id, is_optional, is_active, price, currency)
values ('vehicle-uuid', 1, true, true, 1500.00, 'USD');
```

To retrieve all active features for a specific vehicle:

```plsql
select * from dbo.vehicle_feature where vehicle_id = 'vehicle-uuid' and is_active = true;
```

### Technical Details

- **Composite Primary Key**: The combination of `vehicle_id` and `feature_id` serves as the primary key, ensuring that each feature is unique for a given vehicle.
- **Foreign Keys**: The table includes foreign key constraints that reference the `dbo.vehicle` and `dbo.feature` tables, ensuring referential integrity.

This table is essential for managing the optional or standard features of vehicles within the EV database, enabling structured and organized data management.