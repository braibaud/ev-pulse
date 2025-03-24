-- Create Attributes

-- Electric Range
SELECT dbo.create_attribute('Mixed WLTP Range', 'Electric Range', 'km', true, true, true);
SELECT dbo.create_attribute('City WLTP Range', 'Electric Range', 'km', true, true, true);
SELECT dbo.create_attribute('Combined Cycle Consumption', 'Electric Range', 'kWh/100km', true, true, true);

-- PERFORMANCE
SELECT dbo.create_attribute('Max Power', 'Performance', 'kW (hp)', true, true, true);
SELECT dbo.create_attribute('Max Torque', 'Performance', 'Nm', true, true, true);
SELECT dbo.create_attribute('Max Speed', 'Performance', 'km/h', true, true, true);
SELECT dbo.create_attribute('0 - 100 km/h Time', 'Performance', 's', true, true, true);
SELECT dbo.create_attribute('0 - 50 km/h Time', 'Performance', 's', true, true, true);

-- TRANSMISSION
SELECT dbo.create_attribute('Number of Gears', 'Transmission', '-', true, true, true);

-- BATTERY
SELECT dbo.create_attribute('Gross Capacity', 'Battery', 'kWh', true, true, true);
SELECT dbo.create_attribute('Usable Capacity', 'Battery', 'kWh', true, true, true);
SELECT dbo.create_attribute('Technology', 'Battery', '-', true, true, true);
SELECT dbo.create_attribute('Voltage', 'Battery', 'V', true, true, true);
SELECT dbo.create_attribute('Battery Weight', 'Battery', 'kg', true, true, true);

-- CHARGING TIME
SELECT dbo.create_attribute('Home Outlet 3 kW AC 13A 0-100%', 'Charging', 'min', true, true, true);
SELECT dbo.create_attribute('Public Charging 11 kW AC 16A 0-100%', 'Charging', 'min', true, true, true);
SELECT dbo.create_attribute('Fast Charge 50 kW DC 0-80%', 'Charging', 'min', true, true, true);
SELECT dbo.create_attribute('Fast Charge 85 kW DC 0-80%', 'Charging', 'min', true, true, true);

-- DIMENSIONS
SELECT dbo.create_attribute('Length', 'Dimensions', 'cm', true, true, true);
SELECT dbo.create_attribute('Height', 'Dimensions', 'cm', true, true, true);
SELECT dbo.create_attribute('Width with Mirrors Folded', 'Dimensions', 'cm', true, true, true);
SELECT dbo.create_attribute('Width with Mirrors', 'Dimensions', 'cm', true, true, true);
SELECT dbo.create_attribute('Wheelbase', 'Dimensions', 'cm', true, true, true);
SELECT dbo.create_attribute('Trunk Volume', 'Dimensions', 'l', true, true, true);
SELECT dbo.create_attribute('Turning Diameter', 'Dimensions', 'm', true, true, true);

-- WHEELS AND TIRES
SELECT dbo.create_attribute('Tire Size', 'Wheels and Tires', '-', true, true, true);
SELECT dbo.create_attribute('Wheel Size', 'Wheels and Tires', 'in', true, true, true);

-- WEIGHT
SELECT dbo.create_attribute('Unladen Weight', 'Weight', 'kg', true, true, true);

-- Create Features

-- STYLE & DESIGN
SELECT dbo.create_feature('Body-colored Painted Bumpers', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Hidden Door Handles', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Body-colored Mirror Caps', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('15" Steel Wheels', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('16" Icon Alloy Wheels', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('17" Bi-color Alloy Wheels', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Steering Wheel with Controls', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Soft-touch Steering Wheel with Controls', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Bi-color Soft-touch Steering Wheel with Controls', 'Interior', null, true, true, true);
SELECT dbo.create_feature('Chrome Side Strips', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Chrome Window Trim', 'Exterior', null, true, true, true);
SELECT dbo.create_feature('Door Sills', 'Exterior', null, true, true, true);

-- SAFETY
SELECT dbo.create_feature('ABS with EBD', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Lane Departure Warning with Correction', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Emergency Call e-Call', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Light Sensors', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Driver Fatigue Detection', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Power Steering', 'Safety', null, true, true, true);
SELECT dbo.create_feature('ESP with Hill Holder', 'Safety', null, true, true, true);
SELECT dbo.create_feature('LED Daytime Running Lights', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Electric Parking Brake', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Autonomous Emergency Braking', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Speed Limiter', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Traffic Sign Recognition', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Cruise Control', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Rain Sensors', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Intelligent Speed Limiter', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Automatic High/Low Beam Headlights', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Full LED Infinity Headlights', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Photochromatic Interior Mirror', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Rearview Camera', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Lane Keeping Assist', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Adaptive Cruise Control', 'Safety', null, true, true, true);
SELECT dbo.create_feature('Blind Spot Detection', 'Safety', null, true, true, true);
SELECT dbo.create_feature('360° Radars with Drone View', 'Safety', null, true, true, true);

-- INTERIOR
SELECT dbo.create_feature('Electrically Adjustable Exterior Mirrors', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Electric Front Windows', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Height-Adjustable Steering Wheel', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Depth-Adjustable Steering Wheel', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Driver Seat with 4-Way Adjustment', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Driver Seat with 6-Way Adjustment', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Wireless Phone Charger', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Heated Front Seats', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Heated Windshield', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Glove Box with UV-C Disinfecting Light', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Automatic Single-Zone Climate Control', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Automatic Dual-Zone Climate Control', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Center Armrest', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Closed Central Console', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('50/50 Split-Folding Rear Bench', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Panoramic Glass Roof', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Keyless Entry (Driver Side)', 'Comfort', null, true, true, true);
SELECT dbo.create_feature('Floor Mats', 'Comfort', null, true, true, true);

-- SOUND & CONNECTIVITY
SELECT dbo.create_feature('Smartphone Holder', 'Connectivity', null, true, true, true);
SELECT dbo.create_feature('Uconnect 7" DAB System', 'Connectivity', null, true, true, true);
SELECT dbo.create_feature('Uconnect 10.25" DAB System with Navigation', 'Connectivity', null, true, true, true);
SELECT dbo.create_feature('Wireless Apple CarPlay / Android Auto', 'Connectivity', null, true, true, true);
SELECT dbo.create_feature('Mopar Connect Box', 'Connectivity', null, true, true, true);

-- ELECTRIC VEHICLE EQUIPMENT
SELECT dbo.create_feature('Type 2 Mode 2 Charging Cable (Home Charging)', 'Charging', null, true, true, true);
SELECT dbo.create_feature('Onboard AC Mono-Triphasé Charger up to 11 kW', 'Charging', null, true, true, true);
SELECT dbo.create_feature('DC Fast Charging up to 50 kW', 'Charging', null, true, true, true);
SELECT dbo.create_feature('DC Fast Charging up to 85 kW', 'Charging', null, true, true, true);
SELECT dbo.create_feature('EV Drive Mode Selector', 'Charging', null, true, true, true);
SELECT dbo.create_feature('Pedestrian Alert System', 'Charging', null, true, true, true);
SELECT dbo.create_feature('Type 2 Mode 3 Charging Cable (Wallbox & Public Charging)', 'Charging', null, true, true, true);
