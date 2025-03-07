## dbo.related_entities Table Documentation

### Overview

The `dbo.related_entities` table captures relationships between entities within the EV database. This table allows for the establishment of associations between different entities, such as linking a variant to a motor or a battery to a model. These relationships can be used to represent various types of connections, such as compatibility or dependency.

### Table Definition

```sql
create table if not exists dbo.related_entities (
    entity1_id uuid not null,
    entity1_type_id integer not null,
    entity2_id uuid not null,
    entity2_type_id integer not null,
    primary key (entity1_id, entity1_type_id, entity2_id, entity2_type_id),
    foreign key (entity1_id, entity1_type_id) references dbo.entity(id, entity_type_id),
    foreign key (entity2_id, entity2_type_id) references dbo.entity(id, entity_type_id)
);
```

### Columns

- **entity1_id**: A UUID that references the first entity in the relationship.
- **entity1_type_id**: An integer that specifies the type of the first entity.
- **entity2_id**: A UUID that references the second entity in the relationship.
- **entity2_type_id**: An integer that specifies the type of the second entity.

### Functional Usage

- **Relationship Management**: The `dbo.related_entities` table allows for the establishment and management of relationships between entities. These relationships can represent various types of associations, such as compatibility or dependency.
- **Bidirectional Relationships**: The table can capture bidirectional relationships, where either entity can be considered the first or second entity in the relationship.

### Related Objects

- **dbo.entity**: References the entities involved in the relationships.

### Sample Usage

To establish a relationship between two entities, you can use the following SQL statement:

```sql
insert into dbo.related_entities (entity1_id, entity1_type_id, entity2_id, entity2_type_id)
values ('entity1-uuid', 2, 'entity2-uuid', 4);
```

To retrieve all relationships involving a specific entity:

```sql
select * from dbo.related_entities where entity1_id = 'entity1-uuid' or entity2_id = 'entity1-uuid';
```

### Technical Details

- **Composite Primary Key**: The combination of `entity1_id`, `entity1_type_id`, `entity2_id`, and `entity2_type_id` serves as the primary key, ensuring that each relationship is unique.
- **Foreign Keys**: The table includes foreign key constraints that reference the `dbo.entity` table, ensuring referential integrity for both entities in the relationship.

This table is crucial for managing the complex relationships between entities within the EV database, enabling structured and organized data management.