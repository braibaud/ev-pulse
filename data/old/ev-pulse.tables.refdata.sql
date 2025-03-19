-- Reinitialize data in the entity_type table
delete from dbo.entity_type;

insert into dbo.entity_type (id, name)
values
    (0, 'Brand'),
    (1, 'Model'),
    (2, 'Variant'),
    (3, 'Battery'),
    (4, 'Motor');

-- Reinitialize data in the attribute_group table
delete from dbo.attribute_group;

insert into dbo.attribute_group (name)
values
    ('Performance'),
    ('Dimensions'),
    ('Weight'),
    ('Fuel Efficiency'),
    ('Electric Range'),
    ('Charging'),
    ('Materials'),
    ('Pricing'),
    ('Warranty'),
    ('Certifications'),
    ('Safety'),
    ('Manufacturing Details');

-- Reinitialize data in the feature_group table
delete from dbo.feature_group;

insert into dbo.feature_group (name)
values
    ('Interior'),
    ('Exterior'),
    ('Technology'),
    ('Colors'),
    ('Safety'),
    ('Comfort'),
    ('Performance'),
    ('Connectivity'),
    ('Entertainment'),
    ('Efficiency');
