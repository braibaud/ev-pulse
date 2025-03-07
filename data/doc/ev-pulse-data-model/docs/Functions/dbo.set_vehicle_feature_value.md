## dbo.set_vehicle_feature_value Function Documentation

### Overview

The `dbo.set_vehicle_feature_value` function is designed to update or insert the value of a feature for a specific vehicle in the EV database. This function ensures that the feature value is correctly set, taking into account whether the feature is overridable.

### Function Definition

```sql
create or replace function dbo.set_vehicle_feature_value(
    p_vehicle_id uuid,
    p_feature_id integer,
    p_price real,
    p_currency text
)
returns void as
$$
declare
    v_existing_feature dbo.vehicle_feature%rowtype;
    v_feature dbo.feature%rowtype;
begin
    select * into v_feature
    from dbo.feature
    where id = p_feature_id;

    if not v_feature.is_overridable then
        raise exception 'Cannot override non-overridable feature';
    end if;

    select * into v_existing_feature
    from dbo.vehicle_feature
    where vehicle_id = p_vehicle_id and feature_id = p_feature_id;

    if v_existing_feature is not null and not v_existing_feature.is_overridable then
        raise exception 'Cannot override non-overridable feature';
    end if;

    insert into dbo.vehicle_feature (vehicle_id, feature_id, is_active, price, currency)
    values (p_vehicle_id, p_feature_id, true, p_price, p_currency)
    on conflict (vehicle_id, feature_id) do update
    set price = p_price, currency = p_currency;
end;
$$
language plpgsql;
```

### Parameters

- **p_vehicle_id**: A UUID that specifies the vehicle for which the feature value is being set.
- **p_feature_id**: An integer that specifies the feature to be updated or inserted.
- **p_price**: A real number representing the price of the feature.
- **p_currency**: A text string representing the currency of the feature price.

### Functional Usage

- **Feature Value Management**: This function allows for the setting of feature values for a specific vehicle. It checks whether the feature is overridable before making any updates.
- **Conflict Handling**: The function uses the `ON CONFLICT` clause to update the feature value if it already exists, ensuring that the most recent value is stored.

### Related Objects

- **dbo.vehicle_feature**: The table where vehicle-specific feature values are stored.
- **dbo.feature**: The table defining the features that can be associated with vehicles.

### Sample Usage

To set the value of a feature for a specific vehicle, you can call the function as follows:

```sql
select dbo.set_vehicle_feature_value(
    'vehicle-uuid',
    1,
    1500.00,
    'USD'
);
```

### Technical Details

- **Error Handling**: The function raises an exception if an attempt is made to override a non-overridable feature.
- **Transaction Management**: The function performs an insert or update operation within a single transaction, ensuring data consistency.

This function is essential for managing feature values associated with vehicles, providing a structured way to update and maintain feature information within the EV database.