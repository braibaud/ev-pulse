You'll find below a database schema; the purpose of this database is to handle electric car (EV) related information:

- An EV is represented as an entry in the `dbo.vehicule` table.
- An EV is made of a variant, a motor and a battery.
- Each of these parts is defined in the `dbo.entity` table which allows defining various types of entities defined in the `dbo.entity_type` table.
- An entity can inherit attributes and features from a parent entity (that is the purpose of `foreign key (parent_id, parent_entity_type_name) references dbo.entity(id, entity_type_name)`). Everything that is not overriden is inherited; it includes attributes and features.

I want to change few things:

- I don't like the way a vehicule parts is implemented. It is not flexible enough.
- I want to add a new table `dbo.part` to handle the parts of a vehicule.
- I want to add a new table `dbo.vehicule_part` to link a vehicule to its parts.
- At the moment, a vehicle is made of 3 parts: a variant, a motor and a battery. I want to make it more flexible so that a vehicle can have any number of parts.
- However, a vehicle: 
  - Must have at least one part.
  - Each part must be unique for a vehicule.
  - Each part must have a type (e.g., variant, motor, battery).

I need you to update the database schema accordingly.
Response with a new database schema full script that reflects the changes I want to make.

--- START OF DATABASE SCHEMA ---

--- END OF DATABASE SCHEMA ---

