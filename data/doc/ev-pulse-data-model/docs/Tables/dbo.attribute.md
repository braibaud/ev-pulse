## dbo.attribute Table Documentation

### Overview

The `dbo.attribute` table defines various attributes that can be associated with entities in the EV database. These attributes provide detailed characteristics of entities, such as performance metrics, dimensions, or safety features. Each attribute is linked to an attribute group for better organization and management.

### Table Definition

```sql
create table if not exists dbo.attribute (
    id serial,
    attribute_group_id integer,
    is_active boolean not null default true,
    name text not null,
    default_unit text,
    is_inheritable boolean not null default true,
    is_overridable boolean not null default true,
    primary key (id),
    foreign key (attribute_group_id) references dbo.attribute_group (id)
);
```

### Columns

- **id**: A serial integer that serves as the unique identifier for the attribute.
- **attribute_group_id**: An integer that references the attribute group to which the attribute belongs.
- **is_active**: A boolean flag indicating whether the attribute is active.
- **name**: The name of the attribute (e.g., Horsepower, Range, Weight).
- **default_unit**: The default unit of measurement for the attribute (e.g., kW, miles, kg).
- **is_inheritable**: A boolean flag indicating whether the attribute can be inherited by child entities.
- **is_overridable**: A boolean flag indicating whether the attribute value can be overridden by child entities.

### Functional Usage

- **Attribute Management**: The `dbo.attribute` table allows for the definition and management of various attributes that describe the characteristics of entities.
- **Inheritance and Override**: Attributes can be inherited by child entities and overridden if necessary, providing flexibility in data management.
- **Grouping**: Attributes are grouped using the `attribute_group_id` column, which references the `dbo.attribute_group` table.

### Related Objects

- **dbo.attribute_group**: Defines the groups to which attributes belong.
- **dbo.entity_attribute**: Associates attributes with entities and stores their values.

### Sample Usage

To insert a new attribute, you can use the following SQL statement:

```sql
insert into dbo.attribute (attribute_group_id, name, default_unit, is_inheritable, is_overridable)
values (1, 'Horsepower', 'kW', true, true);
```

To retrieve all active attributes in a specific group:

```sql
select * from dbo.attribute where attribute_group_id = 1 and is_active = true;
```

### Technical Details

- **Auto-Increment ID**: The `id` column is defined as a serial type, which automatically generates a unique identifier for each new attribute.
- **Constraint Management**: The `id` column serves as the primary key, ensuring that each attribute has a unique identifier. The `attribute_group_id` column is a foreign key that references the `dbo.attribute_group` table.

This table is essential for defining the characteristics of entities within the EV database, enabling detailed and structured data management.