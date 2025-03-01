-- Create the FeatureGroup table
DROP TABLE IF EXISTS FeatureGroup;

CREATE TABLE FeatureGroup (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);


-- Create the Feature table
DROP TABLE IF EXISTS Feature;

CREATE TABLE Feature (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    feature_group_id INTEGER,
    FOREIGN KEY (feature_group_id) REFERENCES FeatureGroup(id)
);


-- Create the AttributeGroup table
DROP TABLE IF EXISTS AttributeGroup;

CREATE TABLE AttributeGroup (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);


-- Create the Attribute table
DROP TABLE IF EXISTS Attribute;

CREATE TABLE Attribute (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    attribute_group_id INTEGER,
    FOREIGN KEY (attribute_group_id) REFERENCES AttributeGroup(id)
);


-- Create the Brand table
DROP TABLE IF EXISTS Brand;

CREATE TABLE Brand (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE
);


-- Create the BrandAttribute table for many-to-many relationship
DROP TABLE IF EXISTS BrandAttribute;

CREATE TABLE BrandAttribute (
    brand_id INTEGER NOT NULL,
    attribute_id INTEGER NOT NULL,
    value TEXT NOT NULL,
    unit TEXT,
    PRIMARY KEY (brand_id, attribute_id),
    FOREIGN KEY (brand_id) REFERENCES Brand(id),
    FOREIGN KEY (attribute_id) REFERENCES Attribute(id)
);


-- Create the Model table
DROP TABLE IF EXISTS Model;

CREATE TABLE Model (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    launch_year INTEGER NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES Brand(id)
);


-- Create the ModelFeature table for many-to-many relationship
DROP TABLE IF EXISTS ModelFeature;

CREATE TABLE ModelFeature (
    model_id INTEGER NOT NULL,
    feature_id INTEGER NOT NULL,
    is_included BOOLEAN NOT NULL,
    price REAL NOT NULL,
    currency TEXT,
    PRIMARY KEY (model_id, feature_id),
    FOREIGN KEY (model_id) REFERENCES Model(id),
    FOREIGN KEY (feature_id) REFERENCES Feature(id)
);


-- Create the ModelAttribute table for many-to-many relationship
DROP TABLE IF EXISTS ModelAttribute;

CREATE TABLE ModelAttribute (
    model_id INTEGER NOT NULL,
    attribute_id INTEGER NOT NULL,
    value TEXT NOT NULL,
    unit TEXT,
    PRIMARY KEY (model_id, attribute_id),
    FOREIGN KEY (model_id) REFERENCES Model(id),
    FOREIGN KEY (attribute_id) REFERENCES Attribute(id)
);


-- Create the Variant table
DROP TABLE IF EXISTS Variant;

CREATE TABLE Variant (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    model_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    is_real_variant BOOLEAN NOT NULL,
    inherits_from INTEGER,
    availability TEXT,
    launch_date DATE,
    FOREIGN KEY (model_id) REFERENCES Model(id),
    FOREIGN KEY (inherits_from) REFERENCES Variant(id)
);


-- Create the VariantFeature table for many-to-many relationship
DROP TABLE IF EXISTS VariantFeature;

CREATE TABLE VariantFeature (
    variant_id INTEGER NOT NULL,
    feature_id INTEGER NOT NULL,
    is_included BOOLEAN NOT NULL,
    price REAL NOT NULL,
    currency TEXT,
    PRIMARY KEY (variant_id, feature_id),
    FOREIGN KEY (variant_id) REFERENCES Variant(id),
    FOREIGN KEY (feature_id) REFERENCES Feature(id)
);


-- Create the VariantAttribute table for many-to-many relationship
DROP TABLE IF EXISTS VariantAttribute;

CREATE TABLE VariantAttribute (
    variant_id INTEGER NOT NULL,
    attribute_id INTEGER NOT NULL,
    value TEXT NOT NULL,
    unit TEXT,
    PRIMARY KEY (variant_id, attribute_id),
    FOREIGN KEY (variant_id) REFERENCES Variant(id),
    FOREIGN KEY (attribute_id) REFERENCES Attribute(id)
);


-- Create the Motor table
DROP TABLE IF EXISTS Motor;

CREATE TABLE Motor (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand_id INTEGER NOT NULL,
    type TEXT NOT NULL,
    power REAL NOT NULL,
    power_unit TEXT NOT NULL,
    torque REAL NOT NULL,
    torque_unit TEXT NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES Brand(id)
);


-- Create the MotorFeature table for many-to-many relationship
DROP TABLE IF EXISTS MotorFeature;

CREATE TABLE MotorFeature (
    motor_id INTEGER NOT NULL,
    feature_id INTEGER NOT NULL,
    is_included BOOLEAN NOT NULL,
    price REAL NOT NULL,
    currency TEXT,
    PRIMARY KEY (motor_id, feature_id),
    FOREIGN KEY (motor_id) REFERENCES Motor(id),
    FOREIGN KEY (feature_id) REFERENCES Feature(id)
);


-- Create the MotorAttribute table for many-to-many relationship
DROP TABLE IF EXISTS MotorAttribute;

CREATE TABLE MotorAttribute (
    motor_id INTEGER NOT NULL,
    attribute_id INTEGER NOT NULL,
    value TEXT NOT NULL,
    unit TEXT,
    PRIMARY KEY (motor_id, attribute_id),
    FOREIGN KEY (motor_id) REFERENCES Motor(id),
    FOREIGN KEY (attribute_id) REFERENCES Attribute(id)
);


-- Create the Battery table
DROP TABLE IF EXISTS Battery;

CREATE TABLE Battery (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    brand_id INTEGER NOT NULL,
    capacity REAL NOT NULL,
    capacity_unit TEXT NOT NULL,
    range REAL NOT NULL,
    range_unit TEXT NOT NULL,
    FOREIGN KEY (brand_id) REFERENCES Brand(id)
);


-- Create the BatteryFeature table for many-to-many relationship
DROP TABLE IF EXISTS BatteryFeature;

CREATE TABLE BatteryFeature (
    battery_id INTEGER NOT NULL,
    feature_id INTEGER NOT NULL,
    is_included BOOLEAN NOT NULL,
    price REAL NOT NULL,
    currency TEXT,
    PRIMARY KEY (battery_id, feature_id),
    FOREIGN KEY (battery_id) REFERENCES Battery(id),
    FOREIGN KEY (feature_id) REFERENCES Feature(id)
);


-- Create the BatteryAttribute table for many-to-many relationship
DROP TABLE IF EXISTS BatteryAttribute;

CREATE TABLE BatteryAttribute (
    battery_id INTEGER NOT NULL,
    attribute_id INTEGER NOT NULL,
    value TEXT NOT NULL,
    unit TEXT,
    PRIMARY KEY (battery_id, attribute_id),
    FOREIGN KEY (battery_id) REFERENCES Battery(id),
    FOREIGN KEY (attribute_id) REFERENCES Attribute(id)
);


-- Create the Vehicle table for the combination of variant, motor, and battery
DROP TABLE IF EXISTS Vehicle;

CREATE TABLE Vehicle (
    variant_id INTEGER NOT NULL,
    motor_id INTEGER NOT NULL,
    battery_id INTEGER NOT NULL,
    price REAL NOT NULL,
    currency TEXT,
    PRIMARY KEY (variant_id, motor_id, battery_id),
    FOREIGN KEY (variant_id) REFERENCES Variant(id),
    FOREIGN KEY (motor_id) REFERENCES Motor(id),
    FOREIGN KEY (battery_id) REFERENCES Battery(id)
);


-- Create the VehicleFeature table for many-to-many relationship
DROP TABLE IF EXISTS VehicleFeature;

CREATE TABLE VehicleFeature (
    variant_id INTEGER NOT NULL,
    motor_id INTEGER NOT NULL,
    battery_id INTEGER NOT NULL,
    feature_id INTEGER NOT NULL,
    is_included BOOLEAN NOT NULL,
    price REAL NOT NULL,
    currency TEXT,
    PRIMARY KEY (variant_id, motor_id, battery_id, feature_id),
    FOREIGN KEY (variant_id, motor_id, battery_id) REFERENCES Vehicle(variant_id, motor_id, battery_id),
    FOREIGN KEY (feature_id) REFERENCES Feature(id)
);


-- Create the VehicleAttribute table for many-to-many relationship
DROP TABLE IF EXISTS VehicleAttribute;

CREATE TABLE VehicleAttribute (
    variant_id INTEGER NOT NULL,
    motor_id INTEGER NOT NULL,
    battery_id INTEGER NOT NULL,
    attribute_id INTEGER NOT NULL,
    value TEXT NOT NULL,
    unit TEXT,
    PRIMARY KEY (variant_id, motor_id, battery_id, attribute_id),
    FOREIGN KEY (variant_id, motor_id, battery_id) REFERENCES Vehicle(variant_id, motor_id, battery_id),
    FOREIGN KEY (attribute_id) REFERENCES Attribute(id)
);


-- Create the RelatedModel table for related models
DROP TABLE IF EXISTS RelatedModel;

CREATE TABLE RelatedModel (
    model_id_1 INTEGER NOT NULL,
    model_id_2 INTEGER NOT NULL,
    PRIMARY KEY (model_id_1, model_id_2),
    FOREIGN KEY (model_id_1) REFERENCES Model(id),
    FOREIGN KEY (model_id_2) REFERENCES Model(id)
);


-- Create a trigger to enforce brand consistency for Motor
CREATE TRIGGER check_motor_brand
BEFORE INSERT ON Vehicle
FOR EACH ROW
BEGIN
    SELECT
        CASE
            WHEN (SELECT brand_id FROM Variant JOIN Model ON Variant.model_id = Model.id WHERE Variant.id = NEW.variant_id) !=
                 (SELECT brand_id FROM Motor WHERE id = NEW.motor_id)
            THEN RAISE(FAIL, 'Brand mismatch between Variant and Motor')
        END;
END;


-- Create a trigger to enforce brand consistency for Battery
CREATE TRIGGER check_battery_brand
BEFORE INSERT ON Vehicle
FOR EACH ROW
BEGIN
    SELECT
        CASE
            WHEN (SELECT brand_id FROM Variant JOIN Model ON Variant.model_id = Model.id WHERE Variant.id = NEW.variant_id) !=
                 (SELECT brand_id FROM Battery WHERE id = NEW.battery_id)
            THEN RAISE(FAIL, 'Brand mismatch between Variant and Battery')
        END;
END;